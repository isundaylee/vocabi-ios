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
        [[self navigationItem] setTitle:@"Wordlists"];
        _wvc = [[VBWordsViewController alloc] init];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    [_wvc setWordlist:list];
    
    [[self navigationController] pushViewController:_wvc animated:YES]; 
}

@end
