//
//  VBWordRateStore.m
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordRateStore.h"
#import "VBWordStore.h"
#import "VBServerConfig.h"
#import "VBWord.h"
#import "VBWordRateCategory.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

extern NSString * const VBWordStoreRemoteBaseURL; 

const NSInteger VBWordRatesNumber = 4;

@interface VBWordRateStore ()

@property (nonatomic) AFHTTPClient *client;
@property (nonatomic) NSOperationQueue *requestOperationQueue;
@property (nonatomic) NSMutableDictionary *wordRates;

@end

@implementation VBWordRateStore

@synthesize client = _client;
@synthesize requestOperationQueue = _requestOperationQueue;
@synthesize wordRates = _wordRates;

typedef enum {
    VBWordRateStoreInvalidPasscode = -1000,
    VBWordRateStoreNotebookUploadingError,
    VBWordRateStoreNotebookDownloadingError
} VBWordRateStoreErrorCode;

NSString * const VBWordRatesDidChangeNotification = @"VBWordRatesDidChangeNotification";
NSString * const VBWordRateStoreErrorDomain = @"com.sunday.VOCABI.WordRateStore";
NSString * const VBWordStoreWordRatesPrefKey = @"VBWordStoreWordRatesPrefKey";

- (NSInteger)purgeWordRates
{
    NSInteger count = 0;
    NSMutableDictionary *purged = [NSMutableDictionary dictionary];
    
    for (NSString *uid in [self.wordRates allKeys]) {
        if ([[VBWordStore sharedStore] wordWithUID:uid])
            [purged setObject:[self.wordRates objectForKey:uid] forKey:uid];
        else
            count++;
    }
    
    [self setWordRates:purged];
    
    return count;
}

- (VBWordRate)rateForWord:(VBWord *)word
{
    NSNumber *number = [self.wordRates objectForKey:word.uid];
    
    if (number == nil)
        return VBWordRateNone;
    else
        return [number integerValue];
}

- (void)setRate:(VBWordRate)rate forWord:(VBWord *)word
{
    if (rate == VBWordRateNone)
        [self.wordRates removeObjectForKey:word.uid];
    else {
        if ([self.wordRates objectForKey:word.uid] != nil)
            [self.wordRates removeObjectForKey:word.uid];
        [self.wordRates setObject:[NSNumber numberWithInteger:rate] forKey:word.uid];
    }
    
    [self reportWordRatesUpdate];
}

- (void)reportWordRatesUpdate
{
    [[NSUserDefaults standardUserDefaults] setObject:self.wordRates forKey:VBWordStoreWordRatesPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNotification *note = [NSNotification notificationWithName:VBWordRatesDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (BOOL)isPasscodeValid:(NSString *)passcode
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

- (void)uploadWordRatesWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSString *passcode, NSError *error))block
{
    if (!passcode) passcode = @"";
    
    if (!([passcode isEqualToString:@""] || [self isPasscodeValid:passcode])) {
        if (block) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"PasscodeInvalidFirstTime", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordRateStoreErrorDomain code:VBWordRateStoreInvalidPasscode userInfo:dict];
            block(nil, error);
        }
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.wordRates];
    NSString *content = [data base64EncodedString];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:passcode, @"passcode", content, @"content", @"WordRates", @"entity", nil];
    NSMutableURLRequest *request = [self.client requestWithMethod:@"POST" path:@"upload.php" parameters:dict];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSNumber *number = [result objectForKey:@"result"];
        if ([number intValue] != 1) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[result objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordRateStoreErrorDomain code:VBWordRateStoreNotebookUploadingError userInfo:dict];
            if (block) block(nil, error);
        } else {
            NSString *passcode = [result objectForKey:@"passcode"];
            if (block) block(passcode, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil, error);
    }];
    
    [self.requestOperationQueue addOperation:operation];
}

- (void)downloadWordRatesWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSError *))block
{
    if (![self isPasscodeValid:passcode]) {
        if (block) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"PasscodeInvalid", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordRateStoreErrorDomain code:VBWordRateStoreInvalidPasscode userInfo:dict];
            block(error);
        }
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:passcode, @"passcode", @"WordRates", @"entity", nil];
    NSMutableURLRequest *request = [self.client requestWithMethod:@"POST" path:@"download.php" parameters:dict];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSNumber *retcode = [result objectForKey:@"result"];
        if ([retcode intValue] != 1) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[result objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:VBWordRateStoreErrorDomain code:VBWordRateStoreNotebookDownloadingError userInfo:dict];
            if (block) block(error);
        } else {
            NSString *content = [result objectForKey:@"content"];
            NSData *data = [NSData dataFromBase64String:content];
            [self setWordRates:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
            //            [self reportNotedWordsUpdate];
            [self reportWordRatesUpdate];
            if (block) block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(error);
    }];
    
    [_requestOperationQueue addOperation:operation];
}

- (NSInteger)countOfWordlists
{
    return VBWordRatesNumber - 1;
}

- (NSArray *)orderedWordlists
{
    NSMutableArray *answer = [NSMutableArray array]; 
    for (int i=1; i<VBWordRatesNumber; i++) {
        VBWordRateCategory *category = [[VBWordRateCategory alloc] initWithRate:i];
        [answer addObject:category]; 
    }
    return answer;
}

- (NSArray *)wordsWithRate:(VBWordRate)rate
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *uid in [self.wordRates allKeys]) {
        if ([[self.wordRates objectForKey:uid] integerValue] == rate) {
            [array addObject:[[VBWordStore sharedStore] wordWithUID:uid]];
        }
    }
    
    return array; 
}

+ (VBWordRateStore *)sharedStore
{
    static VBWordRateStore *instance = nil;
    
    if (!instance) {
        instance = [[super allocWithZone:nil] init];
    }
    
    return instance; 
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
        _wordRates = [[NSUserDefaults standardUserDefaults] objectForKey:VBWordStoreWordRatesPrefKey];
        
        if (!_wordRates)
        {
            _wordRates = [NSMutableDictionary dictionary];
            [self reportWordRatesUpdate];
        }
        
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:VBWordStoreRemoteBaseURL]];

        _requestOperationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (NSString *)descriptionForWordRate:(VBWordRate)rate
{
    if (rate == VBWordRateNone)
        return NSLocalizedString(@"Unrated", nil);
    else if (rate == VBWordRateEasy)
        return NSLocalizedString(@"Easy", nil);
    else if (rate == VBWordRateNormal)
        return NSLocalizedString(@"NeedsPractice", nil);
    else if (rate == VBWordRateHard)
        return NSLocalizedString(@"Tricky", nil);
    else {
        [NSException raise:NSInvalidArgumentException format:@"Invalid VBWordRate supplied. "];
        return nil;
    }
}

- (NSString *)listTitle
{    
    return NSLocalizedString(@"Notebook", nil);
}

- (UIColor *)colorForWordRate:(VBWordRate)rate
{
    if (rate == VBWordRateNone)
        return [UIColor blackColor];
    else if (rate == VBWordRateEasy)
        return [UIColor colorWithRed:49/255.0 green:189/255.0 blue:49/255.0 alpha:1];
    else if (rate == VBWordRateNormal)
        return [UIColor colorWithRed:230/255.0 green:223/255.0 blue:25/255.0 alpha:1];
    else if (rate == VBWordRateHard)
        return [UIColor redColor];
    else {
        [NSException raise:NSInvalidArgumentException format:@"Invalid VBWordRate supplied. "];
        return nil; 
    }
}

@end
