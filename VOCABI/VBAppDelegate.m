//
//  VBAppDelegate.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBAppDelegate.h"
#import "VBWelcomeViewController.h"
#import "VBWordlistViewController.h"
#import "VBSearchViewController.h"
#import "VBNotebookViewController.h"
#import "VBConnection.h"
#import "VBWordStore.h"

@implementation VBAppDelegate

- (UINavigationController *)wrapInNavigationController:(UIViewController *)vc withTitle:(NSString *)title image:(UIImage *)image
{
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    UITabBarItem *tbi = [nc tabBarItem];
    [tbi setTitle:title];
    [tbi setImage:image];
    
    return nc; 
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Handling Updates
    
    VBWordStore *store = [VBWordStore sharedStore];
    
    if ([store applyUpdate]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wordlists Updated" message:@"The wordlists have been updated to the newest version! " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
    }
    
    [store fetchUpdateOnCompletion:^(Boolean updated) {
        if (!updated) NSLog(@"Version up-to-date! ");
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wordlists Update Fetched" message:@"Wordlists update has been fetched from the server and will be installed the next time you completely restart the app. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    // Creating views controllers
    
    _tbc = [[UITabBarController alloc] init];
    
    _wevc = [[VBWelcomeViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_wevc withTitle:@"Welcome" image:[UIImage imageNamed:@"Home"]]];
    
    _wlvc = [[VBWordlistViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_wlvc withTitle:@"Wordlists" image:[UIImage imageNamed:@"List"]]];
    
    _svc = [[VBSearchViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_svc withTitle:@"Search" image:[UIImage imageNamed:@"Search"]]];
    
    _nvc = [[VBNotebookViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_nvc withTitle:@"Notebook" image:[UIImage imageNamed:@"Note"]]]; 
    
    [[self window] setRootViewController:_tbc];
    
    // Tests
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
