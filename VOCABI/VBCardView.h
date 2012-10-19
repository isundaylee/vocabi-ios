//
//  VBCardView.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VBWord;

@interface VBCardView : UIWebView
{
}

@property (nonatomic) VBWord *word;


- (void)reload; 

@end
