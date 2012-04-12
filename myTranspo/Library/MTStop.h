//
//  MTStop.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTypes.h"
#import "MTDefinitions.h"
#import "MTBus.h"
#import "MTBase.h"

@interface MTStop : MTBase
{
    NSString*           _stopId;
    int                 _stopNumber;    
    double              _stopLatitude;
    double              _stopLongitude;
    NSString*           _stopName;
    NSMutableArray*     _busIds; //MTBus
    MTLanguage          _language;
    double              _distanceFromOrigin;
    BOOL                _isUpdating;
    
}

@property (nonatomic, strong)   NSString*           StopId;
@property (nonatomic)           int                 StopNumber;
@property (nonatomic)           double              Latitude;
@property (nonatomic)           double              Longitude;
@property (nonatomic, strong)   NSString*           StopName;
@property (nonatomic, strong)   NSMutableArray*     BusIds;
@property (nonatomic)           MTLanguage          Language;
@property (nonatomic)           double              DistanceFromOrigin;
@property (nonatomic)           BOOL                IsUpdating;
@property (nonatomic)           BOOL                MTCardCellHelper;
@property (nonatomic)           uint                UpdateCount;
@property (nonatomic)           double              CurrentLat;
@property (nonatomic)           double              CurrentLon;

@property (nonatomic, readonly, getter = getFirstBus)  MTBus*  Bus;

//methods
- (id)initWithLanguage:(MTLanguage)lang;
- (void)updatingState:(BOOL)state;
- (void)cancelQueuesForBuses;
- (void)restoreQueuesForBuses;

// ui helpers
- (NSString*)getDistanceOfStop;

//debug methods
- (NSString *)description;

@end
