//
//  VBWordsViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBWordListing.h"

@class VBCarouselViewController;

@interface VBWordsViewController : UITableViewController

@property (nonatomic) id<VBWordListing> wordlist;
@property (nonatomic) VBCarouselViewController *carouselViewController;
@property (nonatomic) BOOL disclosing;
@property (nonatomic, strong) void (^didSelectWordBlock)(VBWordsViewController *wordsViewController, NSUInteger index);

- (void)selectWordAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (UIBarButtonItem *)showCardsButton;

- (void)reload;
- (void)reloadSelectedWordAnimated:(BOOL)animated;

@end