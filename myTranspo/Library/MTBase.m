//
//  MTBase.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-24.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBase.h"

@implementation MTBase
@synthesize cancelQueue         = _cancelQueue;
@synthesize isUpdating          = _isUpdating;
@synthesize isFavorite          = _isFavorite;

- (id)init
{
    self = [super init];
    if(self)
    {
        _cancelQueue = NO;
        _isUpdating = NO;
        _isFavorite = NO;
    }
    return self;
}

@end
