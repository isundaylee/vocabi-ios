//
//  VBTextFieldCell.m
//  VOCABI
//
//  Created by Jiahao Li on 10/20/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBTextFieldCell.h"

@implementation VBTextFieldCell

@synthesize titleLabel = _titleLabel;
@synthesize editField = _editField; 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
