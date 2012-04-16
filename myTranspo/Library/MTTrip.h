//
//  MTTrip.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDefinitions.h"
#import "MTTypes.h"
#import "MTTime.h"
#import "MTBase.h"

@interface MTTrip : MTBase
{
    NSString*           _stopId;
    int                 _stopNumber;    
    double              _stopLatitude;
    double              _stopLongitude;
    NSString*           _stopName;
    MTLanguage          _language;
    NSString*           _tripId;
    MTTime*             _time;
    int                 _stopSequence;
    
    NSString*                   _destination;
    BOOL                        _lastTrip;
    uint                        _busType; //MTBusTypes byte
    float                       _busSpeed;
    
}

@property (nonatomic, strong)   NSString*           StopId;
@property (nonatomic)           int                 StopNumber;
@property (nonatomic)           double              Latitude;
@property (nonatomic)           double              Longitude;
@property (nonatomic, strong)   NSString*           StopName;
@property (nonatomic)           MTLanguage          Language;
@property (nonatomic, strong)   NSString*           TripId;
@property (nonatomic, strong)   MTTime*             Time;
@property (nonatomic)           int                 StopSequence;

@property (nonatomic, strong)   NSString*           Destination;
@property (nonatomic, strong)   NSString*           StartTime;
@property (nonatomic)           BOOL                LastTrip;
@property (nonatomic)           uint                BusType;
@property (nonatomic)           float               BusSpeed;

@property (nonatomic, readonly) NSString*           StopNameDisplay;

- (id)initWithLanguage:(MTLanguage)lang;

@end
