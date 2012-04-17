//
//  MTHelper.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-18.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTHelper.h"
#import "MTSettings.h"

@implementation MTHelper

#pragma mark - Days of Week

+ (int)DayOfWeek
{
#if 0
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"e"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    return [[dateFormatter stringFromDate:[NSDate date]] intValue];
#endif
    return [self DayOfWeekForDate:[NSDate date]];
}

+ (int)DayOfWeekForDate:(NSDate*)date
{
    if(date == nil)
        return 2; //monday
    
    int currentWeekday = 2;
    if([MTSettings cityPreference] == MTCITYOTTAWA)
    {
        NSDateComponents *ocDates = [[NSDateComponents alloc] init];
        ocDates.hour = -4;
        date = [[NSCalendar currentCalendar] dateByAddingComponents:ocDates toDate:date options:0];
    }
    
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    weekdayComponents.timeZone = [NSTimeZone localTimeZone];
    currentWeekday = [weekdayComponents weekday];
    
    return  currentWeekday;
}

+ (int)NextDayOfWeekFromWeek:(int)week
{
    //sunday = 1 sat = 7
    switch (week) {
        case 1:
            return 2;
        case 7:
            return 1;
    }
    
    //return week + 1;
    return 7; //dont care about mon-fri as the times are the same return sat as the next day if its a weekday
}

+ (MTResultState)QuickResultState:(BOOL)status
{
    if(status)
        return MTRESULTSTATE_SUCCESS;
    return MTRESULTSTATE_FAILED;
}

+ (NSString*)CurrentTimeHHMMSS
{
    if([MTSettings cityPreference] == MTCITYOTTAWA)
    {
        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
        dateComp.timeZone = [NSTimeZone localTimeZone];
        if(dateComp.hour < 4)
        {
            int modHour = dateComp.hour + 24;
            return [NSString stringWithFormat:@"%02d:%02d:00", modHour, dateComp.minute];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString*)timeRemaingUntilTime:(NSString*)time
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    [timeFormatter setDefaultDate:[NSDate date]];
    
    NSDate* chosenTime = [timeFormatter dateFromString:time];
    
    if(chosenTime == nil)
        return time;
    
    NSDate* today = [NSDate date];
    NSString* timeRemaining = @"";
    
    NSTimeInterval timeBetweenDates = [chosenTime timeIntervalSinceDate:today];
    if(timeBetweenDates < 0)
        return time;
    
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:today  toDate:chosenTime  options:0];

    if([conversionInfo day] >= 1)
        timeRemaining = @"1d+";
    else if([conversionInfo hour] > 0 || [conversionInfo minute] > 0)
    {
        timeRemaining = [NSString stringWithFormat:@"%dm", ([conversionInfo hour] * 60) + [conversionInfo minute]];
    }
    else
    {
        timeRemaining = NSLocalizedString(@"BUSHERENOW", nil);
    }

    if(timeRemaining == nil)
        return time;

    return timeRemaining;
}

+ (NSString*)DateDashesYYYYMMDD:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [self MTDateFormatterDashesYYYYMMDD];
    return [dateFormatter stringFromDate:date];
}

+ (NSDateFormatter*)MTDateFormatterDashesYYYYMMDD
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    return dateFormatter;
}

+ (NSDateFormatter*)TimeFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    return dateFormatter;
}

+ (BOOL)IsDateToday:(NSDate*)date
{
    if(date == nil)
        return NO;
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
     
    return (components.day == 0) ? YES : NO;
}

+ (MTTranspoTypes)transpoTypeBasedOnCity:(MTCity)city
{
    switch (city) {
        case MTCITYOTTAWA:
            return MTTRANSPOTYPE_OC;
            break;
        case MTCITYTORONTO:
            return MTTRANSPOTYPE_TORONTO;
            break;
        case MTCITYMONTREAL:
            return MTTRANSPOTYPE_MONTREAL;
            break;
        case MTCITYVANCOUVER:
            return MTTRANSPOTYPE_VANCOUVER;
            break;
    }
    
    return MTTRANSPOTYPE_OC;
}

#pragma mark - OC HELPERS

+ (MTDirection)convertOCBusHeading:(NSString*)heading
{
    if([heading isEqualToString:@"Northbound"])
    {
        return MTDIRECTION_NORTH;
    }
    else if([heading isEqualToString:@"Southbound"])
        return MTDIRECTION_SOUTH;
    else if([heading isEqualToString:@"Eastbound"])
        return MTDIRECTION_EAST;
    else if([heading isEqualToString:@"Westbound"])
        return MTDIRECTION_WEST;
    
    return MTDIRECTION_UNKNOWN;
}

+ (NSString*)convertOC24HourTime:(NSString*)time
{
    if(time.length < 5)
        return time;
    
    NSString* hourValue = [time substringToIndex:2];
    if([hourValue intValue] < 4)
    {
        int hour = [hourValue intValue] + 24;
        NSRange minRange = NSMakeRange(3, 2);
        int min = [[time substringWithRange:minRange] intValue];
        return [NSString stringWithFormat:@"%02d:%02d:00", hour, min];
    }
    
    return time;
}

+ (NSString*)revertOC24HourTime:(NSString*)time
{
    if(time.length < 5)
        return time;
    
    NSString* hourValue = [time substringToIndex:2];
    if([hourValue intValue] >= 24)
    {
        int hour = [hourValue intValue] - 24;
        NSRange minRange = NSMakeRange(3, 2);
        int min = [[time substringWithRange:minRange] intValue];
        return [NSString stringWithFormat:@"%02d:%02d:00", hour, min];
    }
    
    return time;
}

#pragma mark - NOTICES

+ (NSString*)convertNoticeIdToString:(NSString*)notice
{
    if([notice isEqualToString:@"genserchange"])
        return NSLocalizedString(@"NOTICEGENSERCHANGE", nil);
    else if([notice isEqualToString:@"genmsg"])
        return NSLocalizedString(@"NOTICEGENMSG", nil);
    else if([notice isEqualToString:@"cantrips"])
        return NSLocalizedString(@"NOTICECANTRIPS", nil);
    else if([notice isEqualToString:@"detours"])
        return NSLocalizedString(@"NOTICEDETOURS", nil);
    
    return @"";
}

@end
