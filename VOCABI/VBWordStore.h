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

+ (VBWordStore *)sharedStore;

- (void)fetchUpdateOnCompletion:(void (^)(Boolean updated, NSError *error))block; 
- (Boolean)applyUpdate;

- (void)unnoteWord:(VBWord *)word;
- (void)noteWord:(VBWord *)word;
- (Boolean)isNoted:(VBWord *)word;

- (VBWord *)wordWithUID:(NSString *)uid;

- (void)uploadNotebookWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSString *passcode, NSError *error))block;
- (void)downloadNotebookWithPasscode:(NSString *)passcode onCompletion:(void (^)(NSError *error))block;

- (NSInteger)purgeNotebook;

@property (nonatomic, readonly) NSMutableArray *allWords;
@property (nonatomic, readonly) NSMutableArray *allWordlists;
@property (nonatomic, readonly) NSMutableArray *notedWords;

@end
