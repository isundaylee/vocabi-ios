//
//  VBWord.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VBWordlist;

@interface VBWord : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * ps;
@property (nonatomic, retain) NSString * meaning;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * sample;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) VBWordlist *wordlist;

- (NSComparisonResult) compare:(VBWord *)object; 

@end
