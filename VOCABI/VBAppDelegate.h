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
@class VBSettingsViewController;
@class VBWordsViewController;
@class VBWordsSplitViewController;

@interface VBAppDelegate : UIResponder <UIApplicationDelegate>
{
    UITabBarController *_tbc;
    VBWelcomeViewController *_wevc;
    VBWordlistViewController *_wlvc;
    VBSearchViewController *_svc;
    VBWordlistViewController *_nvc;
    VBSettingsViewController *_syvc;
    VBWordsSplitViewController *_nsvc; 
}

@property (strong, nonatomic) UIWindow *window;

@end
