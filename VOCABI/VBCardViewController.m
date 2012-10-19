//
//  VBCardViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBCardViewController.h"
#import "VBCardView.h"
#import "VBWordStore.h"
#import "VBWord.h"

@interface VBCardViewController ()

@end

@implementation VBCardViewController

@synthesize word = _word;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Note" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleNoteWord:)];
        self.navigationItem.rightBarButtonItem = bbi; 
    }
    return self;
}

- (void)loadView
{
    VBCardView *cv = [[VBCardView alloc] init];
    [cv setWord:[self word]];
    [self setView:cv];
}

- (void)setWord:(VBWord *)word
{
    _word = word;
    VBCardView *v = (VBCardView *)[self view];
    [v setWord:word];
    if ([[VBWordStore sharedStore] isNoted:word]) [self.navigationItem.rightBarButtonItem setTitle:@"Unnote"];
    else [self.navigationItem.rightBarButtonItem setTitle:@"Note"]; 
    self.navigationItem.title = [word word]; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)toggleNoteWord:(id)sender
{
    VBWordStore *store = [VBWordStore sharedStore];
    if ([store isNoted:[self word]]) [store unnoteWord:[self word]];
    else [store noteWord:[self word]];
    [self setWord:[self word]]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
