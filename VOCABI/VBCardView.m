//
//  VBCardView.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBCardView.h"
#import "VBWord.h"

@implementation VBCardView

@synthesize word = _word; 

- (void)setWord:(VBWord *)word
{
    _word = word;
    [self reload];
}

// @synthesize word = _word;

- (NSString *)templateHTML
{
    NSString *htmlFilename = @"";
    if (IS_IPAD)
        htmlFilename = @"cardview~ipad.html";
    else
        htmlFilename = @"cardview.html";
    NSData *data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:htmlFilename]];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (void)reload
{
    NSString *HTML = [self templateHTML];
    HTML = [HTML stringByReplacingOccurrencesOfString:@"#word#" withString:[[self word] word]];
    HTML = [HTML stringByReplacingOccurrencesOfString:@"#ps#" withString:[[self word] ps]];
    NSString *tmp = [[[self word] meaning] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    HTML = [HTML stringByReplacingOccurrencesOfString:@"#meaning#" withString:tmp];
    HTML = [HTML stringByReplacingOccurrencesOfString:@"#desc#" withString:[[self word] desc]];
    NSArray *samples = [[[self word] sample] componentsSeparatedByString:@"\n"];
    tmp = @"<ol>";
    for (NSString *sample in samples) {
        NSString *word = [[self word] word];
        if ([sample characterAtIndex:0] == '~') word = [word capitalizedString];
        NSString *modifiedSample = [sample stringByReplacingOccurrencesOfString:@"~" withString:[NSString stringWithFormat:@"<b>%@</b>", word]];
        tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@"<li>%@</li>", modifiedSample]];
    }
    tmp = [tmp stringByAppendingString:@"</ol>"];
    HTML = [HTML stringByReplacingOccurrencesOfString:@"#sample#" withString:tmp]; 
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] resourcePath]];
    [self loadHTMLString:HTML baseURL:url];
    [self setNeedsDisplay]; 
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[self scrollView] setScrollEnabled:NO]; 
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
