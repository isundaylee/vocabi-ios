//
//  VBWordsViewControllerDelegate.h
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VBWordsViewController;

@protocol VBWordsViewControllerDelegate <NSObject>

- (void)wordsViewController:(VBWordsViewController *)controller didSelectWordWithIndex:(NSInteger)index;

@end
