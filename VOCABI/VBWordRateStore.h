//
//  VBWordRateStore.h
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBWordlistListing.h"

typedef enum {
    VBWordRateNone = 0,
    VBWordRateEasy,
    VBWordRateNormal,
    VBWordRateHard
} VBWordRate;

extern NSString * const VBWordRatesDidChangeNotification;
extern const NSInteger VBWordRatesNumber;

@class VBWord;

@interface VBWordRateStore : NSObject <VBWordlistListing>

- (void)uploadWordRatesWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSString *passcode, NSError *error))block;
- (void)downloadWordRatesWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSError *error))block;

- (NSInteger)purgeWordRates;

- (VBWordRate)rateForWord:(VBWord *)word;
- (void)setRate:(VBWordRate)rate forWord:(VBWord *)word;

+ (VBWordRateStore *) sharedStore;

- (NSArray *)wordsWithRate:(VBWordRate)rate;

- (NSString *)descriptionForWordRate:(VBWordRate)rate;

@end
