//
//  MTInteraction.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTBus.h"
#import "MTStop.h"
#import "MTTrip.h"
#import "MTTripPlanner.h"

@protocol MTInteraction

/* STOPS */
@required
- (BOOL)getRoutesForStop:(MTStop *)stop;
- (BOOL)getStop:(MTStop *)stop;
- (BOOL)getStopsForBus:(MTBus *)bus;
- (BOOL)getAllStops:(NSMutableArray*)stops;
- (BOOL)getAllStopsForBuses:(NSMutableArray *)buses;
- (BOOL)getAllStops:(NSMutableArray *)stops With:(NSString*)identifier Page:(int)page;
- (BOOL)getAllStops:(NSMutableArray *)stops Page:(int)page;

@optional
- (BOOL)getAllStops:(NSMutableArray *)stops NearLon:(double)lon AndLat:(double)lat Distance:(double)kms;

/* TIMES */
@required
- (BOOL)getStop:(MTStop*)stop Route:(MTBus*)bus Times:(NSDate*)date Results:(NSDictionary*)results;
- (BOOL)getTrips:(NSMutableArray*)trips ForTrip:(NSString*)trip;
- (BOOL)getNextTrips:(NSMutableArray*)_trips ForStop:(MTStop*)stop ForRoute:(MTBus*)bus;
- (BOOL)getPrevTrip:(MTTime*)trip ForStop:(MTStop*)stop ForRoute:(MTBus*)bus;


@required


@end
