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
#import "VBConnection.h"
#import "VBWordStore.h"
#import "VBWordRateStore.h"
#import "VBSettingsViewController.h"
#import "VBWordsViewController.h"
#import "VBWordsSplitViewController.h"
#import "VBRateViewController.h"

NSString * const VBWelcomeTabPrefKey = @"VBWelcomeTabPrefKey";

@implementation VBAppDelegate

@synthesize exitOnSuspend = _exitOnSuspend; 

+ (void)initialize
{
    [super initialize];
    if ([self class] == [VBAppDelegate class]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:VBWelcomeTabPrefKey];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    }
}

- (void)crackCheck
{
    if ([self isCracked]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PiracyDetected", nil) message:NSLocalizedString(@"PiracyDetectedMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)isCracked
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [bundle infoDictionary];
    if ([infoDict objectForKey:@"SignerIdentity"])
        return YES;
    else
        return NO;
}

- (void)userDefaultsChanged
{
    
}

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
    
    // Tests
    
    NSLog(@"Info: Bundle path: %@", [[NSBundle mainBundle] bundlePath]);
    NSLog(@"Info: Wordlists version: %@", [[VBWordStore sharedStore] wordRatesVersion]);
    
    // Disable exit on suspend

    self.exitOnSuspend = NO;
    
    // Register notification for userdefaults change
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil]; 
    
    // Check for jailbreak
    
    [self crackCheck]; 
    
    // Handling Updates
    
    VBWordStore *store = [VBWordStore sharedStore];
    VBWordRateStore *rateStore = [VBWordRateStore sharedStore];
    
    if ([store applyUpdate]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WordlistsUpdated", nil) message:NSLocalizedString(@"WordlistsUpdatedMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }
    
    NSInteger purged = [rateStore purgeWordRates];
    if (purged > 0) {
        NSString *message;
        if (purged == 1) {
            message = [NSString stringWithFormat:NSLocalizedString(@"NotebookChangedMessageSingle", nil), purged];
        } else {
            message = [NSString stringWithFormat:NSLocalizedString(@"NotebookChangedMessagePlural", nil), purged];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NotebookChanged", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    NSLog(@"Info: %d item(s) purged after vocabulary update. ", purged);
    
    [store fetchUpdateOnCompletion:^(Boolean updated, NSError *error) {
        if (error) {
            NSLog(@"Info: Abort fetching update due to networking error. Detail: %@", [error localizedDescription]);
            return;
        }
        
        if (!updated) NSLog(@"Info: Version up-to-date! ");
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WordlistsUpdateFetched", nil) message:NSLocalizedString(@"WordlistsUpdateFetchedMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            self.exitOnSuspend = YES; 
        }
    }];
    
//    [store deactivate]; 
    
    // Creating views controllers
    
    _tbc = [[UITabBarController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:VBWelcomeTabPrefKey]) {
        _wevc = [[VBWelcomeViewController alloc] init];
        [_tbc addChildViewController:[self wrapInNavigationController:_wevc withTitle:NSLocalizedString(@"Welcome", nil) image:[UIImage imageNamed:@"Home"]]];
    }
    
    _wlvc = [[VBWordlistViewController alloc] init];
    [_wlvc setWordlistStore:store]; 
    [_tbc addChildViewController:[self wrapInNavigationController:_wlvc withTitle:NSLocalizedString(@"Wordlists", nil) image:[UIImage imageNamed:@"List"]]];
    
    _svc = [[VBSearchViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_svc withTitle:NSLocalizedString(@"Search", nil) image:[UIImage imageNamed:@"Search"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordRatesChanged) name:VBWordRatesDidChangeNotification object:rateStore];
    
//    if (IS_IPAD) {
//        _nsvc = [[VBWordsSplitViewController alloc] init];
//        [_nsvc setWordlist:[store notebook]];
//        [_tbc addChildViewController:[self wrapInNavigationController:_nsvc withTitle:NSLocalizedString(@"Notebook", nil) image:[UIImage imageNamed:@"Note"]]]; 
//    } else {
//        _nvc = [[VBWordlistViewController alloc] init];
//        [_nvc setWordlistStore:rateStore];
//        [_tbc addChildViewController:[self wrapInNavigationController:_nvc withTitle:NSLocalizedString(@"Notebook", nil) image:[UIImage imageNamed:@"Note"]]];
//    }
    
    _nvc = [[VBWordlistViewController alloc] init];
    [_nvc setWordlistStore:rateStore];
    [_tbc addChildViewController:[self wrapInNavigationController:_nvc withTitle:NSLocalizedString(@"Notebook", nil) image:[UIImage imageNamed:@"Note"]]];
    
    _syvc = [[VBSettingsViewController alloc] init];
    [_tbc addChildViewController:[self wrapInNavigationController:_syvc withTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"Sync"]]];
    
    [[self window] setRootViewController:_tbc];
    
//    [[self window] setRootViewController:[[VBRateViewController alloc] init]]; 
    
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
    
    if (self.exitOnSuspend) {
        NSLog(@"Program exited. "); 
        exit(0);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self crackCheck]; 
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)wordRatesChanged
{
    if (IS_IPAD) {
        [[_nvc wordsSplitViewController] reload];
    } else {
        [[_nvc wordsViewContoller] reload];
    }
}

@end
