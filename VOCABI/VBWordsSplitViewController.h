//
//  VBWordsSplitViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/21/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBWordlisting.h"

@class VBWordlist;
@class VBWordsViewController;
@class VBCardViewController;

@interface VBWordsSplitViewController : UIViewController

@property (nonatomic) id<VBWordlisting> wordlist;
@property (nonatomic, readonly) VBWordsViewController *wordsViewController;
@property (nonatomic, readonly) VBCardViewController *cardViewController;

@end
