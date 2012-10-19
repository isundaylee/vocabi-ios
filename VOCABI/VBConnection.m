//
//  VBConnection.m
//  VOCABI
//
//  Created by Jiahao Li on 10/18/12.
//  Copyright (c) 2012 Jiahao Li. All rights reserved.
//

#import "VBConnection.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation VBConnection

@synthesize request = _request;
@synthesize completionBlock = _completionBlock;

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    
    if (self) {
        [self setRequest:request];
    }
    
    return self;
}

- (void)start
{
    _data = [[NSMutableData alloc] init];
    
    _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
    
    [sharedConnectionList addObject:self]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
    
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.completionBlock) {
        self.completionBlock(_data, nil);
    }
    
    [sharedConnectionList removeObject:self]; 
}

@end
