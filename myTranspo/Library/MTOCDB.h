//
//  MTOCDB.h
//  myTranspoOC - This is direct access to the local database stored on the device
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

/*******
 
 DATABASE DETAILS:
 stops: built from octranspo txt file.
 routes: built from octranspo txt file.
 stop_routes: built from view on main MYSQL database, exported results as CSV than loaded into sqlite DB through firefox addon.
 
 
 ******/

#import <Foundation/Foundation.h>
#import "MTInteraction.h"
#import "MTDefinitions.h"
#import <sqlite3.h>
#import "sqlite3_distance.c"

#include <mach/mach_time.h>
#include <stdint.h>

@interface MTOCDB : NSObject <MTInteraction>
{
    NSString*           _dbPath;
    sqlite3*            _db;
    BOOL                _isConnected;
    BOOL                _isWritable;
    MTLanguage          _language;
    uint                _stopsLimit;
    uint                _busLimit;
    float               _locationDistance;
}

@property (nonatomic)   BOOL isConnected;

- (id)initWithDBPath:(NSString *)dbPath And:(MTLanguage)lang;
- (BOOL)connectToDatabase;
- (void)killDatabase;

//updates
- (BOOL)addScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus;

//extras
- (BOOL)getAllBusesForStops:(NSMutableArray *)stops;
- (BOOL)getDistanceFromStop:(MTStop*)stop;
- (BOOL)getStopsForBus:(MTBus *)bus ByDistanceLat:(double)latitude Lon:(double)longitude;
- (BOOL)getBus:(MTBus *)bus ForStop:(MTStop *)stop;
- (MTTrip*)getClosestTrip:(NSArray*)trips ToLat:(double)latitude Lon:(double)longitude;
- (BOOL)getOfflineStop:(MTStop*)stop 
          Route:(MTBus*)bus 
          Times:(NSDate*)date
        Results:(NSDictionary*)results;

//favorites
- (BOOL)getFavorites:(NSMutableArray*)favorites;
- (BOOL)addFavoriteUsingStop:(MTStop*)stop AndBus:(MTBus*)bus;
- (BOOL)removeFavoriteForStop:(MTStop*)stop AndBus:(MTBus*)bus;
- (BOOL)isFavoriteForStop:(MTStop*)stop AndBus:(MTBus*)bus;
- (BOOL)updateFavorite:(MTStop*)stop AndBus:(MTBus*)bus;
- (BOOL)compareFavoritesToNotices:(NSArray*)notices;

//stored times
- (BOOL)addTimes:(NSDictionary*)times ToLocalDatabaseForStop:(MTStop*)stop AndBus:(MTBus*)bus;

//options
- (NSDate*)getLastSupportedDate;

@end
