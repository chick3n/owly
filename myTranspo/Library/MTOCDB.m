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
@synthesize isConnected = _isConnected;


- (BOOL)isConnected
{
    if(_isConnected == NO)
    {
        //lets try to reconnect it once as we may have lost our connection
        [self connectToDatabase];
    }
    
    return _isConnected;
}

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

- (void)killDatabase
{
    if(_isConnected)
    {
        _isWritable = NO;
        _isConnected = NO;
        if(!sqlite3_close(_db) == SQLITE_OK)
            MTLog(@"sqlite not closed, busy.");
    }
}

- (BOOL)connectToDatabase
{
    if(_dbPath == nil)
        return NO;
    
    sqlite3_shutdown();
    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
        MTLog(@"sqlite configured to be threadsafe");
    }    
    sqlite3_initialize();

    //sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    
    //SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE
    if(sqlite3_open_v2([_dbPath UTF8String], &_db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE, nil) != SQLITE_OK)
        return NO;
    
    _isConnected = YES;
    _isWritable = YES;
    return YES;
}

- (BOOL)connectToDatabaseForInstall
{
    if(_dbPath == nil)
        return NO;
    
    sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    
    //SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE
    if(sqlite3_open_v2([_dbPath UTF8String], &_db, SQLITE_OPEN_READWRITE, nil) != SQLITE_OK)
        return NO;
    
    _isConnected = YES;
    _isWritable = YES;
    return YES;
}

- (void)execQuery:(NSString *)query WithVacuum:(BOOL)vacuum
{
    if(!_isConnected)
        return;
    
    //sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
    //MTLog(@"BEGIN: %s", sqlite3_errmsg(_db));
    sqlite3_exec(_db, [query UTF8String], NULL, NULL, NULL);
    MTLog(@"query results: %s", sqlite3_errmsg(_db));
    //sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
    //MTLog(@"COMMIT: %s", sqlite3_errmsg(_db));
    
    if(vacuum)
    {
        sqlite3_exec(_db, "VACUUM;", NULL, NULL, NULL);
        MTLog(@"VACUUM: %s", sqlite3_errmsg(_db));
    }
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
                         @"select sr.trip_headsign, sr.route_short_name, (SELECT COUNT(*) FROM favorites f WHERE f.route_id = sr.route_short_name AND f.stop_id = sr.stop_id) favorite \
                         from stop_routes sr \
                         where sr.stop_id = '%@' group by sr.route_short_name;"
                         , stop.StopId];

    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTBus *bus = [[MTBus alloc] initWithLanguage:_language];
            
            bus.DisplayHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            bus.BusNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 1)];
            //bus.BusId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 2)];
            if(sqlite3_column_int(_cmpStmt, 2) > 0)
                bus.isFavorite = YES;            
            
            [bus.StopIds addObject:stop];
            
            [stop.BusIds addObject:bus];
        }
    }
    else {
        MTLog(@"%s", sqlite3_errmsg(_db));
    }
    
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
    
    return YES;
}

- (BOOL)getRoutesForFavoriteStop:(MTStop*)stop
{
    if(!_isConnected)
        return NO;
    
    NSArray* filterList = [MTSettings favoriteStopFilter:stop.StopId UpdateWith:nil];
    
    NSMutableArray *routesAtStop = [[NSMutableArray alloc] init];
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select sr.route_short_name, sr.trip_headsign \
                         from stop_routes sr \
                         where sr.stop_id = '%@' \
                         group by sr.route_short_name \
                         order by sr.route_short_name"
                         , stop.StopId];
    
    if(sqlite3_prepare_v2(_db, [sqlStmt UTF8String], -1, &_cmpStmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            MTStopHelper *stopHelper = [[MTStopHelper alloc] init];
            stopHelper.routeNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 0)];
            stopHelper.routeHeading = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_cmpStmt, 1)];
            
            if(filterList != nil)
            {
                if(filterList.count > 0 && ![filterList containsObject:stopHelper.routeNumber])
                    stopHelper.hideRoute = YES;
            }
            
            [routesAtStop addObject:stopHelper];
        }
    }
    
    stop.upcomingBusesHelper = routesAtStop;             
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
    
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
    sqlite3_finalize(cmpStmt);
    
    return YES;
}

