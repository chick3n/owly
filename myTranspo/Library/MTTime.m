//
//  MTTime.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTTime.h"

@interface MTTime ()
- (long)convertStringTimeToSeconds:(NSString*)time;
@end

@implementation MTTime

@synthesize Time            = _time;
@synthesize StopId          = _stopId;
@synthesize TripId          = _tripId;
@synthesize IsLive          = _isLive;
@synthesize StopSequence    = _stopSequence;
@synthesize EndStopHeader   = _endStopHeader;
@synthesize Alert           = _alert;
@synthesize dayOfWeek       = _dayOfWeek;

- (long)getTimeInSeconds
{
    return [self convertStringTimeToSeconds:_time];
}

- (long)getStartTimeInSeconds
{
    //return [self convertStringTimeToSeconds:_startTime];
    return [self getTimeInSeconds];
}

- (int)compareTimesHHMMSS:(NSString*)time Ordering:(int)orderBy
{
    return [self compareTimesHHMMSS:time Ordering:orderBy PassedMidnight:NO];
}

//ToDo: Doesnt compare against time after midnight as it registers it as less than because no date is associated to it
- (int)compareTimesHHMMSS:(NSString*)time Ordering:(int)orderBy PassedMidnight:(BOOL)passMidnight
{
    NSString* time1 = [(!passMidnight ? time : [MTHelper revertOC24HourTime:time]) stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString* time2 = [_time stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    int nTime1 = [time1 intValue];
    int nTime2 = [time2 intValue];
    
    if(passMidnight) //add 240000 hours to time
        nTime2 += 240000;
    
    //NSLog(@"time1: %d time2: %d", nTime1, nTime2);
    
    if(nTime1 > nTime2)
        return (orderBy == 1) ? -1 : 1;
    else if(nTime1 < nTime2)
        return (orderBy == 1) ? 1 : -1;
    
    return 0;
    
    /*
     //get current time as a 1970's time
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"HH:mm:ss"];
     [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
     [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]]; //force 24 hour time
     NSString* 1970CurrentTime = [dateFormatter stringFromDate:[NSDate date]];
     NSDate* 1970CurrentTimeDate = [dateFormatter dateFromString:1970CurrentTime];
     NSDate *convertedTime = [dateFormatter dateFromString:time];

     return [1970CurrentTimeDate compare:convertedTime];
        
     */
}

- (long)convertStringTimeToSeconds:(NSString*)time
{
    if(time == nil)
        return -1; //unknown
    
    //should be 24 hour time always
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]]; //force 24 hour time
    NSDate *convertedTime = [dateFormatter dateFromString:time];
    
    if(convertedTime == nil)
        return -1;
    
    return [convertedTime timeIntervalSince1970];
}

- (NSString*)getTimeForDisplay
{
    if(_time == nil)
        return MTDEF_TIMEUNKNOWN;

    //is time past 23:59? adjust!
    NSString* firstPart = [_time substringToIndex:2];
    if([firstPart intValue] >= 24)
    {
        int hour = [firstPart intValue] - 24;
        NSRange minRange = NSMakeRange(3, 2);
        int min = [[_time substringWithRange:minRange] intValue];
        return [NSString stringWithFormat:@"%02d:%02d", hour, min];
    }
    
    //strip off last 2
    return [_time substringToIndex:5];
}

@end

@implementation MTTimeLive

@synthesize Times           = _times;
@synthesize LastUpdated     = _lastUpdate;

- (id)init
{
    self = [super init];
    if(self)
    {
        _times = [[NSMutableArray alloc] init];
        _lastUpdate = nil;
    }
    
    return self;
}

@end

@implementation MTTimes

@synthesize Times           = _times;
@synthesize TimesSat        = _timesSat;
@synthesize TimesSun        = _timesSun;
@synthesize TimesAdded      = _timesHaveBeenAdded;
@synthesize NextUpdate;

- (id)init
{
    self = [super init];
    if(self)
    {
        _times = [[NSMutableArray alloc] init];
        _timesSat = [[NSMutableArray alloc] init];
        _timesSun = [[NSMutableArray alloc] init];
        _timesHaveBeenAdded = NO;
        
        self.NextUpdate = nil;
    }
    
    return self;
}

- (void)clearTimes
{
    [_times removeAllObjects];
    [_timesSat removeAllObjects];
    [_timesSun removeAllObjects];
}

- (void)setTimesAdded:(BOOL)TimesAdded
{
    _timesHaveBeenAdded = TimesAdded;
    _timesAdded = [NSDate date];
}

- (BOOL)TimesAdded
{
    //if we havent updated time times since yesterday
    if(_timesAdded == nil)
    {
        _timesHaveBeenAdded = NO;
        return NO;
    }
    
    if([MTHelper IsDateToday:_timesAdded])
        return _timesHaveBeenAdded;
    
    return NO;
}

@end