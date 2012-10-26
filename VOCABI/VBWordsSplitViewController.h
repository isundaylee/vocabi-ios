//
//  VBWordsSplitViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/21/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBWordListing.h"

@class VBWordlist;
@class VBWordsViewController;
@class VBCarouselViewController;

@interface VBWordsSplitViewController : UIViewController

@property (nonatomic) id<VBWordListing> wordlist;
@property (nonatomic, readonly) VBWordsViewController *wordsViewController;
@property (nonatomic, readonly) VBCarouselViewController *carouselViewController;

- (void) reload;

@end
