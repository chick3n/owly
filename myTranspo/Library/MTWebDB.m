//
//  MTWebDB.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-12.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTWebDB.h"

@interface MTWebDB()
- (NSURL*)appendUrlQuery:(NSString*)query, ...;
- (NSData*)webData:(NSURL*)url;
- (id)jsonData:(NSData *)data WithClassType:(Class)class;
@end

@implementation MTWebDB

#pragma mark - INITILIZATION

- (id)initWithUrlPath:(NSString*)urlPath
                  And:(MTLanguage)lang
{
    self = [super init];
    if(self)
    {
        _urlPath = [NSString stringWithString:urlPath];
        _url = [NSURL URLWithString:urlPath];
        _language = lang;
        _stopsLimit = MTDEF_STOPSLIMIT;
        _busLimit = MTDEF_BUSLIMIT;
        _locationDistance = MTDEF_LOCATIONDISTANCE;
    }
    
    return self;
}

//simple check to see if server is available
- (BOOL)connectToServer
{
    //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_urlPath]];
    //if(data == nil)
    //return NO;    
    return YES;
}

- (NSURL*)appendUrlQuery:(NSString*)query, ...
{
    va_list args;
    va_start(args, query);
    
    NSString *urlPath = [_urlPath stringByAppendingString:[[NSString alloc] initWithFormat:query arguments:args]];
    return [NSURL URLWithString:urlPath];
}

- (NSData*)webData:(NSURL*)url
{
    NSMutableURLRequest* chRequest = [NSMutableURLRequest requestWithURL:url 
															 cachePolicy: NSURLRequestReloadIgnoringCacheData 
														 timeoutInterval:MTDEF_CONNECTIONTIMEOUT];
    
	NSError* error = nil;
	NSData* xmlData = [NSURLConnection sendSynchronousRequest:chRequest returningResponse:nil error:&error];
    
	if(error)
	{
		MTLog(@"Failure to connect and gather XML data. %@", [error localizedFailureReason]);
		return nil;
	}
    
    return xmlData;
}

- (NSArray *)jsonData:(NSData *)data WithClassType:(Class)class
{
    if(data == nil)
    {
        MTLog(@"JSON Data Was Nil");
        return nil;
    }
    
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(json == nil)
    {
        MTLog(@"JSON FAILED %@", [error description]);
        return nil;
    }
    
    if(![json isKindOfClass:class])
        json = nil;
    
    return json;
}

#pragma mark - STOPS

