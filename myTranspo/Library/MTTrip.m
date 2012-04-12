//
//  MTTrip.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTTrip.h"


@implementation MTTrip

@synthesize StopId                  = _stopId;
@synthesize StopNumber              = _stopNumber;
@synthesize Longitude               = _stopLongitude;
@synthesize Latitude                = _stopLatitude;
@synthesize StopName                = _stopName;
@synthesize Language                = _language;
@synthesize TripId                  = _tripId;
@synthesize StopSequence            = _stopSequence;
@synthesize Time                    = _time;

@synthesize BusSpeed        = _busSpeed;
@synthesize Destination     = _destination;
@synthesize BusType         = _busType;
@synthesize LastTrip        = _lastTrip;
@synthesize StartTime       = _startTime;

- (id)initWithLanguage:(MTLanguage)lang
{
    self = [super init];
    if(self)
    {
        _language = lang;
        _stopId = @"";
        _stopNumber = -1;
        _stopLatitude = 0.0;
        _stopLongitude = 0.0;
        _stopName = @"";
        _tripId = @"";
        _stopSequence = -1;
        _time = [[MTTime alloc] init];
    }
    
    return self;
}

#pragma mark - GETTERS & SETTERS

- (NSString*)StopName
{
    if(_stopName == nil)
        return @"";
    return _stopName;
}

@end
