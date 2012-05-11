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
- (NSURL*)appendQuery:(NSString*)query, ...;
- (NSData*)webData:(NSURL*)url;
- (id)jsonData:(NSData *)data WithClassType:(Class)class;
- (NSMutableURLRequest *) multipartRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) dictionary;
- (NSData*)webDataWithURLRequest:(NSURLRequest*)request;
- (void)sanitizeJsonDictionary:(NSMutableDictionary*)dic;
- (void)sanitizeJsonArray:(NSMutableArray*)arr;
@end

@implementation MTWebDB
@synthesize isSet;

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

- (NSURL*)appendQuery:(NSString*)query, ...
{
    va_list args;
    va_start(args, query);
    
    NSString *urlPath = [[NSString alloc] initWithFormat:query arguments:args];
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

- (NSData*)webDataWithURLRequest:(NSURLRequest*)request
{
    if(request == nil)
        return nil;
    
	NSError* error = nil;
	NSData* xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
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
    
    if(json != nil)
    {
        if(class == [NSArray class])
            [self sanitizeJsonArray:json];
        else if(class == [NSDictionary class])
            [self sanitizeJsonDictionary:json];
    }
    
    return json;
}

/** Creates a multipart HTTP POST request.
 *  @param url is the target URL for the POST request
 *  @param dictionary is a key/value dictionary with the DATA of the multipart post.
 *  
 *  Should be constructed like:
 *      NSArray *keys = [[NSArray alloc] initWithObjects:@"login", @"password", nil];
 *      NSArray *objects = [[NSArray alloc] initWithObjects:@"TheLoginName", @"ThePassword!", nil];    
 *      NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
 */
- (NSMutableURLRequest *) multipartRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) dictionary
{
    // Create POST request
    NSMutableURLRequest *mutipartPostRequest = [NSMutableURLRequest requestWithURL:url 
                                                                       cachePolicy:NSURLCacheStorageAllowed
                                                                   timeoutInterval:MTDEF_CONNECTIONTIMEOUT];
    [mutipartPostRequest setHTTPMethod:@"POST"];
    
    // Add HTTP header info
    // Note: POST boundaries are described here: http://www.vivtek.com/rfc1867.html
    // and here http://www.w3.org/TR/html4/interact/forms.html
    NSString *POSTBoundary = [NSString stringWithString:@"0xHttPbOuNdArY"]; // You could calculate a better boundary here.
    [mutipartPostRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", POSTBoundary] forHTTPHeaderField:@"Content-Type"];
    
    // Add HTTP Body
    NSMutableData *POSTBody = [NSMutableData data];
    [POSTBody appendData:[[NSString stringWithFormat:@"--%@\r\n",POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add Key/Values to the Body
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    NSString *key;
    
    while ((key = [enumerator nextObject])) {
        [POSTBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [POSTBody appendData:[[NSString stringWithFormat:@"%@", [dictionary objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (key != nil) {
            [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    // Add the closing -- to the POST Form
    [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
    
    // Add the body to the mutipartPostRequest & return
    [mutipartPostRequest setHTTPBody:POSTBody];
    return mutipartPostRequest;
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
    
    static double ticksToNanoseconds = 0.0;
    uint64_t startTime = mach_absolute_time();
    
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
    int dayOfWeek = 0;
    for(NSString *day in [json allKeys])
    {
        if([day isEqualToString:@"sunday"])
            dayPointer = bus.Times.TimesSun, dayOfWeek = 2;
        else if([day isEqualToString:@"saturday"])
            dayPointer = bus.Times.TimesSat, dayOfWeek = 1;
        else dayPointer = bus.Times.Times, dayOfWeek = 0;
        
        for(NSDictionary *dic in [json objectForKey:day])
        {
            MTTime *time = [[MTTime alloc] init];
            
            time.TripId = ([dic objectForKey:@"trip_id"] == [NSNull null]) ? @"" : [dic valueForKey:@"trip_id"];
            time.Time = ([dic objectForKey:@"arrival_time"] == [NSNull null]) ? @"" : [dic valueForKey:@"arrival_time"];
            time.StopId = ([dic objectForKey:@"stop_id"] == [NSNull null]) ? @"" : [dic valueForKey:@"stop_id"];
            time.StopSequence = [[dic valueForKey:@"stop_sequence"] intValue];
            time.EndStopHeader = ([dic objectForKey:@"end_stop"] == [NSNull null]) ? @"" : [dic valueForKey:@"end_stop"];
            time.dayOfWeek = dayOfWeek;
            
            time.IsLive = NO;
            [dayPointer addObject:time];
        }
        
        bus.Times.TimesAdded = YES;
    }
        
    if(results)
        [(NSMutableDictionary*)results addEntriesFromDictionary:json];
    
    uint64_t endTime = mach_absolute_time();
    uint64_t elapsedTime = endTime - startTime;
    if(0.0 == ticksToNanoseconds)
    {
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    }
    
    NSLog(@"Time Elapsed: %f", elapsedTime * ticksToNanoseconds);
    
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

- (BOOL)getNotices:(NSMutableDictionary*)notices ForLanguage:(MTLanguage)language
{
    
    NSData* data = [self webData:[self appendUrlQuery:((language == MTLANGUAGE_FRENCH) ? @"oc_notices_fr.php" : @"oc_notices.php")]];
    NSDictionary *json = [self jsonData:data WithClassType:[NSDictionary class]];
    
    if(json == nil)
        return NO;
    
    [notices addEntriesFromDictionary:json];
    
    return YES;
}

- (BOOL)getRoutesForNotices:(NSMutableArray*)notices
{
    NSData* data = [self webData:[self appendUrlQuery:@"oc_routeNotices.php"]];
    NSArray *json = [self jsonData:data WithClassType:[NSArray class]];
    
    if(json == nil)
        return NO;
    
    [notices addObjectsFromArray:json];
    
    return YES;
}

#pragma mark - Trip Planner

/******
    1. Pass in url to oc.com and get html results
    2. Pass results to vicestudios.com to parse and return parsed data (easier to parse in PHP than iOS
 */
- (BOOL)getOCTripPlanner:(MTTripPlanner*)tripPlanner WithResults:(NSMutableDictionary*)results
{
    if(tripPlanner == nil)
        return NO;
    
    if(results == nil)
        return NO;
    //http://octranspo.com/mobileweb/jnot/post.details.tripplan.oci?origin=21+gospel+oak&originRegion=OTTA&destination=99+bank+st&destinationRegion=OTTA&timeType=3&hour=6&minute=20&pm=True&day=20120423&accessible=on&regularFare=on&excludeSTO=on&bicycles=on&lang=en&action=Search
    //http://octranspo.com/mobileweb/jnot/post.details.tripplan.oci?origin=21+gospel+oak&originRegion=OTTA&destination=99+bank+st&destinationRegion=OTTA&timeType=4&hour=6&minute=20&pm=True&day=20120423&accessible=on&regularFare=on&excludeSTO=on&bicycles=on&lang=en&action=Search
    //http://octranspo.com/mobileweb/jnot/post.details.tripplan.oci?origin=21+gospel+oak&originRegion=OTTA&destination=99+bank+st&destinationRegion=OTTA&timeType=3&hour=6&minute=20&pm=False&day=20120423&accessible=on&regularFare=on&excludeSTO=on&bicycles=on&lang=en&action=Search
    //http://octranspo.com/mobileweb/jnot/post.details.tripplan.oci?origin=21+gospel+oak&originRegion=OTTA&destination=99+bank+st&destinationRegion=OTTA&timeType=3&hour=6&minute=20&pm=False&day=20120423&regularFare=on&excludeSTO=on&bicycles=on&lang=en&action=Search
    
    NSString* url = @"http://octranspo.com/mobileweb/jnot/post.details.tripplan.oci?origin=%@&originRegion=OTTA&destination=%@&destinationRegion=OTTA&timeType=%@&hour=%@&minute=%@&pm=%@&day=%@&accessible=%@&regularFare=%@&excludeSTO=%@&bicycles=%@&lang=%@&action=Search";
    
    NSDateComponents* comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:tripPlanner.arriveBy];
    comp.timeZone = [NSTimeZone localTimeZone];
    
    NSString* hour;
    NSString* nightTime; //am
    
    //modify minute to be in future based on OC 10 min intervals
    int remainder = comp.minute % 10;
    if(remainder > 0)
    {
        int diff = 10 - remainder;
        comp.minute += diff;
    }
    
    if(comp.hour > 12) //pm
    {
        nightTime = @"True";
        if(comp.hour == 12)
            hour = [NSString stringWithFormat:@"%d", comp.hour];
        else hour = [NSString stringWithFormat:@"%d", comp.hour - 12];
    }
    else {
        nightTime = @"False"; //am
        hour = [NSString stringWithFormat:@"%d", comp.hour];
    }
    
    NSString *day;
    NSString *month;
    
    if(comp.day < 10)
        day = [NSString stringWithFormat:@"0%d", comp.day];
    else day = [NSString stringWithFormat:@"%d", comp.day];
    
    if(comp.month < 10)
        month = [NSString stringWithFormat:@"0%d", comp.month];
    else month = [NSString stringWithFormat:@"%d", comp.month];
    
    NSURL* callUrl = [self appendQuery:url
                      , [tripPlanner.startingLocation URLEncodedString]
                      , [tripPlanner.endingLocation URLEncodedString]
                      , (tripPlanner.departBy) ? @"3" : @"4"
                      , hour
                      , [NSString stringWithFormat:@"%d", comp.minute]
                      , nightTime
                      , [NSString stringWithFormat:@"%d%@%@", comp.year, month, day]
                      , (tripPlanner.accessible) ? @"on" : @"off"
                      , (tripPlanner.regulareFare) ? @"on" : @"off"
                      , (tripPlanner.excludeSTO) ? @"on" : @"off"
                      , (tripPlanner.bikeRack) ? @"on" : @"off"
                      , (_language == MTLANGUAGE_FRENCH) ? @"fr" : @"en"];
    
#if 1
    NSData *data = [self webData:callUrl];
    if(data == nil)
    {
        return NO;
    }
    
    NSString *file = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
#endif

#if 0 //used for basic testing
    NSError* error = nil;
    NSString* file = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tripplanner.html" ofType:nil] encoding:NSUTF8StringEncoding error:&error];
    if(error)
	{
		MTLog(@"create file. %@", [error localizedFailureReason]);
		return NO;
	}
    //http://www.vicestudios.com/apps/owly/oc/oc_tripPlanner.php
    //http://192.168.0.38/oc/oc_tripPlanner.php
#endif
    NSURL* postUrl = nil;
    if(_language == MTLANGUAGE_FRENCH)
        postUrl = [NSURL URLWithString:@"http://www.vicestudios.com/apps/owly/oc/oc_tripPlannerFr.php"];
    else postUrl = [NSURL URLWithString:@"http://www.vicestudios.com/apps/owly/oc/oc_tripPlanner.php"];
    
    if(tripPlanner.cancelQueue)
        return NO;
    
    NSDictionary* post = [NSDictionary dictionaryWithObjectsAndKeys:file, @"DATA", nil];
    NSMutableURLRequest* request = [self multipartRequestWithURL:postUrl andDataDictionary:post];
      
	NSData* xmlData = [self webDataWithURLRequest:request];
    NSDictionary* json = [self jsonData:xmlData WithClassType:[NSDictionary class]];
    
    if(json != nil)
    {
        [results addEntriesFromDictionary:json];
        return YES;
    }
    
    MTLog(@"getOCTripPlanner json failed.");
    return NO;
}

- (void)sanitizeJsonDictionary:(NSMutableDictionary*)dic
{
    if(dic == nil)
        return;
    
    MTLog(@"Sanitizing Dictionary");
    NSArray* keys = [dic allKeys];
    for(NSString* key in keys)
    {
        id obj = [dic objectForKey:key];
        
        if([obj class] == [NSMutableArray class])
            [self sanitizeJsonArray:(NSMutableArray*)obj];
        else if([obj class] == [NSMutableDictionary class])
            [self sanitizeJsonDictionary:(NSMutableDictionary*)obj];
        else if([obj class] == [NSNull class])
        {
            MTLog(@"Santizing Key: %@", key);
            [dic setValue:@"" forKey:key];
        }
    }
}

- (void)sanitizeJsonArray:(NSMutableArray*)arr
{
    if(arr == nil)
        return;
    
    MTLog(@"Sanitizing Array");
    for(int x=0; x<arr.count; x++)
    {
        id obj = [arr objectAtIndex:x];
        
        if([obj class] == [NSMutableArray class])
            [self sanitizeJsonArray:(NSMutableArray*)obj];
        else if([obj class] == [NSMutableDictionary class])
            [self sanitizeJsonDictionary:(NSMutableDictionary*)obj];
        else if([obj class] == [NSNull class])
        {
            MTLog(@"Sanitizing index: %d", x);
            [arr replaceObjectAtIndex:x withObject:@""];
        }
    }
}

@end
