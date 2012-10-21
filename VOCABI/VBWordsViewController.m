//
//  VBWordsViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordsViewController.h"
#import "VBWord.h"
#import "VBWordStore.h"
#import "VBWordlist.h"
#import "VBCardViewController.h"
#import "VBCarouselViewController.h"

@interface VBWordsViewController ()

@end

@implementation VBWordsViewController

@synthesize wordlist = _wordlist; 

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self.navigationItem setTitle:[[self wordlist] title]];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showCards)];
        [self.navigationItem setRightBarButtonItem:bbi]; 
    }
    return self;
}

- (void)setWordlist:(VBWordlist *)wordlist
{
    _wordlist = wordlist;
    [self.navigationItem setTitle:[[self wordlist] title]];
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
    return [[[self wordlist] words] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    VBWord *word = [[[[self wordlist] words] allObjects] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[word word]]; 
    
    return cell;
}

- (void)showCards
{
    VBCarouselViewController *cvc = [[VBCarouselViewController alloc] initWithWords:[[[self wordlist] words] allObjects]];
    
    [self.navigationController pushViewController:cvc animated:YES]; 
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBWord *word = [[[[self wordlist] words] allObjects] objectAtIndex:[indexPath row]];
    VBCardViewController *cvc = [[VBCardViewController alloc] init];
    
    [cvc setWord:word]; 
    
    [self.navigationController pushViewController:cvc animated:YES];
}

@end
