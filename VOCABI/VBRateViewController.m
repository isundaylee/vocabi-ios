//
//  VBRateViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/22/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBRateViewController.h"
#import "VBWord.h"

@interface VBRateViewController ()

@end

@implementation VBRateViewController

@synthesize word = _word;
@synthesize didRateBlock = _didRateBlock;

- (void)setWord:(VBWord *)word
{
    _word = word;
    self.navigationItem.title = word.word;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self setContentSizeForViewInPopover:CGSizeMake(200, 180)];
    }
    return self;
}

- (void)loadView
{
    [super loadView]; 
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:[[VBWordRateStore sharedStore] descriptionForWordRate:[indexPath row]]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VBWordRatesNumber;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBWordRateStore *rateStore = [VBWordRateStore sharedStore];
    
    [rateStore setRate:[indexPath row] forWord:self.word];

//    [self.delegate rateViewControllerDidRateWord:self];
    if (self.didRateBlock) {
        NSLog(@"Calling"); 
        self.didRateBlock(self);
    }
}

@end