- (BOOL)getStopsForBus:(MTBus *)bus
{
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select s.stop_name, s.stop_lat, s.stop_lon, s.stop_id, s.stop_code \
                         from stop_routes sr \
                         inner join stops s on s.stop_id = sr.stop_id \
                         where sr.route_short_name = '%@' AND sr.trip_headsign = '%@' \
                         group by s.stop_code  \
                         order by s.stop_id ASC"
                         , bus.BusNumber
                         , bus.DisplayHeading];
    
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
    sqlite3_finalize(_cmpStmt);
    
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
                         @"select s.stop_name, s.stop_lat, s.stop_lon, s.stop_id, s.stop_code, distance(s.stop_lat, s.stop_lon, %f, %f) AS DIST \
                         from stop_routes sr \
                         inner join stops s on s.stop_id = sr.stop_id \
                         where sr.route_short_name = '%@' AND sr.trip_headsign = '%@' \
                         group by s.stop_code \
                         order by DIST asc"
                         , latitude, longitude
                         , bus.BusNumber, bus.DisplayHeading];
    
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
    sqlite3_finalize(_cmpStmt);
    
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
        sqlite3_finalize(_cmpStmt);
        
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
#if 0
    static double ticksToNanoseconds = 0.0;
    uint64_t startTime = mach_absolute_time();
#endif
    NSMutableArray* buses = [[NSMutableArray alloc] init];
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select r.route_id, r.route_short_name, t.trip_headsign \
                         from trips t \
                         inner join routes r on r.route_id = t.route_id \
                         where r.route_short_name like '%@%%' \
                         group by r.route_short_name, t.trip_headsign \
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
        //get all buses for stops
        //[self getAllBusesForStops:stops];
    }
    
    [stops addObject:buses];
#if 0
    uint64_t endTime = mach_absolute_time();
    uint64_t elapsedTime = endTime - startTime;
    if(0.0 == ticksToNanoseconds)
    {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    }

    MTLog(@"First Search: %f", elapsedTime * ticksToNanoseconds);

    startTime = mach_absolute_time();
#endif    
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
        
        //get all buses for stops
        //[self getAllBusesForStops:busStops];
    }
    
    [stops addObject:busStops];
#if 0
     endTime = mach_absolute_time();
    elapsedTime = endTime - startTime;
    if(0.0 == ticksToNanoseconds)
    {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    }
    
    MTLog(@"Second Search: %f", elapsedTime * ticksToNanoseconds);
    
    startTime = mach_absolute_time();
#endif
    //get bus stops from query
    NSMutableArray* streetNames = [[NSMutableArray alloc] init];
    
    sqlite3_reset(_cmpStmt);
    
    sqlStmt = [NSString stringWithFormat:
               @"select s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon \
               from stops s \
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
        //get all buses for stops
        //[self getAllBusesForStops:streetNames];
    }
#if 0
     endTime = mach_absolute_time();
     elapsedTime = endTime - startTime;
    if(0.0 == ticksToNanoseconds)
    {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    }
    
    MTLog(@"Final Search: %f", elapsedTime * ticksToNanoseconds);
#endif
    [stops addObject:streetNames];
    
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
    
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
        sqlite3_finalize(_cmpStmt);
        
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
        sqlite3_finalize(_cmpStmt);
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
#if 0
    static double ticksToNanoseconds = 0.0;
    uint64_t startTime = mach_absolute_time();
#endif
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

            [stops addObject:stop];
        }
    }
    
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
    
#if 0
    uint64_t endTime = mach_absolute_time();
    uint64_t elapsedTime = endTime - startTime;
    if(0.0 == ticksToNanoseconds)
    {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    }
    
    MTLog(@"AllStopsNear: %f", ticksToNanoseconds * elapsedTime);
#endif
    //[self getAllBusesForStops:stops];
    
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
            sqlite3_finalize(_cmpStmt);
            
            return trip;
        }
    }
    
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
    
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
    
    if(bus == nil)
        return NO;
    
    sqlite3_stmt* _cmpStmt;
    NSString *sqlStmt = [NSString stringWithFormat:
                         @"select sr.trip_headsign, r.route_short_name, r.route_id \
                         from stop_routes sr \
                         inner join routes r on r.route_id = sr.route_id \
                         where sr.stop_id = '%@' and sr.route_short_name = '%@' \
                         limit 1"
                         , stop.StopId
                         , bus.BusNumber];
    
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
    sqlite3_finalize(_cmpStmt);
    
    return YES;
}

#pragma mark - TIMES

