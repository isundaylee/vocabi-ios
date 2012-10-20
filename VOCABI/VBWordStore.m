//
//  VBWordStore.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordStore.h"
#import "VBConnection.h"
#import "CoreData/CoreData.h"
#import "VBWordlist.h"
#import "VBWord.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

NSString * const VBWordStoreVersionPrefKey = @"VBWordStoreVersionPrefKey";
NSString * const VBWordStoreLastCheckVersionPrefKey = @"VBWordStoreLastCheckVersionPrefKey";
NSString * const VBWordStoreNotedWordsPrefKey = @"VBWordStoreNotedWordsPrefKey";

NSString * const VBWordStoreRemotePathUpdate = @"http://ljh.me/vocabi-server/collected.json"; 
NSString * const VBWordStoreRemotePathVersion = @"http://ljh.me/vocabi-server/version.php";
NSString * const VBWordStoreRemotePathUploadNotebook = @"http://localhost/~Sunday/vocabi-server/upload.php";
NSString * const VBWordStoreRemotePathDownloadNotebook = @"http://localhost/~Sunday/vocabi-server/download.php";

NSString * const VBWordStoreHTTPBaseURL = @"http://ljh.me/vocabi-server/";

NSString * const VBWordStoreErrorDomain = @"com.sunday.VOCABI.WordStore";

typedef enum {
    VBWordStoreInvalidPasscode = -1000,
    VBWordStoreNotebookUploadingError,
    VBWordStoreNotebookDownloadingError
} VBWordStoreErrorCode; 

@interface VBWordStore ()
{
    NSManagedObjectModel *_model;
    NSManagedObjectContext *_context;
    
    AFHTTPClient *_httpClient;
    NSOperationQueue *_requestOperationQueue; 
}

@end

@implementation VBWordStore

@synthesize allWords = _allWords;
@synthesize allWordlists = _allWordlists;
@synthesize notedWords = _notedWords;

- (VBWord *)wordWithUID:(NSString *)uid
{
    for (VBWord *word in _allWords) {
        if ([[word uid] isEqualToString:uid]) return word;
    }
    
    return nil; 
}

- (void)noteWord:(VBWord *)word
{
    if ([self isNoted:word]) {
        NSLog(@"Warning: Noting already noted word. Probable logic hole. ");
        return;
    }
    [_notedWords addObject:[[word uid] copy]];
    [self reportNotedWordsUpdate];
}

- (void)unnoteWord:(VBWord *)word
{
    [_notedWords removeObject:[word uid]];
    [self reportNotedWordsUpdate];
}

- (Boolean) isNoted:(VBWord *)word
{
    return [_notedWords containsObject:[word uid]];
    
}

- (NSMutableArray *)allWordlists
{
    return [[_allWordlists sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
}

- (NSMutableArray *)allWords
{
    return [[_allWords sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
}

- (NSMutableArray *)notedWords
{
    return [_notedWords mutableCopy];
}

+ (VBWordStore *)sharedStore
{
    static VBWordStore *instance = nil;
    
    if (!instance) {
        instance = [[super allocWithZone:nil] init];
    }
    
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (void)initialize
{
    NSMutableDictionary *prefKeys = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:VBWordStoreVersionPrefKey];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:prefKeys];
}

- (NSString *)documentDirectoryPath
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirs objectAtIndex:0];
    return path; 
}

- (NSString *)archivePath
{
    return [[self documentDirectoryPath] stringByAppendingPathComponent:@"words.data"];
}

- (NSString *)updateCachePath
{
    return [[self documentDirectoryPath] stringByAppendingPathComponent:@"update.json"];
}

- (NSString *)factoryDatabasePath
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"factory.json"]; 
}

