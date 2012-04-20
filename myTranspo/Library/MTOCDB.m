//
//  MTOCDB.m
//  myTranspoOC - This is direct access to the local database stored on the device
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTOCDB.h"

@interface MTOCDB ()

@end

@implementation MTOCDB 

#pragma mark - INITILIZATION

- (id)initWithDBPath:(NSString *)dbPath 
                 And:(MTLanguage)lang
{
    self = [super init];
    if(self)
    {
        _dbPath = [NSString stringWithString:dbPath];
        _isWritable = NO;
        _isConnected = NO;
        _language = lang;
        _stopsLimit = MTDEF_STOPSLIMIT;
        _busLimit = MTDEF_BUSLIMIT;
        _locationDistance = MTDEF_LOCATIONDISTANCE;
        
        if(![self connectToDatabase])
            return nil;
    }
    
    return self;
}

- (void)dealloc
{
    if(_isConnected)
        sqlite3_close(_db);
}

- (BOOL)connectToDatabase
{
    sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    
    if(sqlite3_open_v2([_dbPath UTF8String], &_db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE, nil) != SQLITE_OK)
        return NO;
    
    _isConnected = YES;
    _isWritable = YES;
    return YES;
}

#pragma mark - UPDATES

- (BOOL)addScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    
    
    return YES;
}

#pragma mark - STOPS

//get all routes that goto a stop
- (BOOL)getRoutesForStop:(MTStop *)stop
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select %@ \
                         from %@ \
                         inner join %@ \
                         where %@ \
                         order by %@",
                         @"sr.trip_headsign, r.route_short_name, r.route_id, (SELECT COUNT(*) FROM favorites f WHERE f.route_id = sr.route_id AND f.stop_id = sr.stop_id) favorite"
                         , @"stop_routes sr"
                         , @"routes r on r.route_id = sr.route_id"
                         , [NSString stringWithFormat:@"sr.stop_id = '%@'", stop.StopId]
                         , @"r.route_short_name"];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTBus *bus = [[MTBus alloc] initWithLanguage:_language];
            
            bus.DisplayHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            bus.BusNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 1)];
            bus.BusId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            if(sqlite3_column_int(_cmpStmt, 3) > 0)
                bus.isFavorite = YES;            
            
            [bus.StopIds addObject:stop];
            
            [stop.BusIds addObject:bus];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    return YES;
}

//return a stop or update it
- (BOOL)getStop:(MTStop *)stop
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select %@ \
                         from %@ \
                         where %@ \
                         order by %@",
                         @"s.stop_name, s.stop_lat, s.stop_lon, s.stop_id, s.stop_code"
                         , @"stops s"
                         , [NSString stringWithFormat:@"s.stop_id = '%@'", stop.StopId]
                         , @"s.stop_id"];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(cmpStmt) == SQLITE_ROW)
        {
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 3)];
            stop.StopNumber = sqlite3_column_int(cmpStmt, 4);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 0)];
            stop.Latitude = sqlite3_column_double(cmpStmt, 1);
            stop.Longitude = sqlite3_column_double(cmpStmt, 2);
        }
    }
    
    sqlite3_reset(cmpStmt);
    
    return YES;
}

- (BOOL)getStopsForBus:(MTBus *)bus
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select %@ \
                         from %@ \
                         inner join %@ \
                         where %@ \
                         order by %@",
                         @"s.stop_name, s.stop_lat, s.stop_lon, s.stop_id, s.stop_code"
                         , @"stop_routes sr"
                         , @"stops s on s.stop_id = sr.stop_id"
                         , [NSString stringWithFormat:@"sr.route_id = '%@' AND sr.trip_headsign = '%@'", bus.BusId, bus.DisplayHeading]
                         , @"s.stop_id"];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 3)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 4);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 1);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 2);
            
            [stop.BusIds addObject:[bus copy]];
            
            [bus.StopIds addObject:stop];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    return YES;
}

