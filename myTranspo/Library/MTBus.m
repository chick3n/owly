//
//  MTBus.m
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBus.h"

@interface MTBus ()
- (BOOL)nextTimesForWeek:(int)week 
        IncludeLiveTimes:(BOOL)includeLive 
             CompareTime:(NSString*)time 
            AmountToFind:(int)count 
                 Results:(NSMutableArray*)results
           RecursiveDeep:(int)deep
                 NextDay:(BOOL)nextDay;
@end

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
@synthesize BusSpeed                    = _busSpeed;
@synthesize TrueDisplayHeading          = _trueDisplayHeading;
//display
@synthesize NextTimeDisplay             = _NextTimeDisplay;
@synthesize PrevTimeDisplay             = _PrevTimeDisplay;
@synthesize NextThreeTimesDisplay       = _NextThreeTimesDisplay;

- (NSString*)BusNumberDisplay
{
    if(_busNumber == nil)
        return @"";
#if 1
    if([_numFormatter numberFromString:_busNumber] == nil) //isnt a number
    {
        return [_busNumber substringToIndex:1]; //return the first letter only
    }
#endif
    return _busNumber;
}

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
        _busSpeed = MTDEF_STOPDISTANCEUNKNOWN;
        _numFormatter = [[NSNumberFormatter alloc] init];
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
        _busSpeed = MTDEF_STOPDISTANCEUNKNOWN;
         _numFormatter = [[NSNumberFormatter alloc] init];
    }
    
    return self;
}

//also clears everything that is set from the Bus Data
- (BOOL)clearLiveTimes
{
    _hasGpsTime = NO;
    _liveTimes.LastUpdated = nil;
    _liveTimes.Times = nil;
    _busSpeed = MTDEF_STOPDISTANCEUNKNOWN;
    _trueDisplayHeading = nil;
    
    return YES;
}

- (BOOL)addLiveTimes:(NSArray*)times
{
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
            _busHeading = MTDIRECTION_EAST; break;
        case 3:
            _busHeading = MTDIRECTION_SOUTH; break;
        case 1:
            _busHeading = MTDIRECTION_WEST; break;
        case 2:
            _busHeading = MTDIRECTION_NORTH; break;
        default:
            _busHeading = MTDIRECTION_UNKNOWN; break;
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

- (BOOL)nextTimesForWeek:(int)week 
        IncludeLiveTimes:(BOOL)includeLive 
             CompareTime:(NSString*)time 
            AmountToFind:(int)count 
                 Results:(NSMutableArray*)results
           RecursiveDeep:(int)deep
                 NextDay:(BOOL)nextDay
{
    if(week < 1 || week > 7)
        week = [MTHelper DayOfWeekForDate:_chosenDate];
    
    if(time == nil)
        time = [MTHelper CurrentTimeHHMMSS];
    
    if(count < 1)
        return NO;
    
    if(results == nil)
        return NO;
    
    if(deep < 0)
        return results.count;
    
    NSArray* timesToParse = nil;
    
    if(_liveTimes != nil && _hasGpsTime && includeLive)
    {
        if(_liveTimes.Times != nil)
        {
            if(_liveTimes.Times.count > 0)
            {
                timesToParse = _liveTimes.Times;
            }
        }
    }
    
    if(timesToParse == nil)
    {
        if(_times == nil) //we have no times set
        {
            [results addObject:MTDEF_TIMEUNKNOWN];
            return NO;
        }
        
        switch (week) {
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
    
    MTTime *nextTime = nil;
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    if(timesToParse != nil && timesToParse.count > 0)
    {
        for(MTTime *time in timesToParse)
        {
            if(results.count > count)
                break;
            
            if(nextDay)
            {
                nextTime = time;
                if(nextTime != nil)
                    [results addObject:nextTime];
            }
            else
            {
                if([time compareTimesHHMMSS:currentTime Ordering:1 PassedMidnight:nextDay] > 0)
                {
                    nextTime = time;
                    if(nextTime != nil)
                        [results addObject:nextTime];
                }
            }
        }
    }
    
    //if no times found doesnt match the requested amount try the next day
    if(results.count < count)
    {
        [self nextTimesForWeek:[MTHelper NextDayOfWeekFromWeek:week]
              IncludeLiveTimes:NO
                   CompareTime:time
                  AmountToFind:count 
                       Results:results
                 RecursiveDeep:deep-1 
                       NextDay:YES];
    }
    
    return results.count;
}

- (MTTime *)getNextTime
{
    NSMutableArray* results = [[NSMutableArray alloc] initWithCapacity:1];
    if([self nextTimesForWeek:[MTHelper DayOfWeekForDate:_chosenDate]
             IncludeLiveTimes:YES
                  CompareTime:[MTHelper CurrentTimeHHMMSS]
                 AmountToFind:1
                      Results:results
                RecursiveDeep:1
                      NextDay:![MTHelper IsDateToday:_chosenDate]] > 0)
    {
        if(results.count > 0)
        {
            MTTime* time = [results objectAtIndex:0];
            if(time != nil)
            {
                return time;
            }
        }
    }

    MTTime* time = [[MTTime alloc] init];
    time.Time = MTDEF_TIMEUNKNOWN;
    
    return time;
}

- (NSArray*)getNextThreeTimes
{
    return [self getNextTimesOfAmount:3 IncludeLiveTime:YES];
}

- (NSArray*)getNextTimesOfAmount:(int)count IncludeLiveTime:(BOOL)useLive
{
    BOOL isToday = [MTHelper IsDateToday:_chosenDate];
    
    NSMutableArray* results = [[NSMutableArray alloc] initWithCapacity:count];
    if([self nextTimesForWeek:[MTHelper DayOfWeekForDate:_chosenDate]
             IncludeLiveTimes:useLive
                  CompareTime:[MTHelper CurrentTimeHHMMSS]
                 AmountToFind:count
                      Results:results
                RecursiveDeep:1
                      NextDay:!isToday] > 0)
    {
        if(results.count < count)
        {
            for(int x=0; x<count - results.count; x++)
                [results addObject:[[MTTime alloc] init]];
        }
    }
    
    return results;
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
    NSArray* trips = [self getNextTimesOfAmount:1 IncludeLiveTime:NO];
    if(trips == nil)
        return nil;
    
    if(trips.count <= 0)
        return nil;
    
    return (MTTime*)[trips objectAtIndex:0];
}

- (void)updateDisplayObjects
{
    self.NextThreeTimesDisplay = self.NextThreeTimes;
    [self updatePrevNextObjects];
}

- (void)updatePrevNextObjects
{    
    self.NextTimeDisplay = self.NextTime;
    self.PrevTimeDisplay = self.PrevTime;
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
