//
//  VBWord.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWord.h"
#import "VBWordlist.h"


@implementation VBWord

@dynamic word;
@dynamic ps;
@dynamic meaning;
@dynamic desc;
@dynamic sample;
@dynamic uid;
@dynamic wordlist;

- (NSComparisonResult)compare:(VBWord *)object
{
    return [[self word] localizedCaseInsensitiveCompare:[object word]]; 
}

@end
