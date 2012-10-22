//
//  VBWordlisting.h
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VBWordlisting <NSObject>

- (NSString *)listTitle;
- (NSInteger)count;
- (NSArray *)orderedWords;

@end
