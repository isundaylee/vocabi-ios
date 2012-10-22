//
//  VBNotebook.m
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBNotebook.h"
#import "VBWord.h"
#import "VBWordStore.h"

@implementation VBNotebook {
    NSArray *_uids;
}

- (id)initWithUIDs:(NSArray *)uids
{
    self = [super init];
    if (self) {
        _uids = uids;
    }
    return self;
}

- (id)init
{
    return [self initWithUIDs:[NSArray array]];
}

- (NSString *)listTitle
{
    return NSLocalizedString(@"Notebook", nil);
}

- (NSInteger)count
{
    return [_uids count];
}

- (NSArray *)orderedWords
{
    NSMutableArray *words = [NSMutableArray arrayWithCapacity:[self count]];
    VBWordStore *store = [VBWordStore sharedStore];
    for (NSString *uid in _uids) {
        VBWord *word = [store wordWithUID:uid];
        [words addObject:word];
    }
    return words; 
}

@end
