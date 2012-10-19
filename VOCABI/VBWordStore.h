//
//  VBWordStore.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VBWord; 

@interface VBWordStore : NSObject
{
    NSManagedObjectModel *_model;
    NSManagedObjectContext *_context;
}

+ (VBWordStore *)sharedStore;
- (void)fetchUpdateOnCompletion:(void (^)(Boolean))block;
- (Boolean)applyUpdate;
- (void)unnoteWord:(VBWord *)word; 
- (void)noteWord:(VBWord *)word;
- (Boolean)isNoted:(VBWord *)word;
- (VBWord *)wordWithUID:(NSString *)uid; 

@property (nonatomic, readonly) NSMutableArray *allWords;
@property (nonatomic, readonly) NSMutableArray *allWordlists;
@property (nonatomic, readonly) NSMutableArray *notedWords;

@end
