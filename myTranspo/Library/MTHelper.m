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
        ocDates.hour = -4; //todo: Should be set to 3:30 for OC end of day
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
    if(week >= 7)
        return 1;
    
    //return week + 1;
    return week+1;
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
    {
        //assume that the time we sent is now for the next day
        chosenTime = [chosenTime dateByAddingTimeInterval:24*60*60];
//        return time;
    }
    
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:today  toDate:chosenTime  options:0];

#if 0
    if([conversionInfo day] >= 1)
        timeRemaining = @"1d+";
    else if([conversionInfo hour] > 16 || ([conversionInfo hour] >= 16 && [conversionInfo minute] > 39))
    {
        timeRemaining = [NSString stringWithFormat:@"%dh+", [conversionInfo hour]];
    }
#endif
    
    if([conversionInfo minute] == 0 && [conversionInfo hour] == 0 && [conversionInfo day] == 0)
    {
        timeRemaining = NSLocalizedString(@"BUSHERENOW", nil);
    }
    else if( [conversionInfo hour] == 0 && [conversionInfo day] == 0 && [conversionInfo minute] <= 15)
    {
        timeRemaining = [NSString stringWithFormat:@"%d min", ([conversionInfo hour] * 60) + [conversionInfo minute]];
    }
    else {
        timeRemaining = time;
    }
    
    return timeRemaining;
}

+ (NSString*)ShortTime:(NSString*)time
{
    return time;
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

+ (NSDateFormatter*)MTDateFormatterNoDashesYYYYMMDD
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    return dateFormatter;
}

+ (NSString*)PrettyDate:(NSDate*)date
{
    if(date == nil)
        return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    return [dateFormatter stringFromDate:date];
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
    
    NSDate* today = [NSDate date];
    NSUInteger components = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSSecondCalendarUnit;
    //reset date to midnight
    
    NSDateComponents* day1 = [[NSCalendar currentCalendar] components:components fromDate:date];
    NSDateComponents* day2 = [[NSCalendar currentCalendar] components:components fromDate:today];
    
    day1.hour = 03; //this is OC midngiht time, modify this when using other cities
    day1.minute = 30;
    day1.second = 00;
    
    day2.hour = 03;
    day2.minute = 30;
    day2.second = 00;
    
    NSDate *newToday = [[NSCalendar currentCalendar] dateFromComponents:day2];
    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:day1];
    
    NSDateComponents* component = [[NSCalendar currentCalendar] components:components fromDate:newToday toDate:newDate options:0];

    return (component.day == 0) ? YES : NO;

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
    if([heading isEqualToString:@"Northbound"] || [heading isEqualToString:@"Inbound"])
    {
        return MTDIRECTION_NORTH;
    }
    else if([heading isEqualToString:@"Southbound"] || [heading isEqualToString:@"Outbound"])
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

+ (NSString*)convertNoticeIdToSubtitleString:(NSString*)notice
{
    if([notice isEqualToString:@"genserchange"])
        return NSLocalizedString(@"NOTICEGENSERCHANGEDESC", nil);
    else if([notice isEqualToString:@"genmsg"])
        return NSLocalizedString(@"NOTICEGENMSGDESC", nil);
    else if([notice isEqualToString:@"cantrips"])
        return NSLocalizedString(@"NOTICECANTRIPSDESC", nil);
    else if([notice isEqualToString:@"detours"])
        return NSLocalizedString(@"NOTICEDETOURSDESC", nil);
    
    return @"";
}

+ (NSString*)convertNoticeIdToIconString:(NSString*)notice
{
    if([notice isEqualToString:@"genserchange"])
        return @"notice_plan_icon.png";
    else if([notice isEqualToString:@"genmsg"])
        return @"notice_elevator_icon.png";
    else if([notice isEqualToString:@"cantrips"])
        return @"notice_day_icon.png";
    else if([notice isEqualToString:@"detours"])
        return @"notice_detour_icon.png";
    
    return @"";
}

@end
