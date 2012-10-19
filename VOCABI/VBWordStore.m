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

NSString * const VBWordStoreVersionPrefKey = @"VBWordStoreVersionPrefKey";
NSString * const VBWordStoreLastCheckVersionPrefKey = @"VBWordStoreLastCheckVersionPrefKey";
NSString * const VBWordStoreNotedWordsPrefKey = @"VBWordStoreNotedWordsPrefKey";

NSString * const VBWordStoreRemotePathUpdate = @"http://ljh.me/vocabi-server/collected.json"; 
NSString * const VBWordStoreRemotePathVersion = @"http://ljh.me/vocabi-server/version.php";

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
    [_notedWords addObject:[word uid]];
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

- (void)checkForUpdateOnCompletion:(void (^)(Boolean, NSNumber *))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:VBWordStoreRemotePathVersion]];
    VBConnection *connection = [[VBConnection alloc] initWithRequest:request];
    [connection setCompletionBlock:^void(NSData *data, NSError *error){
        if (error) {
            // [NSException raise:@"Connection failed" format:@"Reason: %@", [error localizedDescription]];
            NSLog(@"Info: Exception during fetching update, ignored. "); 
        } else {
            NSString *str=  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *n = [f numberFromString:str];
            NSNumber *now = [[NSUserDefaults standardUserDefaults] objectForKey:VBWordStoreVersionPrefKey];
            if ([n intValue] > [now intValue]) {
                if (block) block(YES, n);
            } else {
                if (block) block(NO, nil);
            }
        }
    }];
    [connection start]; 
}

- (void)fetchUpdateOnCompletion:(void (^)(Boolean))block
{
    [self checkForUpdateOnCompletion:^(Boolean updated, NSNumber *newVersion) {
        if (!updated) {
            if (block) block(NO);
        } else {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:VBWordStoreRemotePathUpdate]];
            VBConnection *connection = [[VBConnection alloc] initWithRequest:request];
            [connection setCompletionBlock:^(NSData *data, NSError *error) {
                if (error) {
                    // [NSException raise:@"Connection failed" format:@"Reason: %@", [error localizedDescription]];
                    NSLog(@"Info: Exception during fetching update, ignored. ");
                } else {
                    NSString *cachePath = [self updateCachePath];
                    [data writeToFile:cachePath atomically:YES];
                    [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:VBWordStoreLastCheckVersionPrefKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if (block) block(YES);
                }
            }];
            [connection start];
            
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

@end
