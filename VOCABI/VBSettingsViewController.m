//
//  VBSyncViewController.m
//  VOCABI
//
//  Created by Jiahao Li on 10/19/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBSettingsViewController.h"
#import "VBWordStore.h"
#import "VBWordRateStore.h"
#import "VBAppDelegate.h"

NSString * const VBNotebookPasscodePrefKey = @"VBNotebookPasscodePrefKey";

NSInteger const VBTextFieldCellTextFieldTag = 52; 

@interface VBSettingsViewController ()
{
}

@property (nonatomic, getter = isDownloading) BOOL downloading;
@property (nonatomic, getter = isUploading) BOOL uploading;
@property (nonatomic, getter =  isActivating) BOOL activating;

@end

@implementation VBSettingsViewController

@synthesize uploadable = _uploadable;
@synthesize downloadable = _downloadable;
@synthesize uploading = _uploading;
@synthesize downloading = _downloading;

@synthesize activatable = _activatable; 
@synthesize activating = _activating;

- (void)setUploadable:(BOOL)uploadable
{
    _uploadable = uploadable;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setUploading:(BOOL)uploading
{
    _uploading = uploading;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setDownloadable:(BOOL)downloadable
{
    _downloadable = downloadable; 
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setDownloading:(BOOL)downloading
{
    _downloading = downloading; 
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setActivatable:(BOOL)activatable
{
    _activatable = activatable;
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:2];
    if ([self.tableView cellForRowAtIndexPath:path])
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setActivating:(BOOL)activating
{
    _activating = activating;
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:2];
    if ([self.tableView cellForRowAtIndexPath:path])
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Settings", nil);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        _downloadable = YES;
        _uploadable = YES;
        _activatable = YES; 
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:VBTextFieldCellTextFieldTag];
    return field;
}

- (UITextField *)activationKeyField
{
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:VBTextFieldCellTextFieldTag];
    return field;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [super viewDidUnload];
}

- (IBAction)uploadNotebook:(id)sender {
    VBWordRateStore *rateStore = [VBWordRateStore sharedStore];
    NSString *passcode = [[self passcodeField] text];
    
    [self setUploadable:NO];
    [self setUploading:YES];
    
    [rateStore uploadWordRatesWithPasscode:passcode onCompletion:^(NSString *passcode, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SyncFailed", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        } else {
            [[self passcodeField] setText:passcode];
            [self passcodeChanged]; 
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SyncSucceeded", nil) message:NSLocalizedString(@"SyncSucceededUploadMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show]; 
        }
        [self setUploading:NO];
        [self setUploadable:YES]; 
    }];
}

- (IBAction)downloadNotebook:(id)sender {
    VBWordRateStore *rateStore = [VBWordRateStore sharedStore];
    NSString *passcode = [[self passcodeField] text];
    
    [self setDownloadable:NO];
    [self setDownloading:YES]; 
    
    [rateStore downloadWordRatesWithPasscode:passcode onCompletion:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SyncFailed", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SyncSucceeded", nil) message:NSLocalizedString(@"SyncSucceededDownloadMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            NSInteger purged = [rateStore purgeWordRates];
            if (purged > 0) {
                NSString *message;
                if (purged == 1) {
                    message = [NSString stringWithFormat:NSLocalizedString(@"NotebookChangedMessageSingle", nil), purged];
                } else {
                    message = [NSString stringWithFormat:NSLocalizedString(@"NotebookChangedMessagePlural", nil), purged];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NotebookChanged", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
            NSLog(@"Info: %d item(s) purged after notebook sync. ", purged);
            [alert show];
        }
        
        [self setDownloadable:YES];
        [self setDownloading:NO];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)passcodeChanged {
    [[NSUserDefaults standardUserDefaults] setObject:[[self passcodeField] text] forKey:VBNotebookPasscodePrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)textFieldChanged:(NSNotification *)note {
    if (note.object == [self passcodeField]) {
        [self passcodeChanged];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[VBWordStore sharedStore] isActivated]) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 2;
    }
}

- (UITableViewCell *)getTextFieldCellWithTableView:(UITableView *)tableView
{
    NSString *cellIdentifier = @"VBTextFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        CGRect rect;
        if (IS_IPAD) {
            rect = CGRectMake(120, 12, 540, 30);
        } else {
            rect = CGRectMake(120, 12, 170, 30);
        }
        UITextField *textField = [[UITextField alloc] initWithFrame:rect];
        [textField setTag:VBTextFieldCellTextFieldTag];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setDelegate:self];
        [cell.contentView addSubview:textField];
    }
    
    return cell; 
}

