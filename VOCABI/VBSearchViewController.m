//
//  VBSearchViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBSearchViewController.h"
#import "VBCardViewController.h"
#import "VBWordStore.h"
#import "VBWord.h"

@interface VBSearchViewController ()

@end

@implementation VBSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _filteredWords = [[VBWordStore sharedStore] allWords];
        self.navigationItem.title = NSLocalizedString(@"Search", nil);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filteredWords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    VBWord *word = (VBWord *)[_filteredWords objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[word word]];
    
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBWord *word = (VBWord *)[_filteredWords objectAtIndex:[indexPath row]];
    VBCardViewController *cvc = [[VBCardViewController alloc] init];
    
    [cvc setWord:word];
    
    [self.navigationController pushViewController:cvc animated:YES]; 
}

- (void)refilter
{
    NSString *searchString = [_searchController.searchBar text];
    
    NSMutableArray *all = [[VBWordStore sharedStore] allWords];
    [_filteredWords removeAllObjects];
    
    for (VBWord *word in all) {
        NSComparisonResult result = [[word word] compare:searchString options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame)
        {
            [_filteredWords addObject:word];
        }
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self refilter];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _filteredWords = [[VBWordStore sharedStore] allWords]; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    _tableView = nil;
    _searchBar = nil;
    _searchController = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