- (BOOL)getStopsForBus:(MTBus *)bus
         ByDistanceLat:(double)latitude
                   Lon:(double)longitude
{
    if(!_isConnected)
        return NO;
    
    sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select %@ \
                         from %@ \
                         inner join %@ \
                         where %@ \
                         order by %@"
                         , [NSString stringWithFormat:
                            @"s.stop_name, s.stop_lat, s.stop_lon, s.stop_id, s.stop_code, distance(s.stop_lat, s.stop_lon, %f, %f) AS DIST"
                            , latitude, longitude]
                         , @"stop_routes sr"
                         , @"stops s on s.stop_id = sr.stop_id"
                         , [NSString stringWithFormat:@"sr.route_id = '%@' AND sr.trip_headsign = '%@'", bus.BusId, bus.DisplayHeading]
                         , @"DIST asc"];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 3)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 4);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 1);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 2);
            
            [stop.BusIds addObject:[bus copy]];
            
            [bus.StopIds addObject:stop];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    return YES;
}

- (BOOL)getAllStops:(NSMutableArray*)stops
{
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         order by %@",
                         @"s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon"
                         , @"stops s"
                         , @"s.stop_code ASC"];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            [stops addObject:stop];
        }
        
        sqlite3_reset(_cmpStmt);
        
        return YES;
    }

    
    return NO;
}


- (BOOL)getAllStopsForBuses:(NSMutableArray *)buses
{
    if(!_isConnected)
    {
        return NO;
    }
    
    for(MTBus *bus in buses)
    {
        [self getStopsForBus:bus];
    }
    
    return YES;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
               With:(NSString*)identifier // (len <= 3) route_short_name , (len == 4) stop_code, (len > 4) displayHeading?
               Page:(int)page
{
    if(!_isConnected)
        return NO;
    
    //Get Buses 
    
    NSMutableArray* buses = [[NSMutableArray alloc] init];
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select tr.route_id, r.route_short_name, tr.trip_headsign \
                         from trip_routes tr \
                         INNER JOIN routes r on r.route_id = tr.route_id \
                         WHERE r.route_short_name like '%@%%' \
                         ORDER BY r.route_id ASC \
                         LIMIT %d, %d"
                         , identifier
                         , (page - 1) * _stopsLimit
                         , _stopsLimit];    
    
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTBus *bus = [[MTBus alloc] initWithLanguage:_language];
            
            bus.BusId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            bus.BusNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 1)];
            bus.DisplayHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            
            [buses addObject:bus];
        }
        
        sqlite3_reset(_cmpStmt);
        
        //get all buses for stops
        //[self getAllBusesForStops:stops];
    }
    
    [stops addObject:buses];

    //get bus stops from query
    NSMutableArray* busStops = [[NSMutableArray alloc] init];
    
    sqlite3_reset(_cmpStmt);
    
    sqlStmt = [NSString stringWithFormat:
               @"select s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon \
               from stops s \
               where s.stop_code like '%%%@%%' \
               ORDER BY s.stop_name ASC \
               LIMIT %d, %d"
               , identifier
               , (page - 1) * _stopsLimit
               , _stopsLimit];    
    
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            [busStops addObject:stop];
        }
        
        sqlite3_reset(_cmpStmt);
        
        //get all buses for stops
        //[self getAllBusesForStops:busStops];
    }
    
    [stops addObject:busStops];
    
    //get bus stops from query
    NSMutableArray* streetNames = [[NSMutableArray alloc] init];
    
    sqlite3_reset(_cmpStmt);
    
    sqlStmt = [NSString stringWithFormat:
               @"select s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon \
               from stops s \
               INNER JOIN stop_routes sr ON sr.stop_id = s.stop_id \
               WHERE s.stop_name like '%%%@%%' \
               GROUP BY s.stop_name \
               ORDER BY s.stop_name ASC \
               LIMIT %d, %d"
               , identifier
               , (page - 1) * _stopsLimit
               , _stopsLimit];
    
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            [streetNames addObject:stop];
        }
        
        sqlite3_reset(_cmpStmt);
        
        //get all buses for stops
        //[self getAllBusesForStops:streetNames];
    }
    
    [stops addObject:streetNames];
    
    return (stops.count > 0) ? YES : NO;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
               Page:(int)page
{
    if(!_isConnected)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         order by %@ \
                         limit %d, %d",
                         @"s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon"
                         , @"stops s"
                         , @"s.stop_code ASC"
                         , (page - 1) * _stopsLimit
                         , _stopsLimit];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            [stops addObject:stop];
        }
        
        sqlite3_reset(_cmpStmt);
        
        //get all buses for stops
        [self getAllBusesForStops:stops];

        return YES;
    }
    
    return NO;
}

