//
//  VBCarouselViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface VBCarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (nonatomic, copy) NSArray *words;

- (id)initWithWords:(NSArray *)words;
- (UIBarButtonItem *)rateButton;
- (void)reload;

@end
