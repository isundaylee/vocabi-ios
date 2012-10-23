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
#import "VBRateViewController.h"
#import "VBWord.h"

@interface VBCarouselViewController ()
{
    NSArray *_words;
}

@property (nonatomic) VBRateViewController *rateViewController;
@property (nonatomic) UIPopoverController *rateViewPopoverController;

@end

@implementation VBCarouselViewController

@synthesize carousel = _carousel;
@synthesize words = _words;
@synthesize rateViewController = _rateViewController;
@synthesize rateViewPopoverController = _rateViewPopoverController;

- (id)initWithWords:(NSArray *)words
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _words = [words copy];
        _rateViewController = [[VBRateViewController alloc] init];
        [_rateViewController setDelegate:self]; 
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Note", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(rateWord:)];
        self.navigationItem.rightBarButtonItem = bbi;
    }
    return self;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self carouselDidEndScrollingAnimation:self.carousel];
//}

- (void)rateViewControllerDidRateWord:(VBRateViewController *)rateViewController
{
    
    
    if (IS_IPAD) {
        [self.rateViewPopoverController dismissPopoverAnimated:YES];
        [self setRateViewPopoverController:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self carouselDidEndScrollingAnimation:self.carousel];
}

- (void)rateWord:(id)sender
{
    if (IS_IPAD) {
        if ([self.rateViewPopoverController isPopoverVisible]) {
            [self.rateViewPopoverController dismissPopoverAnimated:YES];
            self.rateViewPopoverController = nil;
        } else {
            self.rateViewPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.rateViewController];
            [self.rateViewPopoverController setDelegate:self];
            [self.rateViewPopoverController presentPopoverFromBarButtonItem:[self rateButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self.navigationController pushViewController:self.rateViewController animated:YES]; 
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.rateViewPopoverController = nil; 
}

- (id)init
{
    return [self initWithWords:[NSArray array]];
}

- (void)setWords:(NSArray *)words
{
    _words = [words copy];
    [self.carousel reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithWords:[NSArray array]];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.carousel reloadData]; 
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
    id word = [self.words objectAtIndex:index];
    if (word == [NSNull null]) word = nil;
    [cardView setWord:word];

    return cardView;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    self.navigationItem.title = [NSString stringWithFormat:@"%d/%d", [carousel currentItemIndex] + 1, [self.words count]];
    VBCardView *view = (VBCardView *)[[self carousel] currentItemView];
    VBWord *word = [view word];
    VBWordRateStore *rateStore = [VBWordRateStore sharedStore];
    [self.navigationItem.rightBarButtonItem setTitle:[[VBWordRateStore sharedStore] descriptionForWordRate:[rateStore rateForWord:word]]];
    [self.rateViewController setWord:word];
    [self.rateButton setEnabled:(word != nil)];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) {
        return 1;
    } else {
        return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return self.view.bounds.size.width; 
}

- (void)reload
{
    [self.carousel reloadData]; 
}

- (UIBarButtonItem *)rateButton
{
    return self.navigationItem.rightBarButtonItem; 
}

@end
