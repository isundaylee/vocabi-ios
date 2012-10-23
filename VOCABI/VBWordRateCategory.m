//
//  VBWordRateCategory.m
//  VOCABI
//
//  Created by Jiahao Li on 10/23/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordRateCategory.h"

@interface VBWordRateCategory ()

@property (nonatomic) VBWordRate rate;

@end

@implementation VBWordRateCategory

@synthesize rate = _rate;

- (id)init
{
    [NSException raise:@"Wrong Initializer" format:@"Please use initWithRate:"];
    return nil; 
}

- initWithRate:(VBWordRate)rate
{
    self = [super init];
    if (self) {
        _rate = rate;
    }
    return self; 
}

- (NSString *)listTitle
{
    return [[VBWordRateStore sharedStore] descriptionForWordRate:self.rate];
}

- (NSInteger)countOfWords
{
    return [[self orderedWords] count]; 
}

- (NSArray *)orderedWords
{
    VBWordRateStore *store = [VBWordRateStore sharedStore];
    
    return [store wordsWithRate:self.rate];
}

@end
