//
//  MTBus.m
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBus.h"

@implementation MTBus

@synthesize BusId                       = _busId;
@synthesize BusNumber                   = _busNumber; 
@synthesize BusHeading                  = _busHeading;
@synthesize DisplayHeading              = _busDisplayHeading;
@synthesize GPSTime                     = _hasGpsTime;
@synthesize StopIds                     = _stopIds;
@synthesize Language                    = _language;
@synthesize Times                       = _times;
@synthesize chosenDate                  = _chosenDate;

- (id)init
{
    self = [super init];
    
    if (self) {
        _busId = @"";
        _busNumber = @"";
        _busHeading = MTDIRECTION_UNKNOWN;
        _busDisplayHeading = NSLocalizedString(@"MTDEF_BUSNAMEUNKNOWN", nil); 
        _hasGpsTime = NO;
        _stopIds = [[NSMutableArray alloc] init];
        _language = MTLANGUAGE_ENGLISH;
        _times = [[MTTimes alloc] init];
        _liveTimes = [[MTTimeLive alloc] init];
        _chosenDate = [NSDate date];
    }
    
    return self;
}

- (id)initWithLanguage:(MTLanguage)lang
{
    self = [super init];
    
    if (self) {
        _busId = @"";
        _busNumber = @"";
        _busHeading = MTDIRECTION_UNKNOWN;
        _busDisplayHeading = NSLocalizedString(@"MTDEF_BUSNAMEUNKNOWN", nil);
        _hasGpsTime = NO;
        _stopIds = [[NSMutableArray alloc] init];
        _language = lang;
        _times = [[MTTimes alloc] init];
        _liveTimes = [[MTTimeLive alloc] init];
        _chosenDate = [NSDate date];
    }
    
    return self;
}

- (BOOL)clearLiveTimes
{
    _hasGpsTime = NO;
    _liveTimes.LastUpdated = nil;
    _liveTimes.Times = nil;
    return YES;
}

- (BOOL)addLiveTimes:(NSArray*)times
{
    [self clearLiveTimes];
    
    _liveTimes.Times = times;
    _liveTimes.LastUpdated = [NSDate date];
    _hasGpsTime = YES;
    
    return YES;
}

#pragma mark - UI HELPER METHODS

- (NSString *)getBusHeading
{
    switch(_busHeading)
    {
        case MTDIRECTION_EAST:
            return NSLocalizedString(@"MTDEF_DIRECTIONEAST", nil);
        case MTDIRECTION_SOUTH:
            return NSLocalizedString(@"MTDEF_DIRECTIONSOUTH", nil);
        case MTDIRECTION_WEST:
            return NSLocalizedString(@"MTDEF_DIRECTIONWEST", nil);
        case MTDIRECTION_NORTH:
            return NSLocalizedString(@"MTDEF_DIRECTIONNORTH", nil);
        case MTDIRECTION_UNKNOWN:
            return NSLocalizedString(@"MTDEF_DIRECTIONUNKNOWN", nil);
    }
    
    return NSLocalizedString(@"MTDEF_DIRECTIONUNKNOWN", nil);
}

- (NSString *)getBusHeadingShortForm
{
    switch(_busHeading)
    {
        case MTDIRECTION_EAST:
            return [NSLocalizedString(@"MTDEF_DIRECTIONEAST", nil) substringToIndex:1];
        case MTDIRECTION_SOUTH:
            return [NSLocalizedString(@"MTDEF_DIRECTIONSOUTH", nil) substringToIndex:1];
        case MTDIRECTION_WEST:
            return [NSLocalizedString(@"MTDEF_DIRECTIONWEST", nil) substringToIndex:1];
        case MTDIRECTION_NORTH:
            return [NSLocalizedString(@"MTDEF_DIRECTIONNORTH", nil) substringToIndex:1];
        case MTDIRECTION_UNKNOWN:
            return @"-";
    }
    
    return @"-";
}

- (NSString *)getBusHeadingOCStyle
{
    switch(_busHeading)
    {
        case MTDIRECTION_EAST:
            return NSLocalizedString(@"MTDEF_DIRECTIONEASTOC", nil);
        case MTDIRECTION_SOUTH:
            return NSLocalizedString(@"MTDEF_DIRECTIONSOUTHOC", nil);
        case MTDIRECTION_WEST:
            return NSLocalizedString(@"MTDEF_DIRECTIONWESTOC", nil);
        case MTDIRECTION_NORTH:
            return NSLocalizedString(@"MTDEF_DIRECTIONNORTHOC", nil);
        case MTDIRECTION_UNKNOWN:
            return NSLocalizedString(@"MTDEF_DIRECTIONUNKNOWNOC", nil);
    }
    
    return NSLocalizedString(@"MTDEF_DIRECTIONUNKNOWNOC", nil);
}

- (int)getBusHeadingForFavorites
{
    switch(_busHeading)
    {
        case MTDIRECTION_EAST:
            return 0;
        case MTDIRECTION_SOUTH:
            return 3;
        case MTDIRECTION_WEST:
            return 1;
        case MTDIRECTION_NORTH:
            return 2;
        case MTDIRECTION_UNKNOWN:
            return -1;
    }
    
    return -1;
}

- (BOOL)updateBusHeadingFromInt:(int)heading
{
    switch(heading)
    {
        case 0:
            _busHeading = MTDIRECTION_EAST;
        case 3:
            _busHeading = MTDIRECTION_SOUTH;
        case 1:
            _busHeading = MTDIRECTION_WEST;
        case 2:
            _busHeading = MTDIRECTION_NORTH;
        default:
            _busHeading = MTDIRECTION_UNKNOWN;
    }
    
    return NO;
}

