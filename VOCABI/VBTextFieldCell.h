//
//  VBTextFieldCell.h
//  VOCABI
//
//  Created by Jiahao Li on 10/20/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBTextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *editField;

@end