- (BOOL)getOfflineStop:(MTStop*)stop 
          Route:(MTBus*)bus 
          Times:(NSDate*)date
        Results:(NSDictionary*)results
{
    if(!_isConnected)
        return NO;
#if 0
    static double ticksToNanoseconds = 0.0;
    uint64_t startTime = mach_absolute_time();
#endif
    
    sqlite3_stmt* cmpStmt;
    BOOL foundTime = NO;
    NSMutableArray *weekdayPointer = bus.Times.Times;
    NSMutableArray *saturdayPointer = bus.Times.TimesSat;
    NSMutableArray *sundayPointer = bus.Times.TimesSun;
    
    [bus.Times clearTimes];
    
    NSDateFormatter* dateFormatter = [MTHelper MTDateFormatterDashesYYYYMMDD];
    
    NSString* current_next_update = nil;
    NSString* sqlPreStmt = [NSString stringWithFormat:@"SELECT MIN(next_update) FROM offline_times WHERE stop_id = '%@' and route_id = '%@' and next_update > '%@';"
                            , stop.StopId
                            , bus.BusId
                            , [dateFormatter stringFromDate:date]];
    if(sqlite3_prepare_v2(_db
                          , [sqlPreStmt UTF8String]
                          , -1
                          , &cmpStmt
                          , NULL) == SQLITE_OK)
    {
        if(sqlite3_step(cmpStmt) == SQLITE_ROW)
        {
            current_next_update = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 0)];
        }
    }
    sqlite3_reset(cmpStmt);
    sqlite3_finalize(cmpStmt);
        
    if(current_next_update == nil)
        return NO;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select case ft.day_of_week when 'su' then 2 when 's' then 1 else 0 end, ft.trip_id, ft.arrival_time_ori, ft.stop_sequence, ft.stop_id, ft.route_id, ft.end_stop \
                         from offline_times ft \
                         where ft.stop_id = '%@'  AND ft.route_id = '%@' AND (ft.next_update > '%@' AND ft.next_update <= '%@') \
                         order by ft.day_of_week asc, ft.id asc"
                         , stop.StopId
                         , bus.BusId
                         , [dateFormatter stringFromDate:date]
                         , current_next_update];
    
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
            time.EndStopHeader = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 6)];
            
            switch (sqlite3_column_int(cmpStmt, 0)) {
                case 0:
                    time.dayOfWeek = 0;
                    [weekdayPointer addObject:time];
                    break;
                case 1:
                    time.dayOfWeek = 1;
                    [saturdayPointer addObject:time];
                    break;
                case 2:
                    time.dayOfWeek = 2;
                    [sundayPointer addObject:time];
                    break;
            }            
            
            foundTime = YES;
        }
        
        sqlite3_reset(cmpStmt);
        sqlite3_finalize(cmpStmt);
#if 0 //TIMER COUNT
        uint64_t endTime = mach_absolute_time();
        uint64_t elapsedTime = endTime - startTime;
        if(0.0 == ticksToNanoseconds)
        {
            mach_timebase_info_data_t timebase;
            mach_timebase_info(&timebase);
            ticksToNanoseconds = (double)timebase.numer / timebase.denom;
        }
        
        MTLog(@"Local Time Elapsed: %f", elapsedTime * ticksToNanoseconds);
