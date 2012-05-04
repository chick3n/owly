//
//  MTTime.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDefinitions.h"
#import "MTHelper.h"

@interface MTTime : NSObject //think of it as a time and trip object
{
    NSString*                   _time;
    BOOL                        _isLive;
    NSString*                   _tripId;
    NSString*                   _stopId;
    int                         _stopSequence;
}

@property (nonatomic, strong)   NSString*       Time;
@property (nonatomic, strong)   NSString*       TripId;
@property (nonatomic, strong)   NSString*       StopId;
@property (nonatomic)           BOOL            IsLive;
@property (nonatomic)           int             StopSequence;
@property (nonatomic, strong)   NSString*       EndStopHeader;
@property (nonatomic, weak)     UILocalNotification* Alert;
@property (nonatomic)           int             dayOfWeek;

- (long)getTimeInSeconds;
- (long)getStartTimeInSeconds;
- (NSString*)getTimeForDisplay;
- (int)compareTimesHHMMSS:(NSString*)time Ordering:(int)orderBy;
- (int)compareTimesHHMMSS:(NSString*)time Ordering:(int)orderBy PassedMidnight:(BOOL)passMidnight;

@end

@interface MTTimeLive : NSObject 
{
    NSArray*                _times; //weekday: think of it as a time and trip object
    NSDate*                 _lastUpdate;
}

@property (nonatomic, strong)   NSArray*            Times;
@property (nonatomic, strong)   NSDate*             LastUpdated;

@end


@interface MTTimes : NSObject 
{
    BOOL                    _timesHaveBeenAdded;
    NSMutableArray*         _times; //weekday: think of it as a time and trip object
    NSMutableArray*         _timesSat;
    NSMutableArray*         _timesSun;
    NSDate*                 _timesAdded;
}

@property (nonatomic, strong)   NSMutableArray*     Times;
@property (nonatomic, strong)   NSMutableArray*     TimesSat;
@property (nonatomic, strong)   NSMutableArray*     TimesSun;
@property (nonatomic)           BOOL                TimesAdded;
@property (nonatomic, strong)   NSString*           NextUpdate;
@property (nonatomic, readonly) NSDate*             TimesAddedOn;

- (void)clearTimes;

@end
