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
@synthesize individualUpdate    = _individualUpdate;
@synthesize isFavoriteStop      = _isFavoriteStop;

- (id)init
{
    self = [super init];
    if(self)
    {
        _state = CCM_EMPTY;
        _status = CMS_IDLE;
        _hasAnimated = NO;
        _isAnimating = NO;
        _individualUpdate = NO;
        _isFavoriteStop = NO;
        
        _busNumber = @"";
        _stopStreetName = @"";
        _busHeadingDisplay = @"";
        
        _busSpeed = MTDEF_STOPDISTANCEUNKNOWN;
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
    _busSpeed = _stop.Bus.BusSpeed;
    
    _state = CCM_FULL;
    _status = CMS_NEWUPDATE;
}

- (void)updateDisplayObjectsForStop:(NSArray*)stopTimes
{
    if(_stop.isUpdating)
        return;
    
    _stopStreetName = _stop.StopNameDisplay;
    _distance = [_stop getDistanceOfStop];
    
    NSMutableString *upcomingBuses = [[NSMutableString alloc] init];
    for(MTTime* stop in stopTimes)
    {
        [upcomingBuses appendFormat:@"%@   ", stop.routeNumber];
    }
    
    if(upcomingBuses.length <= 0)
        [upcomingBuses appendString:NSLocalizedString(@"NOUPCOMINGBUSES", nil)];
    else {
        [upcomingBuses insertString:NSLocalizedString(@"UPCOMINGBUSES", nil) atIndex:0];
    }
    
    _busHeadingDisplay = upcomingBuses;
    
#if 0
    if(stopTimes == nil)
        return;
    
    if(stopTimes.count > 0)
        _nextTime = (MTTime*)[stopTimes objectAtIndex:0];
    
    if(stopTimes.count >= 1)
    {
        int max = stopTimes.count; //we add the first one to mimic the same functionality as MTBus times
        int inc = 0;
        
        if(max < 2)
            inc = max;
        else inc = 2;
        
        _additionalNextTimes = [stopTimes subarrayWithRange:NSMakeRange(0, inc)];
    }
#endif
    
    _state = CCM_EMPTY; //keep stop favorites on empty for now so not to rearange all the icons below the card cell
    _status = CMS_NEWUPDATE;
}

@end