#endif
        if(foundTime)
        {
            bus.Times.TimesAdded = YES;
            return YES;
        }
    }
    MTLog(@"%s", sqlite3_errmsg(_db));
    sqlite3_reset(cmpStmt);
    sqlite3_finalize(cmpStmt);
    return NO;
}

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
    
    NSDateFormatter* dateFormatter = [MTHelper MTDateFormatterNoDashesYYYYMMDD];
    
    //, (select IFNULL(s2.stop_name, '') from stop_times st2 inner join stops s2 on s2.stop_id = st2.stop_id WHERE st2.trip_id = st.trip_id ORDER BY st2.stop_sequence DESC LIMIT 1)  end_stop \
    
    NSString *sqlStmt = [NSString stringWithFormat:\
                         @"select distinct\
                         case when c.sunday = '1' then 2 when c.saturday = '1' then 1 else 0 end dayOfWeek \
                         , st.trip_id \
                         , s.stop_id \
                         , (h.hour || ':' || m.minute || ':00') arrival_time \
                         , st.stop_sequence \
                         , t.end_stop \
                         from stop_times st \
                         inner join stops s on s.id = st.stop_id \
                         inner join trips t on t.trip_id = st.trip_id \
                         inner join routes r on r.route_id = t.route_id \
                         inner join calendar c on c.service_id = t.service_id \
                         left join calendar_dates cd on cd.service_id = c.service_id \
                         inner join hours h on h.id = st.hour \
                         inner join minutes m on m.id = st.minute \
                         where '%@' BETWEEN c.start_date AND c.end_date \
                         and (r.route_short_name = '%@') \
                         and s.stop_id = '%@' \
                         and (cd.exception_type IS NULL OR cd.exception_type <> 2) \
                         order by dayOfWeek asc, arrival_time asc;"
                          , [dateFormatter stringFromDate:date]
                          , bus.BusNumber
                          , stop.StopId];
    
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
            time.Time = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 3)];
            time.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 2)];
            time.StopSequence = sqlite3_column_int(cmpStmt, 4);
            time.IsLive = NO;
            time.EndStopHeader = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 5)];
            
            switch (sqlite3_column_int(cmpStmt, 0)) {
                case 0:
                    time.dayOfWeek = 0;
                    [weekdayPointer addObject:time];
                    break;
                case 1:
                    time.dayOfWeek = 1;
                    [saturdayPointer addObject:time];
                    break;
                case 2:
                    time.dayOfWeek = 2;
                    [sundayPointer addObject:time];
                    break;
            }            
            
            foundTime = YES;
        }
        
        sqlite3_reset(cmpStmt);
        sqlite3_finalize(cmpStmt);
        
        if(foundTime)
        {
            bus.Times.TimesAdded = YES;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)getStopTimes:(MTStop*)stop
{
    if(stop == nil)
        return NO;
    
    if(!_isConnected)
        return NO;
    
    sqlite3_stmt* cmpStmt;
    
    //this is not a very good way to do this as we keep generating this after every update request!
    NSMutableArray* filterList = [[NSMutableArray alloc] init];
    NSMutableString* filterParameter = [[NSMutableString alloc] init];
    NSString *routeList = @"";
    for(MTStopHelper* helper in stop.upcomingBusesHelper)
    {
        if(helper.hideRoute == YES)
            continue;
        
        [filterList addObject:helper.routeNumber];
        [filterParameter appendFormat:@"'%@',", helper.routeNumber];
    }
    
    if(filterList.count != stop.upcomingBusesHelper.count)
    {
        if(filterParameter.length > 0)
        {
            [filterParameter deleteCharactersInRange:NSMakeRange(filterParameter.length - 1, 1)];
            routeList = [NSString stringWithFormat:@"and r.route_short_name IN (%@) ", filterParameter];
        }
    }
    
    NSString *dateFilter = @"";
    switch ([MTHelper DayOfWeek]) {
        case 1: //sunday
            dateFilter = @"c.sunday = '1'";
            break;
        case 7:
            dateFilter = @"c.saturday = '1'";
            break;            
        default:
            dateFilter = @"(c.monday = '1' OR c.tuesday = '1' OR c.wednesday = '1' OR c.thursday = '1' OR c.friday = '1')";
            break;
    }
    
    [stop.upcomingBuses removeAllObjects];
    
    NSString *sqlStmt = [NSString stringWithFormat:\
                         @"select \
                         st.trip_id \
                         , (h.hour || ':' || m.minute || ':00') arrival_time \
                         , s.stop_id \
                         , st.stop_sequence \
                         , r.route_short_name \
                         , t.end_stop \
                         from stop_times st \
                         inner join stops s on s.id = st.stop_id \
                         inner join trips t on t.trip_id = st.trip_id \
                         inner join routes r on r.route_id = t.route_id \
                         inner join calendar c on c.service_id = t.service_id \
                         left join calendar_dates cd on cd.service_id = c.service_id \
                         inner join hours h on h.id = st.hour \
                         inner join minutes m on m.id = st.minute \
                         where strftime('%%Y%%m%%d', 'now', 'localtime') between c.start_date and c.end_date \
                         %@ \
                         and s.stop_id = '%@' \
                         and %@ \
                         and (cd.exception_type IS NULL OR cd.exception_type <> 2) \
                         and arrival_time > strftime('%%H:%%M:%%S', 'now', 'localtime') \
                         order by arrival_time ASC \
                         LIMIT 40;"
                         , routeList
                         , stop.StopId
                         , dateFilter];

    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(cmpStmt) == SQLITE_ROW)
        {
            MTTime *time = [[MTTime alloc] init];
            
            time.TripId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 0)];
            time.Time = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 1)];
            time.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 2)];
            time.StopSequence = sqlite3_column_int(cmpStmt, 3);
            time.EndStopHeader = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 5)];
            time.routeNumber = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 4)];
            
            time.IsLive = NO;
            
            [stop.upcomingBuses addObject:time];
        }
    } else {
        MTLog(@"ocDb_getStopTimes: %s", sqlite3_errmsg(_db));
    }
    
    sqlite3_reset(cmpStmt);
    sqlite3_finalize(cmpStmt);
    
    return YES;
}

