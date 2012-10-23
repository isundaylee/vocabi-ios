//
//  VBWordsSplitViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/21/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBWordsSplitViewController.h"
#import "VBWordsViewController.h"
#import "VBCarouselViewController.h"
#import "VBWordlist.h"
#import "VBWordlisting.h"
#import "VBWordRateStore.h"

@interface VBWordsSplitViewController ()

@end

@implementation VBWordsSplitViewController

@synthesize wordlist = _wordlist;
@synthesize wordsViewController = _wordsViewController;
@synthesize carouselViewController = _carouselViewController;

- (void)wordsViewController:(VBWordsViewController *)controller didSelectWordWithIndex:(NSInteger)index
{
    // [self.carouselViewController setWords:[NSArray arrayWithObject:[[self.wordlist orderedWords] objectAtIndex:index]]];
}

- (void)setWordlist:(id<VBWordListing>)wordlist
{
    _wordlist = wordlist;
    [self.wordsViewController setWordlist:wordlist];
    [self.wordsViewController setDelegate:self]; 
    [self.carouselViewController setWords:[NSArray arrayWithObject:[NSNull null]]];
    [[self.carouselViewController rateButton] setEnabled:NO]; 
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
        _carouselViewController = [[VBCarouselViewController alloc] init];
        _wordsViewController.carouselViewController = _carouselViewController;
//        self.navigationItem.rightBarButtonItem = _cardViewController.noteButton;
//        self.navigationItem.leftBarButtonItem = _wordsViewController.showCardsButton;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_carouselViewController.rateButton, _wordsViewController.showCardsButton, nil];
        [_wordsViewController.showCardsButton setTarget:self];
        [_wordsViewController.showCardsButton setAction:@selector(showCards:)];
        [_wordsViewController setDisclosing:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordRatesChanged) name:VBWordRatesDidChangeNotification object:[VBWordRateStore sharedStore]];
        
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
    [self.view addSubview:self.carouselViewController.view];
    [self.view addSubview:self.wordsViewController.view];
}

- (void)adjustViews
{
    CGPoint origin = self.view.frame.origin;
    CGSize size = self.view.frame.size;
    CGFloat sideWidth = 200;
    [self.wordsViewController.view setFrame:CGRectMake(origin.x, origin.y, sideWidth, size.height)];
    [self.carouselViewController.view setFrame:CGRectMake(sideWidth, origin.y, size.width - sideWidth, size.height)];
    [self.carouselViewController reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self adjustViews];
    [self.wordsViewController viewWillAppear:animated];
    [self.carouselViewController viewWillAppear:animated];
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

- (void)reload
{
    [self.wordsViewController reload];
    [self.carouselViewController setWords:[NSArray arrayWithObject:[NSNull null]]]; 
}

- (void)wordRatesChanged
{
    [self.wordsViewController reloadSelectedWordAnimated:NO];
}

@end