- (BOOL)getDistanceFromStop:(MTStop*)stop
{
    if(!_isConnected)
        return NO;
    
    sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
    NSString * sqlStmt = [NSString stringWithFormat:
                          @"SELECT distance(s.stop_lat, s.stop_lon, %f, %f) AS DIST FROM stops s WHERE s.stop_id = '%@' ORDER BY DIST ASC;"
						  , stop.CurrentLat
						  , stop.CurrentLon
						  , stop.StopId];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
		{
            stop.DistanceFromOrigin = sqlite3_column_double(_cmpStmt, 0);
        }
        sqlite3_reset(_cmpStmt);
        return YES;
    }
    
    return NO;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
            NearLon:(double)lon 
             AndLat:(double)lat
           Distance:(double)kms
{
    if(!_isConnected)
        return NO;
    
    sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
    NSString * sqlStmt = [NSString stringWithFormat:
                          @"SELECT s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon, distance(s.stop_lat, s.stop_lon, %f, %f) AS DIST FROM stops s WHERE DIST < %f ORDER BY DIST ASC;"
						  , lat
						  , lon
						  , ((kms == 0) ? _locationDistance : kms)];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
		{
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            stop.DistanceFromOrigin = sqlite3_column_double(_cmpStmt, 5);

            //NSLog(@"%f", stop.DistanceFromOrigin);
            [stops addObject:stop];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    [self getAllBusesForStops:stops];
    
    return (stops.count > 0) ? YES : NO;
}

- (MTTrip*)getClosestTrip:(NSArray*)trips ToLat:(double)latitude Lon:(double)longitude
{
    if(!_isConnected)
        return nil;
    
    NSMutableString* stopList = [[NSMutableString alloc] init];
    
    for(int x=0; x<trips.count; x++)
    {
        MTTrip* trip = [trips objectAtIndex:x];
        if(x+1 >= trips.count)
            [stopList appendFormat:@"'%@'", trip.StopId];
        else [stopList appendFormat:@"'%@', ", trip.StopId];
    }
    
    sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
    NSString * sqlStmt = [NSString stringWithFormat:
                          @"SELECT s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon, distance(s.stop_lat, s.stop_lon, %f, %f) AS DIST FROM stops s WHERE s.stop_id IN (%@) ORDER BY DIST ASC;"
						  , latitude
						  , longitude
						  , (NSString*)stopList];
    
    NSLog(@"getClosestTrip:%@", sqlStmt);
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
	{
		if(sqlite3_step(_cmpStmt) == SQLITE_ROW)
		{
            MTTrip* trip = [[MTTrip alloc] initWithLanguage:_language];
            
            trip.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            trip.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            trip.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            trip.Latitude = sqlite3_column_double(_cmpStmt, 3);
            trip.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            sqlite3_reset(_cmpStmt);
            
            return trip;
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    return nil;
}

#pragma mark - BUSES CUSTOM

- (BOOL)getAllBusesForStops:(NSMutableArray *)stops
{
    if(!_isConnected)
    {
        return NO;
    }
    
    for(MTStop *stop in stops)
    {
        if(stop.cancelQueue)
            return NO;
        [self getRoutesForStop:stop];
    }
    
    return YES;
}

- (BOOL)getBus:(MTBus *)bus ForStop:(MTStop *)stop
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select sr.trip_headsign, r.route_short_name, r.route_id \
                         from stop_routes sr \
                         inner join routes r on r.route_id = sr.route_id \
                         where sr.stop_id = '%@' and sr.route_id = '%@' \
                         limit 1"
                         , stop.StopId
                         , bus.BusId];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            bus.DisplayHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            bus.BusNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 1)];
            bus.BusId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    
    return YES;
}

