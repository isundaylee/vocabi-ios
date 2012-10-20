//
//  VBCarouselViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBCarouselViewController.h"
#import "VBCardView.h"
#import "VBWordStore.h"

@interface VBCarouselViewController ()
{
    NSMutableArray *_words; 
}

@end

@implementation VBCarouselViewController

@synthesize carousel = _carousel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithWords:[NSArray array]];
}

- (id) initWithWords:(NSArray *)words
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _words = [words mutableCopy];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Note" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleNoteWord:)];
        self.navigationItem.rightBarButtonItem = bbi;
    }
    
    return self; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self carousel].type = iCarouselTypeLinear;
    [self carousel].bounceDistance = 0.1;
    [self carousel].scrollSpeed = 0.3;
    [self carousel].decelerationRate = 0.1; 
}

- (void)viewDidUnload
{
    [self setCarousel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_words count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        CGRect rect = [[self view] bounds];
        view = [[VBCardView alloc] initWithFrame:rect];
    }
    
    VBCardView *cardView = (VBCardView *)view;
    [cardView setWord:[_words objectAtIndex:index]];

    return cardView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    self.navigationItem.title = [NSString stringWithFormat:@"%d/%d", [carousel currentItemIndex] + 1, [_words count]];
    VBCardView *view = (VBCardView *)[[self carousel] currentItemView];
    VBWord *word = [view word];
    VBWordStore *store = [VBWordStore sharedStore];
    if ([store isNoted:word]) self.navigationItem.rightBarButtonItem.title = @"Unnote";
    else self.navigationItem.rightBarButtonItem.title = @"Note";
}

- (void)toggleNoteWord:(id)sender
{
    VBCardView *view = (VBCardView *)[[self carousel] currentItemView];
    VBWord *word = [view word];
    VBWordStore *store = [VBWordStore sharedStore];
    if ([store isNoted:word]) [store unnoteWord:word];
    else [store noteWord:word];
    [self carouselDidEndScrollingAnimation:[self carousel]]; 
}

@end
