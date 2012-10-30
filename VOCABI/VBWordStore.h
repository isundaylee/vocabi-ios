//
//  VBWordStore.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBWordlistListing.h"

@class VBWord;
@class VBNotebook; 

extern NSString * const VBNotebookDidChangeNotification;

@interface VBWordStore : NSObject <VBWordlistListing>

+ (VBWordStore *)sharedStore;

- (void)fetchUpdateOnCompletion:(void (^)(Boolean updated, NSError *error))block; 
- (Boolean)applyUpdate;

- (VBWord *)wordWithUID:(NSString *)uid;

- (BOOL)isActivated;
- (void)activateWithKey:(NSString *)key onCompletion:(void (^)(BOOL activated, NSError *error))block;
- (void)deactivate;

- (NSNumber *)wordRatesVersion; 

@property (nonatomic, readonly) NSMutableArray *allWords;
@property (nonatomic, readonly) NSMutableArray *allWordlists;

@end
