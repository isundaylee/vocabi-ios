//
//  VBSearchViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UISearchBar *_searchBar; 
    IBOutlet UISearchDisplayController *_searchController;
    
    NSMutableArray *_filteredWords;
}

@end
