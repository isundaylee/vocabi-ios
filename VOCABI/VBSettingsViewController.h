//
//  VBSyncViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/19/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBSettingsViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, getter = isUploadable) BOOL uploadable;
@property (nonatomic, getter = isDownloadable) BOOL downloadable;
@property (nonatomic, readonly, getter = isUploading) BOOL uploading;
@property (nonatomic, readonly, getter = isDownloading) BOOL downloading;

@property (nonatomic, getter = isActivatable) BOOL activatable;
@property (nonatomic, readonly, getter =  isActivating) BOOL activating;

@end
