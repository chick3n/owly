//
//  MTHelper.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-18.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTHelper.h"

@implementation MTHelper

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
    
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    weekdayComponents.timeZone = [NSTimeZone localTimeZone];
    int currentWeekday = [weekdayComponents weekday];

    return  currentWeekday;
}

+ (MTResultState)QuickResultState:(BOOL)status
{
    if(status)
        return MTRESULTSTATE_SUCCESS;
    return MTRESULTSTATE_FAILED;
}

+ (NSString*)CurrentTimeHHMMSS
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSDateFormatter*)MTDateFormatterDashesYYYYMMDD
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
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

@end
