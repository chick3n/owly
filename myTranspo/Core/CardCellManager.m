//
//  CardCellManager.m
//  myTranspo
//
//  Created by Lion User on 09/05/2012.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "CardCellManager.h"

@implementation CardCellManager
@synthesize state               = _state;
@synthesize status              = _status;
@synthesize stop                = _stop;
@synthesize busNumber           = _busNumber;
@synthesize hasAnimated         = _hasAnimated;
@synthesize isAnimating         = _isAnimating;
@synthesize stopStreetName      = _stopStreetName;
@synthesize busHeadingDisplay   = _busHeadingDisplay;
@synthesize prevTime            = _prevTime;
@synthesize distance            = _distance;
@synthesize heading             = _heading;
@synthesize nextTime            = _nextTime;
@synthesize additionalNextTimes = _additionalNextTimes;
@synthesize busSpeed            = _busSpeed;

- (id)init
{
    self = [super init];
    if(self)
    {
        _state = CCM_EMPTY;
        _status = CMS_IDLE;
        _hasAnimated = NO;
        _isAnimating = NO;
        
        _busNumber = @"";
        _stopStreetName = @"";
        _busHeadingDisplay = @"";
    }
    return self;
}

- (void)updateDisplayObjects
{
    if(_stop.isUpdating) 
    {
        //ToDo: Add Timer here to keep trying untill done updatingg
        return;
    }
    
    [_stop.Bus updateDisplayObjects];
    
    _busNumber = _stop.Bus.BusNumberDisplay;
    _busHeadingDisplay = _stop.Bus.DisplayHeading;
    _stopStreetName = _stop.StopNameDisplay;
    
    _prevTime = _stop.Bus.PrevTimeDisplay;
    _distance = [_stop getDistanceOfStop];
    _heading = [_stop.Bus getBusHeadingShortForm];
    _nextTime = _stop.Bus.NextTimeDisplay;
    _additionalNextTimes = _stop.Bus.NextThreeTimesDisplay;
    
    _state = CCM_FULL;
    _status = CMS_IDLE;
}

@end
