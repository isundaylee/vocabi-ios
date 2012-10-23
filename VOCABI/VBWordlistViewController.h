//
//  VBWordlistViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBWordlistListing.h"

@class VBWordsViewController;
@class VBWordsSplitViewController;

@interface VBWordlistViewController : UITableViewController

@property (nonatomic) id<VBWordlistListing> wordlistStore;
@property (nonatomic, readonly) VBWordsViewController *wordsViewContoller;
@property (nonatomic, readonly) VBWordsSplitViewController *wordsSplitViewController; 

- (void)reload; 

@end
