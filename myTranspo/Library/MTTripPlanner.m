//
//  MTTripPlanner.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTTripPlanner.h"

@implementation MTTripPlanner
@synthesize city                    = _city;
@synthesize arriveBy                = _arriveBy;
@synthesize language                = _language;
@synthesize endingLocation          = _endingLocation;
@synthesize startingLocation        = _startingLocation;
@synthesize departBy                = _departBy;

//OCTranspo Specific
@synthesize bikeRack                = _bikeRack;
@synthesize accessible              = _accessible;
@synthesize excludeSTO              = _excludeSTO;
@synthesize regulareFare            = _regulareFare;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _bikeRack = NO;
        _accessible = NO;
        _excludeSTO = NO;
        _regulareFare = NO;
    }
    
    return self;
}

@end