- (NSArray*)getWeekdayTimesForDisplay
{
    NSMutableArray* times = [[NSMutableArray alloc] init];
    
    for(int x=0; x<_times.Times.count; x++)
    {
        MTTime *time = [_times.Times objectAtIndex:x];
        [times addObject:[time getTimeForDisplay]];
    }
    
    return times;
}

- (NSArray*)getSaturdayTimesForDisplay
{
    NSMutableArray* times = [[NSMutableArray alloc] init];
    
    for(int x=0; x<_times.TimesSat.count; x++)
    {
        MTTime *time = [_times.TimesSat objectAtIndex:x];
        [times addObject:[time getTimeForDisplay]];
    }
    
    return times;
}

- (NSArray*)getSundayTimesForDisplay
{
    NSMutableArray* times = [[NSMutableArray alloc] init];
    
    for(int x=0; x<_times.TimesSun.count; x++)
    {
        MTTime *time = [_times.TimesSun objectAtIndex:x];
        [times addObject:[time getTimeForDisplay]];
    }

    return times;
}

#pragma mark - TIME OPERATIONS

- (NSString *)getNextTime
{
    NSArray* timesToParse = nil;
    
    if(_liveTimes != nil && _hasGpsTime)
    {
        timesToParse = _liveTimes.Times;
    }
    else
    {
        if(_times == nil)
            return MTDEF_TIMEUNKNOWN;
        
        switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
            case 1: //Sunday
                timesToParse = _times.TimesSun;
                break;
            case 7:
                timesToParse = _times.TimesSat;
                break;
            default:
                timesToParse = _times.Times;
                break;
        }
    }
    
    if(timesToParse == nil)
        return MTDEF_TIMEUNKNOWN;
    
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    MTTime *nextTime = nil;
    
    for(MTTime *time in timesToParse)
    {
        if([time compareTimesHHMMSS:currentTime Ordering:1] > 0)
        {
            nextTime = time;
            break;
        }
    }
    
    if(nextTime != nil)
        return [nextTime getTimeForDisplay];
    
    return MTDEF_TIMEUNKNOWN;
}

- (NSArray*)getNextThreeTimes
{
    return [self getNextTimesOfAmount:3];
}

- (NSArray*)getNextTimesOfAmount:(int)count
{
    NSArray* timesToParse = nil;
    NSMutableArray *foundTimes = nil;
    
    if(_liveTimes != nil && _hasGpsTime)
    {
        timesToParse = _liveTimes.Times;
    }
    else
    {
        if(_times == nil)
            return nil;
        
        switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
            case 1: //Sunday
                timesToParse = _times.TimesSun;
                break;
            case 7:
                timesToParse = _times.TimesSat;
                break;
            default:
                timesToParse = _times.Times;
                break;
        }
    }
    
    if(timesToParse == nil)
        return nil;
    
    foundTimes = [[NSMutableArray alloc] initWithCapacity:count];
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    
    for(MTTime *time in timesToParse)
    {
        if(foundTimes.count >= count)
            break;
        
        if([time compareTimesHHMMSS:currentTime Ordering:1] > 0)
        {
            [foundTimes addObject:time];
        }
    }
    
    if(foundTimes != nil && foundTimes.count > 0)
        return (NSArray*)foundTimes;
    
    return nil;
}

- (NSString *)getPrevTime
{
    NSArray* timesToParse = nil;
    
    if(_times == nil)
        return MTDEF_TIMEUNKNOWN;
    
    switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
        case 1: //Sunday
            timesToParse = _times.TimesSun;
            break;
        case 7:
            timesToParse = _times.TimesSat;
            break;
        default:
            timesToParse = _times.Times;
            break;
    }
    
    if(timesToParse == nil)
        return MTDEF_TIMEUNKNOWN;
    
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    MTTime* lastTime = nil;
    
    for(MTTime *time in timesToParse)
    {
        if([time compareTimesHHMMSS:currentTime Ordering:0] < 0)
        {
            break;
        }
        
        lastTime = time;
    }
    
    if(lastTime != nil)
        return [lastTime getTimeForDisplay];
    
    return MTDEF_TIMEUNKNOWN;
}

- (MTTime*)getCurrentTrip
{
    NSArray* timesToParse = nil;
    
    if(_liveTimes != nil && _hasGpsTime)
    {
        timesToParse = _liveTimes.Times;
    }
    else
    {
        if(_times == nil)
            return nil;
        
        switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
            case 1: //Sunday
                timesToParse = _times.TimesSun;
                break;
            case 7:
                timesToParse = _times.TimesSat;
                break;
            default:
                timesToParse = _times.Times;
                break;
        }
    }
    
    if(timesToParse == nil)
        return nil;
    
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    MTTime *nextTime = nil;
    
    for(MTTime *time in timesToParse)
    {
        if([time compareTimesHHMMSS:currentTime Ordering:1] > 0)
        {
            nextTime = time;
            break;
        }
    }
    
    if(nextTime != nil)
        return nextTime;
    
    return nil;
}

#pragma mark - DEBUG HELPERS

- (NSString *)description
{
    return [NSString stringWithFormat:@"BUS: %@ , %d", _busId, _busNumber];
}

#pragma mark - NSCOPYING

- (id)copyWithZone:(NSZone *)zone
{
    MTBus * bus = [[MTBus allocWithZone:zone] initWithLanguage:_language];
    
    bus.DisplayHeading = self.DisplayHeading;
    bus.BusId = self.BusId;
    bus.BusHeading = self.BusHeading;
    bus.BusNumber = self.BusNumber;
    
    bus.Times.TimesAdded = NO;
    
    return bus;
}

@end
