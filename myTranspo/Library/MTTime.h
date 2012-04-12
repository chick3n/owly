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
#if 0  
    NSString*                   _destination;
    NSString*                   _startTime; //Can be used as a local start time and _time can be gps time if _isLive = YES
    BOOL                        _lastTrip;
    uint                        _busType; //MTBusTypes byte
    float                       _busSpeed;
    double                      _longitude; //current location
    double                      _latitude; //current location
#endif
}

@property (nonatomic, strong)   NSString*       Time;
@property (nonatomic, strong)   NSString*       TripId;
@property (nonatomic, strong)   NSString*       StopId;
@property (nonatomic)           BOOL            IsLive;
@property (nonatomic)           int             StopSequence;
#if 0
@property (nonatomic, strong)   NSString*       Destination;
@property (nonatomic, strong)   NSString*       StartTime;
@property (nonatomic)           BOOL            LastTrip;
@property (nonatomic)           uint            BusType;
@property (nonatomic)           float           BusSpeed;
@property (nonatomic)           double          Longitude;
@property (nonatomic)           double          Latitude;
#endif

- (long)getTimeInSeconds;
- (long)getStartTimeInSeconds;
- (NSString*)getTimeForDisplay;
- (int)compareTimesHHMMSS:(NSString*)time Ordering:(int)orderBy;

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

- (void)clearTimes;

@end
