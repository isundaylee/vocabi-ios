//
//  VBWordlistViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordlistViewController.h"
#import "VBWordStore.h"
#import "VBWordlist.h"
#import "VBWord.h"
#import "VBWordsViewController.h"
#import "VBWordsSplitViewController.h"

@interface VBWordlistViewController ()

@end

@implementation VBWordlistViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [[self navigationItem] setTitle:NSLocalizedString(@"Wordlists", nil)];
        _wvc = [[VBWordsViewController alloc] init];
        if (IS_IPAD)
            _wsvc = [[VBWordsSplitViewController alloc] init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData]; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[VBWordStore sharedStore] allWordlists] count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    VBWordlist *list = [[[VBWordStore sharedStore] allWordlists] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[list title]]; 
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBWordlist *list = [[[VBWordStore sharedStore] allWordlists] objectAtIndex:[indexPath row]];
    
    if (IS_IPAD) {
        [_wsvc setWordlist:list];
        [[self navigationController] pushViewController:_wsvc animated:YES];
    } else {
        [_wvc setWordlist:list];
        [_wvc setDisclosing:YES]; 
        [[self navigationController] pushViewController:_wvc animated:YES];
    }
}

@end