#pragma mark - TIMES

- (BOOL)getStop:(MTStop*)stop 
          Route:(MTBus*)bus 
          Times:(NSDate*)date
        Results:(NSDictionary*)results
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* cmpStmt;
    BOOL foundTime = NO;
    NSMutableArray *weekdayPointer = bus.Times.Times;
    NSMutableArray *saturdayPointer = bus.Times.TimesSat;
    NSMutableArray *sundayPointer = bus.Times.TimesSun;
    
    [bus.Times clearTimes];
    
    NSDateFormatter* dateFormatter = [MTHelper MTDateFormatterDashesYYYYMMDD];
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select case ft.day_of_week when 'sunday' then 2 when 'saturday' then 1 else 0 end, ft.trip_id, ft.arrival_time, ft.stop_sequence, s.stop_id, s.stop_name, ft.route_id \
                         from stored_times ft \
                         inner join stops s on s.stop_id = ft.stop_id \
                         where ft.stop_id = '%@'  AND ft.route_id = '%@' AND ft.next_update > '%@' \
                         order by ft.day_of_week asc, ft.id asc"
                         , stop.StopId
                         , bus.BusId
                         , [dateFormatter stringFromDate:date]];
        
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(cmpStmt) == SQLITE_ROW)
        {
            MTTime *time = [[MTTime alloc] init];
            
            time.TripId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 1)];
            time.Time = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 2)];
            time.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 4)];
            time.StopSequence = sqlite3_column_int(cmpStmt, 3);
            time.IsLive = NO;
            
            switch (sqlite3_column_int(cmpStmt, 0)) {
                case 0:
                    [weekdayPointer addObject:time];
                    break;
                case 1:
                    [saturdayPointer addObject:time];
                    break;
                case 2:
                    [sundayPointer addObject:time];
                    break;
            }            
            
            foundTime = YES;
        }
        
        sqlite3_reset(cmpStmt);
        
        if(foundTime)
        {
            bus.Times.TimesAdded = YES;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)getTrips:(NSMutableArray*)trips 
         ForTrip:(NSString*)trip
{
    return NO;
}

- (BOOL)getNextTrips:(NSMutableArray*)_trips
             ForStop:(MTStop*)stop
            ForRoute:(MTBus*)bus
{
    return NO;
}

- (BOOL)getPrevTrip:(MTTime*)trip
            ForStop:(MTStop*)stop
           ForRoute:(MTBus*)bus
{
    return NO;
}

#pragma mark - FAVORITES