- (BOOL)getTrips:(NSMutableArray*)trips 
         ForTrip:(NSString*)trip
{
    if(!_isConnected)
        return NO;
    
    if(trip == nil)
        return NO;
    
    if(trips == nil)
        return NO;
    
    sqlite3_stmt* cmpStmt;
    
    NSString *sqlStmt = [NSString stringWithFormat:\
                         @"select st.trip_id, (h.hour || ':' || m.minute || ':00') arrival_time, s.stop_id, st.stop_sequence, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon  \
                         from stop_times st \
                         inner join stops s on s.id = st.stop_id \
                         inner join hours h on h.id = st.hour \
                         inner join minutes m on m.id = st.minute \
                         where st.trip_id = %@ \
                         order by st.stop_sequence ASC;"
                         , trip];
    
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &cmpStmt
                          , NULL) == SQLITE_OK)
    {
        while(sqlite3_step(cmpStmt) == SQLITE_ROW)
        {
            MTTrip *trip = [[MTTrip alloc] initWithLanguage:_language];
            
            trip.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 2)];
            trip.StopNumber = [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 4)] intValue];
            trip.Longitude = [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 7)] doubleValue];
            trip.Latitude = [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 6)] doubleValue];
            trip.StopName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 5)];
            trip.Language = _language;
            trip.TripId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 0)];
            trip.StopSequence = [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 3)] intValue];
            trip.Time.Time = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 1)];
            trip.Time.TripId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 0)];
            trip.Time.StopId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 2)];
            trip.Time.StopSequence = [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(cmpStmt, 3)] intValue];
            trip.Time.IsLive = NO;
            
            [trips addObject:trip];
        }
    }
    
    sqlite3_reset(cmpStmt);
    sqlite3_finalize(cmpStmt);
    
    return (trips.count > 0);
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
                         @"select distinct s.stop_id, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon, (select min(r2.route_id) from routes r2 where r2.route_short_name = f.route_id), r.route_short_name, r.route_type, f.route_direction, f.route_tripheading, f.updated, f.display_sequence \
                         from favorites f \
                         inner join stops s on s.stop_id = f.stop_id \
                         left join routes r on r.route_short_name = f.route_id \
                         order by f.display_sequence ASC"];
    
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
            
            //is stop favorite only?
            if(sqlite3_column_text(_cmpStmt, 5) == NULL)
            {
                stop.isFavorite = YES;
                
                //[self getRoutesForStop:stop];
                [self getRoutesForFavoriteStop:stop];
                
                [favorites addObject:stop];
                continue;
            }
            
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
        sqlite3_finalize(_cmpStmt);
        
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
        if(stop.isFavorite) //dont show notices affecting a whole stop
            continue;
        
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
    
    BOOL favoriteStop = NO;
    if(bus == nil)
        favoriteStop = YES;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         where %@",
                         @"f.*"
                         , @"favorites f"
                         , [NSString stringWithFormat:@"f.route_id = '%@' AND f.stop_id = '%@'", ((favoriteStop) ? @"" : bus.BusNumber), stop.StopId]];
        
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        if(sqlite3_step(_cmpStmt) == SQLITE_ROW)
        {
            if(favoriteStop)
                stop.isFavorite = YES;
            else bus.isFavorite = YES;
        }
    }
    sqlite3_reset(_cmpStmt);
    sqlite3_finalize(_cmpStmt);
        
    return (favoriteStop) ? stop.isFavorite : bus.isFavorite;
}

