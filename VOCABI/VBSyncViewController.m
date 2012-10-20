//
//  VBSyncViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/19/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBSyncViewController.h"
#import "VBWordStore.h"
#import "VBTextFieldCell.h"

NSString * const VBNotebookPasscodePrefKey = @"VBNotebookPasscodePrefKey"; 

@interface VBSyncViewController ()
{
    __weak IBOutlet UITextField *_passcodeField;
    
    IBOutlet UIView *_headerView;
    IBOutlet UIView *_footerView;
}

@end

@implementation VBSyncViewController

- (UIView *)footerView;
{
    if (!_footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"VBSyncViewCellHeaderFooter" owner:self options:nil];
    }
    
    return _footerView; 
}

- (UIView *)headerView
{
    if (!_headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"VBSyncViewCellHeaderFooter" owner:self options:nil];
    }
    
    return _headerView; 
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.navigationItem.title = @"Sync";
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

- (UITextField *)passcodeField
{
    VBTextFieldCell *cell = (VBTextFieldCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *field = [cell editField];
    return field;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"VBTextFieldCell" bundle:nil] forCellReuseIdentifier:@"VBTextFieldCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self passcodeField] setText:[[NSUserDefaults standardUserDefaults] objectForKey:VBNotebookPasscodePrefKey]]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//    _passcodeField = nil;
    [super viewDidUnload];
}

- (IBAction)uploadNotebook:(id)sender {
    VBWordStore *store = [VBWordStore sharedStore];
    NSString *passcode = [[self passcodeField] text];
    
    [store uploadNotebookWithPasscode:passcode onCompletion:^(NSString *passcode, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            [[self passcodeField] setText:passcode];
            [self passcodeChanged:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Succeeded" message:@"The notebook has been uploaded to the server. Your passcode is shown in the 'Sync' tab. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show]; 
        }
    }];
}

- (IBAction)downloadNotebook:(id)sender {
    VBWordStore *store = [VBWordStore sharedStore];
    NSString *passcode = [[self passcodeField] text];
    
    [store downloadNotebookWithPasscode:passcode onCompletion:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Succeeded" message:@"Your notebook has been downloaded from the server. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)passcodeChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[[self passcodeField] text] forKey:VBNotebookPasscodePrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"VBTextFieldCell";
    VBTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        NSLog(@"Warning: Should never happen. "); 
    }
    
    [[cell titleLabel] setText:@"Passcode"];
    [[cell editField] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeChanged:) name:UITextFieldTextDidChangeNotification object:[cell editField]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self footerView].bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView]; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self headerView].bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView]; 
}

@end