- (BOOL)getFavorites:(NSMutableArray*)favorites
{
    if(!_isConnected)
        return NO;
    
    if(favorites == nil)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         inner join %@ \
                         inner join %@ \
                         order by %@",
                         @"s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon, r.route_id, r.route_short_name, r.route_type, f.route_direction, f.route_tripheading, f.updated, f.display_sequence"
                         , @"favorites f"
                         , @"stops s on s.stop_id = f.stop_id"
                         , @"routes r on r.route_id = f.route_id"
                         , @"f.display_sequence ASC"];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
            
            stop.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stop.StopNumber = sqlite3_column_int(_cmpStmt, 1);
            stop.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            stop.Latitude = sqlite3_column_double(_cmpStmt, 3);
            stop.Longitude = sqlite3_column_double(_cmpStmt, 4);
            
            MTBus* bus = [[MTBus alloc] initWithLanguage:_language];
            
            bus.DisplayHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 9)];
            bus.BusNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 6)];
            bus.BusId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 5)];
            bus.isFavorite = YES;
            [bus updateBusHeadingFromInt:sqlite3_column_int(_cmpStmt, 8)];
            
            [stop.BusIds addObject:bus];
            
            [favorites addObject:stop];
        }
        
        sqlite3_reset(_cmpStmt);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)compareFavoritesToNotices:(NSArray*)notices
{
    if(!_isConnected)
        return NO;
    
    if(notices == nil)
        return NO;
    
    if(notices.count <= 0)
        return NO;
    
    NSMutableArray* favorites = [[NSMutableArray alloc] init];
    [self getFavorites:favorites];
    
    if(favorites == nil)
        return NO;
    
    for(MTStop* stop in favorites)
    {
        MTBus* bus = stop.Bus;
        for(int x=0; x<notices.count; x++)
        {
            if([bus.BusNumber isEqualToString:(NSString*)[notices objectAtIndex:x]])
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)isFavoriteForStop:(MTStop*)stop
                      AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         where %@",
                         @"f.*"
                         , @"favorites f"
                         , [NSString stringWithFormat:@"f.route_id = '%@' AND f.stop_id = '%@'", bus.BusId, stop.StopId]];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        if(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            bus.isFavorite = YES;
        }
    }
    sqlite3_reset(_cmpStmt);
        
    return bus.isFavorite;
}

- (BOOL)addFavoriteUsingStop:(MTStop*)stop
                      AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         where %@",
                         @"f.*"
                         , @"favorites f"
                         , [NSString stringWithFormat:@"f.route_id = '%@' AND f.stop_id = '%@'", bus.BusId, stop.StopId]];

    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        if(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            sqlite3_reset(_cmpStmt);
            return NO;
        }
        
        sqlite3_reset(_cmpStmt);
        
        sqlStmt = [NSString stringWithFormat: \
                   @"INSERT INTO `favorites` \
                   (`stop_id`, `route_id`, `route_direction`, `route_tripheading`, `display_sequence`) \
                   VALUES ('%@','%@',%d,'%@',%d);"
                   , stop.StopId
                   , bus.BusId
                   , [bus getBusHeadingForFavorites]
                   , bus.DisplayHeading
                   , 99];
        
        if(sqlite3_prepare_v2(_db
                              , [sqlStmt UTF8String]
                              , -1
                              , &_cmpStmt
                              , NULL) == SQLITE_OK)
        {
            sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
            
            int result = sqlite3_step(_cmpStmt);
            if(result != SQLITE_DONE)
            {
                MTLog(@"Add Favorite Error: %s", sqlite3_errmsg(_db));
            }
            sqlite3_reset(_cmpStmt);		
            
            if(result == SQLITE_DONE)
            {
                sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
                bus.isFavorite = YES;
                return YES;
            }
            else 
                sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);        
        }
        else
        {
            MTLog(@"Add Favorite Error: %s", sqlite3_errmsg(_db));
        }
    }
    else
    {
        MTLog(@"Add Favorite Error: %s", sqlite3_errmsg(_db));
    }
    
    return NO;
}

- (BOOL)updateFavorite:(MTStop*)stop AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"UPDATE favorites SET route_direction = %d WHERE stop_id = '%@' and route_id = '%@';"
                         , [bus getBusHeadingForFavorites]
                         , stop.StopId
                         , bus.BusId];
    sqlite3_stmt* _cmpStmt;
    
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
        
        int result = sqlite3_step(_cmpStmt);
        if(result != SQLITE_DONE)
        {
            MTLog(@"Update Favorite Error: %s", sqlite3_errmsg(_db));
        }
        sqlite3_reset(_cmpStmt);		
        
        if(result == SQLITE_DONE)
        {
            sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
            bus.isFavorite = NO;
            return YES;
        }
        else 
            sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);   
    }
    
    return NO;
}