- (BOOL)getRoutesForStop:(MTStop *)stop
{
    NSData* data = [self webData:[self appendUrlQuery:@"oc_routesForStop.php?stop=%@", stop.StopId]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //expecting array of stops
    for(NSDictionary *dic in json)
    {
        MTBus* bus = [[MTBus alloc] initWithLanguage:_language];
        
        bus.BusId = [dic valueForKey:@"route_id"];
        bus.BusNumber = [dic valueForKey:@"route_short_name"];
        bus.DisplayHeading = [dic valueForKey:@"trip_headsign"];
        bus.GPSTime = NO;
        
        [stop.BusIds addObject:bus];
    }
    
    return YES;  
}

/*oc_stops.php 
 $stop_id = $_GET['stop'];  */
- (BOOL)getStop:(MTStop *)stop
{
    NSData* data = [self webData:[self appendUrlQuery:@"oc_stops.php?stop=%@", stop.StopId]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //expecting array of stops
    for(NSDictionary *dic in json)
    {
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        break; //should always only be 1 result
    }
    
    return YES;    
}

- (BOOL)getStopsForBus:(MTBus *)bus
{
    NSData *data = [self webData:[self appendUrlQuery:@"oc_stopsForBus.php?route=%@", bus.BusId]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //1-to-many stops
    for(NSDictionary *dic in json)
    {
        MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
        
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        [bus.StopIds addObject:stop];
    }
    
    return YES;
}

- (BOOL)getAllStops:(NSMutableArray*)stops
{
    NSData *data = [self webData:[self appendUrlQuery:@"oc_stops.php"]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //1 to many stops
    for(NSDictionary *dic in json)
    {
        MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
        
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        [stops addObject:stop];
    }
    
    return YES;
}

- (BOOL)getAllStopsForBuses:(NSMutableArray *)buses
{
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
    //determine type of search
    uint searchType = 0; //0=route,1=stop_code,2=textsearch
    int code;
    NSScanner *scanner = [NSScanner scannerWithString:identifier];
    
    if([scanner scanInt:&code] && [scanner isAtEnd])
    {
        if(identifier.length <= 3)
            searchType = 0;
        else if(identifier.length == 4)
            searchType = 1;
        else return NO; //int value but to large
    }
    else
    {
        searchType = 2;
    }
    
    NSData* data = nil;
    
    switch (searchType) {
        case 0:
            data = [self webData:[self appendUrlQuery:@"oc_stopsForBusName.php?bus=%@&page=%d&limit=%d", identifier, (page-1)*_stopsLimit, _stopsLimit]];
            break;
        case 1:
            data = [self webData:[self appendUrlQuery:@"oc_stopsForStopCode.php?stop=%@&page=%d&limit=%d", identifier, (page-1)*_stopsLimit, _stopsLimit]];
            break;
        case 2:
            data = [self webData:[self appendUrlQuery:@"oc_stopsForStopName.php?stop=%@&page=%d&limit=%d", identifier, (page-1)*_stopsLimit, _stopsLimit]];
            break;
    }
    
    if(data == nil)
        return NO;
    
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    if(json == nil)
        return NO;
    
    for(NSDictionary *dic in json)
    {
        MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
        
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        [stops addObject:stop];
    }
    
    return YES;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
               Page:(int)page
{
    NSData *data = [self webData:[self appendUrlQuery:@"oc_stopsLimit.php?page=%d&limit=%d", (page-1)*_stopsLimit, _stopsLimit]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //1 to many stops
    for(NSDictionary *dic in json)
    {
        MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
        
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        [stops addObject:stop];
    }
    
    return YES;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
            NearLon:(double)lon 
             AndLat:(double)lat 
           Distance:(double)kms
{
    NSData *data = [self webData:[self appendUrlQuery:@"oc_stopsDistance.php?lat=%f&lon=%f&distance=%f", lat, lon, _locationDistance]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    //1 to many stops
    for(NSDictionary *dic in json)
    {
        MTStop *stop = [[MTStop alloc] initWithLanguage:_language];
        
        stop.StopId = [dic valueForKey:@"stop_id"];
        stop.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        stop.StopName = [dic valueForKey:@"stop_name"];
        stop.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        stop.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        
        [stops addObject:stop];
    }
    
    return YES;
}


#pragma mark - TIMES
//ToDo: update all times for the whole week, NSDate date and than determine the week for it.
- (BOOL)getStop:(MTStop*)stop 
          Route:(MTBus*)bus 
          Times:(NSDate*)date
        Results:(NSDictionary*)results
{
    if(stop == nil || bus == nil)
        return NO;
    
    [bus.Times clearTimes];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    /*NSData *data = [NSData dataWithContentsOfURL:[self appendUrlQuery:@"oc_stopRouteTimes.php?route=%@&stop=%@&date=%@"
                                                  , bus.BusId
                                                  , stop.StopId
                                                  , [dateFormatter stringFromDate:date]]];*/
    
    NSData *data = [self webData:[self appendUrlQuery:@"oc_stopRouteTimes.php?route=%@&stop=%@&date=%@"
                   , bus.BusId
                   , stop.StopId
                   , [dateFormatter stringFromDate:date]]];
    
    NSDictionary *json = (NSDictionary*)[self jsonData:data WithClassType:[NSDictionary class]];
    
    if(json == nil)
        return NO;
    
    NSMutableArray *dayPointer = nil;
    for(NSString *day in [json allKeys])
    {
        if([day isEqualToString:@"sunday"])
            dayPointer = bus.Times.TimesSun;
        else if([day isEqualToString:@"saturday"])
            dayPointer = bus.Times.TimesSat;
        else dayPointer = bus.Times.Times;
        
        for(NSDictionary *dic in [json objectForKey:day])
        {
            MTTime *time = [[MTTime alloc] init];
            
            time.TripId = [dic valueForKey:@"trip_id"];
            time.Time = [dic valueForKey:@"arrival_time"];
            time.StopId = [dic valueForKey:@"stop_id"];
            time.StopSequence = [[dic valueForKey:@"stop_sequence"] intValue];

            time.IsLive = NO;
            [dayPointer addObject:time];
        }
        
        bus.Times.TimesAdded = YES;
    }
        
    if(results)
        [(NSMutableDictionary*)results addEntriesFromDictionary:json];
    
    return YES;
}

- (BOOL)getTrips:(NSMutableArray*)trips 
         ForTrip:(NSString*)trip
{
    if(trip == nil || trips == nil)
        return NO;
    
    NSData *data = [self webData:[self appendUrlQuery:@"oc_tripTimes.php?trip=%@"
                                                  , trip]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    for(NSDictionary *dic in json)
    {
        MTTrip *trip = [[MTTrip alloc] initWithLanguage:_language];
        
        trip.StopId = [dic valueForKey:@"stop_id"];
        trip.StopNumber = [[dic valueForKey:@"stop_code"] intValue];
        trip.Longitude = [[dic valueForKey:@"stop_lon"] doubleValue];
        trip.Latitude = [[dic valueForKey:@"stop_lat"] doubleValue];
        trip.StopName = [dic valueForKey:@"stop_name"];
        trip.Language = _language;
        trip.TripId = [dic valueForKey:@"trip_id"];
        trip.StopSequence = [[dic valueForKey:@"stop_sequence"] intValue];
        trip.Time.Time = [dic valueForKey:@"arrival_time"];
        trip.Time.TripId = [dic valueForKey:@"trip_id"];
        trip.Time.StopId = [dic valueForKey:@"stop_id"];
        trip.Time.StopSequence = [[dic valueForKey:@"stop_sequence"] intValue];
        trip.Time.IsLive = NO;
        
        [trips addObject:trip];
    }
    
    return YES;
}

- (BOOL)getNextTrips:(NSMutableArray*)_trips
             ForStop:(MTStop*)stop
            ForRoute:(MTBus*)bus
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"e"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    int dayOfWeek = [[dateFormatter stringFromDate:[NSDate date]] intValue];
    
    NSMutableArray* times = nil;
    
    switch (dayOfWeek) {
        case 0: //Sunday
            times = bus.Times.TimesSun;
            break;
        case 6: //Saturday
            times = bus.Times.TimesSat;
            break;
        default:
            times = bus.Times.Times;
            break;
    }
    
    if(times == nil) //should never be here
    {
        if(![self getStop:stop Route:bus Times:[NSDate date] Results:nil])
            return NO;
    } 
    else if(times.count <= 0)
    {
        if(![self getStop:stop Route:bus Times:[NSDate date] Results:nil])
            return NO;
    }
    
    long compareTime = [[NSDate date] timeIntervalSince1970];
    uint nextTripsCount = 0;
    
    for(MTTime *time in times)
    {
        if(nextTripsCount >= 3)
            break;
        
        if([time getTimeInSeconds] > compareTime)
        {
            [_trips addObject:time];
            nextTripsCount += 1;
        }
    }
    
    if(_trips.count > 0)
        return YES;
    
    return NO;
}

- (BOOL)getPrevTrip:(MTTime*)trip
            ForStop:(MTStop*)stop
           ForRoute:(MTBus*)bus
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"e"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    
    int dayOfWeek = [[dateFormatter stringFromDate:[NSDate date]] intValue];
    
    NSMutableArray* times = nil;
    
    switch (dayOfWeek) {
        case 0: //Sunday
            times = bus.Times.TimesSun;
            break;
        case 6: //Saturday
            times = bus.Times.TimesSat;
            break;
        default:
            times = bus.Times.Times;
            break;
    }
    
    if(times == nil) //should never be here
    {
        if(![self getStop:stop Route:bus Times:[NSDate date] Results:nil])
            return NO;
    } 
    else if(times.count <= 0)
    {
        if(![self getStop:stop Route:bus Times:[NSDate date] Results:nil])
            return NO;
    }
    
    long compareTime = [[NSDate date] timeIntervalSince1970];
    MTTime* lastTime = nil;
    
    for(MTTime *time in times)
    {
        if([time getTimeInSeconds] > compareTime)
        {
            break;
        }
        
        lastTime = time;
    }
    
    if(lastTime != nil)
        return YES;
    
    return NO;
}

#pragma mark - NOTICES

- (BOOL)getBusNotices:(NSMutableArray*)notices
{
    return NO;
}

- (BOOL)getRoutesForNotices:(NSMutableArray*)notices
{
    return NO;
}

@end
