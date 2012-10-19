//
//  VBWordlist.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordlist.h"


@implementation VBWordlist

@dynamic title;
@dynamic words;


- (NSComparisonResult)compare:(VBWordlist *)object
{
    return [[self title] localizedCaseInsensitiveCompare:[object title]]; 
}

@end
