//
//  VBWordsSplitViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/21/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordsSplitViewController.h"
#import "VBWordsViewController.h"
#import "VBCardViewController.h"
#import "VBCarouselViewController.h"
#import "VBWordlist.h"
#import "VBWordlisting.h"

@interface VBWordsSplitViewController ()

@end

@implementation VBWordsSplitViewController

@synthesize wordlist = _wordlist;
@synthesize wordsViewController = _wordsViewController;
@synthesize cardViewController = _cardViewController;

- (void)setWordlist:(id<VBWordlisting>)wordlist
{
    _wordlist = wordlist;
    [self.wordsViewController setWordlist:wordlist];
    [self.cardViewController setWord:nil];
    self.navigationItem.title = [self.wordlist listTitle];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)showCards:(id)sender
{
    VBCarouselViewController *cvc = [[VBCarouselViewController alloc] initWithWords:[[self wordlist] orderedWords]];
    
    [self.navigationController pushViewController:cvc animated:YES];
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _wordsViewController = [[VBWordsViewController alloc] init];
        _cardViewController = [[VBCardViewController alloc] init];
        _wordsViewController.cardViewController = _cardViewController;
//        self.navigationItem.rightBarButtonItem = _cardViewController.noteButton;
//        self.navigationItem.leftBarButtonItem = _wordsViewController.showCardsButton;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_cardViewController.noteButton, _wordsViewController.showCardsButton, nil];
        [_wordsViewController.showCardsButton setTarget:self];
        [_wordsViewController.showCardsButton setAction:@selector(showCards:)];
        [_wordsViewController setDisclosing:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    [self.view addSubview:self.cardViewController.view];
    [self.view addSubview:self.wordsViewController.view];
}

- (void)adjustViews
{
    CGPoint origin = self.view.frame.origin;
    CGSize size = self.view.frame.size;
    CGFloat sideWidth = 200;
    [self.wordsViewController.view setFrame:CGRectMake(origin.x, origin.y, sideWidth, size.height)];
    [self.cardViewController.view setFrame:CGRectMake(sideWidth, origin.y, size.width - sideWidth, size.height)];
    [self.cardViewController reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self adjustViews];
    [self.wordsViewController viewWillAppear:animated];
    [self.cardViewController viewWillAppear:animated]; 
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustViews]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