- (UITableViewCell *)getButtonCellWithTableView:(UITableView *)tableView
{
    NSString *cellIdentifier = @"VBButtonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

- (UIColor *)tableViewCellTextColor
{
    return [UIColor blackColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *cell = [self getTextFieldCellWithTableView:tableView];
        cell.textLabel.text = NSLocalizedString(@"Passcode", nil); 
        return cell;
    } else if ([indexPath section] == 1) {
        UITableViewCell *cell = [self getButtonCellWithTableView:tableView];
        if ([indexPath row] == 0) {
            if (!self.uploading) {
                cell.textLabel.text = NSLocalizedString(@"Upload", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Uploading", nil);
                NSLog(@"%@", NSLocalizedString(@"Uploading", nil));
            }
            
            if (self.uploadable) {
                [cell.textLabel setTextColor:[self tableViewCellTextColor]];
            } else {
                [cell.textLabel setTextColor:[UIColor grayColor]];
            }
        } else {
            if (!self.downloading) {
                cell.textLabel.text = NSLocalizedString(@"Download", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Downloading", nil);
            }
            
            if (self.downloadable) {
                [cell.textLabel setTextColor:[self tableViewCellTextColor]];
            } else {
                [cell.textLabel setTextColor:[UIColor grayColor]];
            }
        }
        
        return cell;
    } else {
        if ([indexPath row] == 0) {
            UITableViewCell *cell = [self getTextFieldCellWithTableView:tableView];
            cell.textLabel.text = NSLocalizedString(@"ActivationKey", nil);
            return cell; 
        } else {
            UITableViewCell *cell = [self getButtonCellWithTableView:tableView];
            if (self.activating) {
                cell.textLabel.text = NSLocalizedString(@"Activating", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Activate", nil);
            }
            
            if (self.activatable) {
                [cell.textLabel setTextColor:[self tableViewCellTextColor]];
            } else {
                [cell.textLabel setTextColor:[UIColor grayColor]];
            }
            
            return cell; 
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0 && !self.uploading) {
            [self uploadNotebook:nil];
        } else if ([indexPath row] == 1 && !self.downloading) {
            [self downloadNotebook:nil];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO]; 
    } else {
        if ([indexPath row] == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        } else {
            if (self.activatable)
                [self activate];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

- (void)activate
{
    NSString *activationKey = [[self activationKeyField] text];
    if (activationKey == nil) activationKey = @""; 
    VBWordStore *store = [VBWordStore sharedStore];
    
    [self setActivatable:NO];
    [self setActivating:YES]; 
    
    [store activateWithKey:activationKey onCompletion:^(BOOL activated, NSError *error) {
        if (activated) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ActivationSucceeded", nil) message:NSLocalizedString(@"ActivationSucceededMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            VBAppDelegate *appDelegate = (VBAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate setExitOnSuspend:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ActivationFailed", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        
        [self.tableView reloadData]; 
        [self setActivatable:YES];
        [self setActivating:NO]; 
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"SyncNotebookWithServer", nil);
    } else if (section == 1) {
        return @""; 
    } else {
        return NSLocalizedString(@"ActivateAllWordlists", nil); 
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    } else if (section == 1) {
        return NSLocalizedString(@"BlankPasscodeFirstTimeSync", nil);
    } else {
        return NSLocalizedString(@"ActivationKeySuppliedInBook", nil);
    }
}

@end
