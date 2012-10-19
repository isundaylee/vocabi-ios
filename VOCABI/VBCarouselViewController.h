//
//  VBCarouselViewController.h
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface VBCarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>
{
    NSMutableArray *_words;
}

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

- (id)initWithWords:(NSArray *)words;

@end
