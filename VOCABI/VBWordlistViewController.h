//
//  VBWordlistViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VBWordsViewController;
@class VBWordsSplitViewController;

@interface VBWordlistViewController : UITableViewController
{
    VBWordsViewController *_wvc;
    VBWordsSplitViewController *_wsvc;
}

@end
