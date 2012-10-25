//
//  VBWordRateCategory.h
//  VOCABI
//
//  Created by Jiahao Li on 10/23/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBWordRateStore.h"
#import "VBWordListing.h"

@interface VBWordRateCategory : NSObject <VBWordListing>

- initWithRate:(VBWordRate)rate; 

@end
