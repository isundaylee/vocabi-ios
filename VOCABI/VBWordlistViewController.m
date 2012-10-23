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
#import "VBWordListing.h"
#import "VBWordsViewController.h"
#import "VBWordsSplitViewController.h"

@interface VBWordlistViewController ()

@end

@implementation VBWordlistViewController

@synthesize wordlistStore = _wordlistStore;
@synthesize wordsViewContoller = _wordsViewContoller;
@synthesize wordsSplitViewController = _wordsSplitViewController; 

- (void)setWordlistStore:(id<VBWordlistListing>)wordlistStore
{
    _wordlistStore = wordlistStore;
    [self.tableView reloadData];
    [[self navigationItem] setTitle:[wordlistStore listTitle]];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [[self navigationItem] setTitle:[self.wordlistStore listTitle]];
        _wordsViewContoller = [[VBWordsViewController alloc] init];
        if (IS_IPAD)
            _wordsSplitViewController = [[VBWordsSplitViewController alloc] init];
    }
    
    return self;
}

- (void)reload
{
    [self.tableView reloadData]; 
}

- (void)viewWillAppear:(BOOL)animated
{
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
    return [self.wordlistStore countOfWordlists];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    id<VBWordListing> wordlist = [[self.wordlistStore orderedWordlists] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[wordlist listTitle]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<VBWordListing> wordlist = [[self.wordlistStore orderedWordlists] objectAtIndex:[indexPath row]];
    
    if (IS_IPAD) {
        [self.wordsSplitViewController setWordlist:wordlist];
        [[self navigationController] pushViewController:self.wordsSplitViewController animated:YES];
    } else {
        [self.wordsViewContoller setWordlist:wordlist];
        [self.wordsViewContoller setDisclosing:YES];
        [[self navigationController] pushViewController:self.wordsViewContoller animated:YES];
    }
}

@end
