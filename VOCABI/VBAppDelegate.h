//
//  VBAppDelegate.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VBWelcomeViewController;
@class VBWordlistViewController;
@class VBSearchViewController;
@class VBNotebookViewController;
@class VBSyncViewController; 

@interface VBAppDelegate : UIResponder <UIApplicationDelegate>
{
    UITabBarController *_tbc;
    VBWelcomeViewController *_wevc;
    VBWordlistViewController *_wlvc;
    VBSearchViewController *_svc;
    VBNotebookViewController *_nvc;
    VBSyncViewController *_syvc; 
}

@property (strong, nonatomic) UIWindow *window;

@end
