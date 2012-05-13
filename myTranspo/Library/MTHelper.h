//
//  MTHelper.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-18.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTypes.h"

@interface MTHelper : NSObject

+ (int)DayOfWeek;
+ (int)DayOfWeekForDate:(NSDate*)date;
+ (int)NextDayOfWeekFromWeek:(int)week;
+ (MTResultState)QuickResultState:(BOOL)status;
+ (NSString*)CurrentTimeHHMMSS;
+ (NSString*)DateDashesYYYYMMDD:(NSDate*)date;
+ (NSDateFormatter*)MTDateFormatterDashesYYYYMMDD;
+ (NSDateFormatter*)TimeFormatter;
+ (BOOL)IsDateToday:(NSDate*)date;
+ (MTTranspoTypes)transpoTypeBasedOnCity:(MTCity)city;
+ (NSString*)timeRemaingUntilTime:(NSString*)time;
+ (MTDirection)convertOCBusHeading:(NSString*)heading;
+ (NSString*)convertOC24HourTime:(NSString*)time;
+ (NSString*)revertOC24HourTime:(NSString*)time;
+ (NSString*)convertNoticeIdToString:(NSString*)notice;
+ (NSString*)convertNoticeIdToSubtitleString:(NSString*)notice;
+ (NSString*)convertNoticeIdToIconString:(NSString*)notice;

//dates
+ (NSString*)PrettyDate:(NSDate*)date;

//time
+ (NSString*)ShortTime:(NSString*)time;

@end