- (void)reportNotedWordsUpdate
{
    [[NSUserDefaults standardUserDefaults] setObject:_notedWords forKey:VBWordStoreNotedWordsPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
}

- (id)init
{
    self = [super init];
    if (self) {
        _allWordlists = [[NSMutableArray alloc] init];
        _allWords = [[NSMutableArray alloc] init];
        
        _notedWords = [[NSUserDefaults standardUserDefaults] objectForKey:VBWordStoreNotedWordsPrefKey];
        
        if (!_notedWords)
        {
            _notedWords = [NSMutableArray array];
            [self reportNotedWordsUpdate]; 
        }

        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        NSURL *pathURL = [NSURL fileURLWithPath:[self archivePath]];
        NSError *err = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:pathURL options:nil error:&err])
        {
            [NSException raise:@"Open failed" format:@"Reason: %@", [err localizedDescription]];
        }
        
        _context = [[NSManagedObjectContext alloc] init];

        [_context setPersistentStoreCoordinator:psc];
        [_context setUndoManager:nil];
        
        _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:VBWordStoreHTTPBaseURL]];
        
        _requestOperationQueue = [[NSOperationQueue alloc] init]; 
        
        [self reloadAllWords];
        [self reloadAllWordlists];
        
        if ([_allWords count] == 0) {
            // Installing factory database
            [self applyUpdateWithPath:[self factoryDatabasePath]];
            NSLog(@"Info: Factory database installed. ");
        }
    }

    return self;
}

- (void)checkForUpdateOnCompletion:(void (^)(Boolean, NSNumber *, NSError *error))block
{
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path:@"version.php" parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = (NSData *)responseObject;
        NSString *versionString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *version = [f numberFromString:versionString];
        NSNumber *now = [[NSUserDefaults standardUserDefaults] objectForKey:VBWordStoreVersionPrefKey];
        if ([version intValue] > [now intValue]) {
            if (block) block(YES, version, nil);
        } else {
            if (block) block(NO, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(NO, nil, error); 
    }];
    
    [_requestOperationQueue addOperation:operation];
}

- (void)fetchUpdateOnCompletion:(void (^)(Boolean updated, NSError *error))block
{
    [self checkForUpdateOnCompletion:^(Boolean updated, NSNumber *newVersion, NSError *error) {
        if (error) {
            if (block) block(NO, error);
            return;
        }
        
        if (!updated) {
            if (block) block(NO, nil);
        } else {
            NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path:@"collected.json" parameters:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSData *data = (NSData *)responseObject;
                NSString *cachePath = [self updateCachePath];
                [data writeToFile:cachePath atomically:YES];
                [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:VBWordStoreLastCheckVersionPrefKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (block) block(YES, nil);

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (block) block(NO, error);
            }];
            
            [_requestOperationQueue addOperation:operation];          
        }
    }];
}

- (void)clear
{
    NSPersistentStoreCoordinator *psc = [_context persistentStoreCoordinator];
    NSArray *stores = [psc persistentStores];
    
    for (NSPersistentStore *store in stores) {
        [psc removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    NSError *err = nil;
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[self archivePath]] options:nil error:&err])
    {
        [NSException raise:@"Open failed" format:@"Reason: %@", [err localizedDescription]];
    }
    
    [self reloadAllWords];
    [self reloadAllWordlists]; 
}

- (Boolean)applyUpdate
{
    Boolean result = [self applyUpdateWithPath:[self updateCachePath]];
    
    NSNumber *newVersion = [[NSUserDefaults standardUserDefaults] objectForKey:VBWordStoreLastCheckVersionPrefKey];
    [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:VBWordStoreVersionPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSFileManager defaultManager] removeItemAtPath:[self updateCachePath] error:nil];
    
    return result;
}

