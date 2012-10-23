//
//  VBWordlist.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VBWordListing.h"


@interface VBWordlist : NSManagedObject <VBWordListing>

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *words;
@end

@interface VBWordlist (CoreDataGeneratedAccessors)

- (void)addWordsObject:(NSManagedObject *)value;
- (void)removeWordsObject:(NSManagedObject *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

- (NSComparisonResult)compare:(VBWordlist *)object;

@end