- (BOOL)removeFavoriteForStop:(MTStop*)stop AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"delete from favorites \
                         where stop_id = '%@' AND route_id = '%@';"
                         , stop.StopId
                         , bus.BusId];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
        
        int result = sqlite3_step(_cmpStmt);
        if(result != SQLITE_DONE)
        {
            MTLog(@"Remove Favorite Error: %s", sqlite3_errmsg(_db));
        }
        sqlite3_reset(_cmpStmt);		
        
        if(result == SQLITE_DONE)
        {
            sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
            bus.isFavorite = NO;
            return YES;
        }
        else 
            sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);   
    }
    
    return NO;
}

#pragma mark - STORED TIMES

- (BOOL)addTimes:(NSDictionary*)times ToLocalDatabaseForStop:(MTStop*)stop AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
        
    if(times == nil)
        return NO;
    
    //delete current times in there
    NSString * sqlStmt = [NSString stringWithFormat: \
                          @"delete from stored_times where stop_id = '%@' and route_id='%@';"
                          , stop.StopId
                          , bus.BusId];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        sqlite3_step(_cmpStmt);
        sqlite3_reset(_cmpStmt);
    }
    
    
    sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
    for(NSString *day in [times allKeys])
    {        
        for(NSDictionary *dic in [times objectForKey:day])
        {
            NSString * sqlStmt = [NSString stringWithFormat: \
                                  @"insert into stored_times \
                                  (day_of_week, arrival_time_ori, arrival_time, stop_id, trip_id, stop_sequence, start_date, end_date, next_update, route_id) \
                                  VALUES \
                                  ('%@', '%@', '%@', '%@', '%@', %@, '%@', '%@', '%@', '%@')"
                                  , [dic valueForKey:@"dayOfWeek"]
                                  , [dic valueForKey:@"arrival_time"]
                                  , [dic valueForKey:@"arrival_time"]
                                  , [dic valueForKey:@"stop_id"]
                                  , [dic valueForKey:@"trip_id"]
                                  , [dic valueForKey:@"stop_sequence"]
                                  , [dic valueForKey:@"start_date"]
                                  , [dic valueForKey:@"end_date"]
                                  , [dic valueForKey:@"next_update"]
                                  , bus.BusId];
            
            if(sqlite3_prepare_v2(_db
                                  , [sqlStmt UTF8String]
                                  , -1
                                  , &_cmpStmt
                                  , NULL) == SQLITE_OK)
            {
                int result = sqlite3_step(_cmpStmt);
                if(result != SQLITE_DONE)
                {
                    MTLog(@"Add Times Error: %s", sqlite3_errmsg(_db));
                    sqlite3_reset(_cmpStmt);
                    sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);   
                    return NO;
                }
                sqlite3_reset(_cmpStmt);
            }
            else
            {
                MTLog(@"Add Times Error: %s", sqlite3_errmsg(_db));
                sqlite3_reset(_cmpStmt);
                sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);   
                return NO;
            }
            
        }
        
        bus.Times.TimesAdded = YES;
    }
    sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
    
    return YES;
}

#pragma mark - OPTIONS

- (NSDate*)getLastSupportedDate
{
    if(!_isConnected)
        return nil;
    
    NSString *sqlStmt = [NSString stringWithFormat:@"select MAX(end_date) from calendar LIMIT 1;"];
    NSString *dateString = nil;
    NSDate* date = nil;
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        if(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            dateString = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
        }
        
        sqlite3_reset(_cmpStmt);
    }
    
    if(dateString != nil)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        
        date = [dateFormat dateFromString:dateString];
        
        if([date compare:[NSDate date]] == NSOrderedAscending) //date is before current date
            date = nil;
    }
    
    return date;
}

@end
