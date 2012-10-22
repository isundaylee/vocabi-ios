//
//  VBWordsViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBWordlisting.h"

@class VBWordlist;
@class VBCardViewController; 

@interface VBWordsViewController : UITableViewController

@property (nonatomic) id<VBWordlisting> wordlist;
@property (nonatomic) VBCardViewController *cardViewController;

@property (nonatomic) BOOL disclosing;

- (UIBarButtonItem *)showCardsButton;

- (void)selectWordAtIndex:(NSUInteger)index animated:(BOOL)animated; 

@end
