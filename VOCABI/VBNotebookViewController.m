//
//  VBNotebookViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBNotebookViewController.h"
#import "VBCardViewController.h"
#import "VBCarouselViewController.h"
#import "VBWordStore.h"
#import "VBWord.h"

@interface VBNotebookViewController ()

@end

@implementation VBNotebookViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"Notebook";
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showCards:)];
        self.navigationItem.rightBarButtonItem = bbi;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [self.navigationItem.rightBarButtonItem setEnabled:[[[VBWordStore sharedStore] notedWords] count] > 0]; 
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
    return [[[VBWordStore sharedStore] notedWords] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *uid = [[[VBWordStore sharedStore] notedWords] objectAtIndex:[indexPath row]];
    VBWord *word = [[VBWordStore sharedStore] wordWithUID:uid];
    
    [[cell textLabel] setText:[word word]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *uid = [[[VBWordStore sharedStore] notedWords] objectAtIndex:[indexPath row]];
    VBWord *word = [[VBWordStore sharedStore] wordWithUID:uid];
    VBCardViewController *cvc = [[VBCardViewController alloc] init];
    [cvc setWord:word];
    
    [self.navigationController pushViewController:cvc animated:YES]; 
}

- (void)showCards:(id)sender
{
    NSMutableArray *words = [NSMutableArray array];
    NSMutableArray *uids = [[VBWordStore sharedStore] notedWords];
    for (NSString *uid in uids) {
        [words addObject:[[VBWordStore sharedStore] wordWithUID:uid]];
    }
    VBCarouselViewController *cvc = [[VBCarouselViewController alloc] initWithWords:words];
    [self.navigationController pushViewController:cvc animated:YES]; 
}

@end