- (Boolean)applyUpdateWithPath:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) return NO;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self clear];
    
    for (NSDictionary *wordlist in json) {
        VBWordlist *newList = [NSEntityDescription insertNewObjectForEntityForName:@"VBWordlist" inManagedObjectContext:_context];
        [newList setTitle:[wordlist objectForKey:@"title"]];
        [_allWordlists addObject:newList];
        NSArray *words = [wordlist objectForKey:@"words"];
        for (NSDictionary *word in words) {
            VBWord *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"VBWord" inManagedObjectContext:_context];
            [newWord setWord:[word objectForKey:@"word"]];
            [newWord setPs:[word objectForKey:@"ps"]];
            [newWord setMeaning:[word objectForKey:@"meaning"]];
            [newWord setDesc:[word objectForKey:@"description"]];
            [newWord setUid:[word objectForKey:@"UID"]]; 
            [newWord setSample:[word objectForKey:@"sample"]];
            [newWord setWordlist:newList];
            [_allWords addObject:newWord];
        }
    }
    
    NSError *err = nil;
    if (![_context save:&err]) {
        [NSException raise:@"Save failed" format:@"Reason: %@", [err localizedDescription]]; 
    }
    
    return YES; 
}

- (void)reloadAllWords
{
    [_allWordlists removeAllObjects];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"VBWord" inManagedObjectContext:_context]];
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"Fetch failed" format:@"Reason: %@", [err localizedDescription]];
    } else {
        _allWords = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (void)reloadAllWordlists
{
    [_allWordlists removeAllObjects];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"VBWordlist" inManagedObjectContext:_context]];
    NSError *err = nil;
    NSArray *result = [_context executeFetchRequest:request error:&err];
    if (!result) {
        [NSException raise:@"Fetch failed" format:@"Reason: %@", [err localizedDescription]];
    } else {
        _allWordlists = [[NSMutableArray alloc] initWithArray:result]; 
    }
}

- (Boolean)isPasscodeValid:(NSString *)passcode
{
    NSString *allowedString = @"0123456789ABCDEF";
    
    if ([passcode length] != 8) return NO;
    for (int i=0; i<[passcode length]; i++) {
        Boolean flag = NO;
        for (int j=0; j<[allowedString length]; j++) {
            if ([allowedString characterAtIndex:j] == [passcode characterAtIndex:i]) flag = YES;
            if (flag) break;
        }
        if (!flag) return NO;
    }
    
    return YES;
}

- (void)uploadNotebookWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSString *passcode, NSError *error))block
{
    if (!passcode) passcode = @""; 
    
    if (!([passcode isEqualToString:@""] || [self isPasscodeValid:passcode])) {
        if (block) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"The passcode supplied is invalid. For first-time sync, leave the passcode blank. " forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordStoreErrorDomain code:VBWordStoreInvalidPasscode userInfo:dict];
            block(nil, error);
        }
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_notedWords];
    NSString *content = [data base64EncodedString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:passcode, @"passcode", content, @"content", nil];
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"upload.php" parameters:dict];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSNumber *number = [result objectForKey:@"result"];
        if ([number intValue] != 1) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[result objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordStoreErrorDomain code:VBWordStoreNotebookUploadingError userInfo:dict];
            if (block) block(nil, error);
        } else {
            NSString *passcode = [result objectForKey:@"passcode"];
            if (block) block(passcode, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil, error);
    }];
    
    [_requestOperationQueue addOperation:operation]; 
}

- (void)downloadNotebookWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSError *))block
{
    if (![self isPasscodeValid:passcode]) {
        if (block) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"The passcode supplied is invalid. " forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordStoreErrorDomain code:VBWordStoreInvalidPasscode userInfo:dict];
            block(error);
        }
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:passcode forKey:@"passcode"];
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"download.php" parameters:dict];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSNumber *retcode = [result objectForKey:@"result"];
        if ([retcode intValue] != 1) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[result objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordStoreErrorDomain code:VBWordStoreNotebookDownloadingError userInfo:dict];
            if (block) block(error);
        } else {
            NSString *content = [result objectForKey:@"content"];
            NSData *data = [NSData dataFromBase64String:content];
            _notedWords = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self reportNotedWordsUpdate];
            if (block) block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(error);
    }];
    
    [_requestOperationQueue addOperation:operation];
}

@end