- (BOOL)addFavoriteUsingStop:(MTStop*)stop
                      AndBus:(MTBus*)bus
{
    if(!_isConnected)
        return NO;
    
    BOOL favoriteStop = NO;
    if(bus == nil) //favoriting the whole stop
        favoriteStop = YES;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"select %@ \
                         from %@ \
                         where %@",
                         @"f.*"
                         , @"favorites f"
                         , [NSString stringWithFormat:@"f.route_id = '%@' AND f.stop_id = '%@'"
                            , ((favoriteStop) ? @"" : bus.BusNumber)
                            , stop.StopId]];

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
            sqlite3_finalize(_cmpStmt);
            return NO;
        }
        
        sqlite3_reset(_cmpStmt);
        sqlite3_finalize(_cmpStmt);
        
        sqlStmt = [NSString stringWithFormat: \
                   @"INSERT INTO `favorites` \
                   (`stop_id`, `route_id`, `route_direction`, `route_tripheading`, `display_sequence`) \
                   VALUES ('%@','%@',%d,\"%@\",%d);"
                   , stop.StopId
                   , ((favoriteStop) ? @"" : bus.BusNumber)
                   , ((favoriteStop) ? -1 : [bus getBusHeadingForFavorites])
                   , ((favoriteStop) ? @"" : bus.DisplayHeading)
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
            sqlite3_finalize(_cmpStmt);
            
            if(result == SQLITE_DONE)
            {
                sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
                if(favoriteStop)
                    stop.isFavorite = YES;
                else bus.isFavorite = YES;
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
                         , bus.BusNumber];
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
        sqlite3_finalize(_cmpStmt);
        
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
    
    BOOL favoriteStop = NO;
    if(bus == nil)
        favoriteStop = YES;
    
    NSString *sqlStmt = [NSString stringWithFormat: \
                         @"delete from favorites \
                         where stop_id = '%@' AND route_id = '%@';"
                         , stop.StopId
                         , ((favoriteStop) ? @"" : bus.BusNumber)];
    
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
        sqlite3_finalize(_cmpStmt);
        
        if(result == SQLITE_DONE)
        {
            sqlite3_exec(_db, "COMMIT;", NULL, NULL, NULL);
            if(favoriteStop)
                stop.isFavorite = NO;
            else bus.isFavorite = NO;
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
                          , bus.BusNumber];
    
    sqlite3_stmt* _cmpStmt;
    if(sqlite3_prepare_v2(_db
                          , [sqlStmt UTF8String]
                          , -1
                          , &_cmpStmt
                          , NULL) == SQLITE_OK)
    {
        sqlite3_step(_cmpStmt);
        sqlite3_reset(_cmpStmt);
        sqlite3_finalize(_cmpStmt);
    }
    
    
    sqlite3_exec(_db, "BEGIN;", NULL, NULL, NULL);
    for(NSString *day in [times allKeys])
    {        
        for(NSDictionary *dic in [times objectForKey:day])
        {
            NSString * sqlStmt = [NSString stringWithFormat: \
                                  @"insert into stored_times \
                                  (day_of_week, arrival_time_ori, arrival_time, stop_id, trip_id, stop_sequence, start_date, end_date, next_update, route_id, end_stop) \
                                  VALUES \
                                  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
            
            if(sqlite3_prepare_v2(_db
                                  , [sqlStmt UTF8String]
                                  , -1
                                  , &_cmpStmt
                                  , NULL) == SQLITE_OK)
            {
                sqlite3_bind_text(_cmpStmt, 1, [[dic valueForKey:@"dayOfWeek"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 2, [[dic valueForKey:@"arrival_time"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 3, [[dic valueForKey:@"arrival_time"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 4, [[dic valueForKey:@"stop_id"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 5, [[dic valueForKey:@"trip_id"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(_cmpStmt, 6, [(NSNumber*)[dic valueForKey:@"stop_sequence"] intValue]);
                sqlite3_bind_text(_cmpStmt, 7, [[dic valueForKey:@"start_date"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 8, [[dic valueForKey:@"end_date"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 9, [[dic valueForKey:@"next_update"] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 10, [bus.BusId UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(_cmpStmt, 11, [[dic valueForKey:@"end_stop"] UTF8String], -1, SQLITE_TRANSIENT);
                
                int result = sqlite3_step(_cmpStmt);
                if(result != SQLITE_DONE)
                {
                    MTLog(@"Add Times Error: %s", sqlite3_errmsg(_db));
                    sqlite3_reset(_cmpStmt);
                    sqlite3_finalize(_cmpStmt);
                    sqlite3_exec(_db, "ROLLBACK;", NULL, NULL, NULL);   
                    return NO;
                }
                sqlite3_reset(_cmpStmt);
                sqlite3_finalize(_cmpStmt);
            }
            else
            {
                MTLog(@"Add Times Error: %s", sqlite3_errmsg(_db));
                sqlite3_reset(_cmpStmt);
                sqlite3_finalize(_cmpStmt);
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
        sqlite3_finalize(_cmpStmt);
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
