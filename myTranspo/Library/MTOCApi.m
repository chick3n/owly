//
//  MTOCApi.m
//  myTranspoOC - This is direct access to the external API provided by OC Transpo
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTOCApi.h"

@interface MTOCApi ()
- (NSString *)createSoapRequest:(NSDictionary *)dic;
- (NSData *)sendSoapRequest:(NSString*)soap WithAction:(NSString *)action;
@end

@implementation MTOCApi

@synthesize UrlPath                     = _urlPath;


#pragma mark - INITILIZATION

- (id)initWithLanguage:(MTLanguage)lang
            AndUrlPath:(NSString*)urlPath
           UsingAPIKey:(NSString*)apiKey 
    UsingApplicationID:(NSString*)appId
{
    self = [super init];
    if(self)
    {
        _language = lang;
        _urlPath = [NSString stringWithString:urlPath];
        _url = [NSURL URLWithString:_urlPath];
        _isAvailable = NO;
        _apiKey = [NSString stringWithString:apiKey];
        _applicationId = appId;
    }
    
    return self;
}

- (NSString *)createSoapRequest:(NSDictionary *)dic
{
    NSString *header = [dic valueForKey:@"header"];
    
    NSMutableString *query = [[NSMutableString alloc] initWithString:@""];
    
    [query appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
    "xmlns:soap=\"http://schema.xmlsoap.org/soap/envelope/\">"
     "<soap:Body>"];
    [query appendFormat:@"<%@ xmlns=\"http://octranspo.com\">", header];
    
    for(NSString* key in [dic allKeys])
    {
        if([key isEqualToString:@"header"])
            continue;
        
        [query appendFormat:@"<%@>%@</%@>", key, [dic valueForKey:key], key];
    }    
    
    [query appendFormat:@"</%@>", header];
    [query appendString:@"</soap:Body></soap:Envelope>"];
    
    return query;
}

- (NSData *)sendSoapRequest:(NSString*)soap 
                 WithAction:(NSString *)action
{
    NSData* postData = [soap dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[_url URLByAppendingPathComponent:action]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:MTDEF_CONNECTIONTIMEOUT];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSURLResponse* response;
    NSError* error;
    
    NSData* result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    if(result == nil)
    {
        MTLog(@"Soap Failed: %@", [error localizedDescription]);
    }
    
    
    return result;    
}

#pragma mark - STOPS
//TODO: Update DirectionID to = which direction and also determine if we want to use inbound etc
- (BOOL)getRoutesForStop:(MTStop *)stop
{
   /* NSData* xmlData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GetRouteStopsAPISample" ofType:@"xml"]];
    NSDictionary* nsMappings = [NSDictionary dictionaryWithObject:@"http://tempuri.org/" forKey:@"tu"];
    NSError* error;
    CXMLDocument *xmlDocument = [[CXMLDocument alloc] initWithData:xmlData
                                                           options:0
                                                             error:&error];
    
    if(xmlDocument == nil && error != nil)
    {
        MTLog(@"XML Error: %@", [error localizedDescription]);
        return NO;
    }
    
    CXMLNode* errorNode = [xmlDocument nodeForXPath:@"{http://tempuri.org/}:RoutesForStopData/{http://tempuri.org/}:Error" error:&error];
    if(error != nil)
    {
        MTLog(@"XML Error:%@", [error localizedDescription]);
        return NO;
    }
    
    if(errorNode != nil)
    {
        if([errorNode.stringValue length] > 0)
        {
            MTLog(@"Error Node for path:%@\nResponse:%@", @"RoutesForStopData/Error", [error localizedDescription]);
            return NO;
        }
    }
        
    NSArray* resultNodes = [xmlDocument nodesForXPath:@"/tu:RoutesForStopData/tu:Routes/tu:Route" 
                                    namespaceMappings:nsMappings
                                                error:&error];

    
    if(resultNodes == nil && error != nil)
    {
        MTLog(@"XML Nodes Error: %@", [error localizedDescription]);
        return NO;
    }
    
    */
    
    /*NSString *soapRequest = [self createSoapRequest:@"GetRouteSummaryForStop"
     , @"stopNo"
     , [NSString stringWithFormat:@"%d", stop.StopNumber]
     , @"apiKey"
     , _apiKey];
     NSData* xmlData = [self sendSoapRequest:soapRequest WithAction:@"GetRouteSummaryForStop"];
     
     if(xmlData == nil)
     return NO;
     
     */
    
    NSData* xmlData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GetRouteStopsAPISample" ofType:@"xml"]];
    NSDictionary *xmlDic = [XMLReader dictionaryForXMLData:xmlData error:nil];
    
    if(xmlDic == nil)
    {
        MTLog(@"XML Data Error");
        return NO;
    }
    
    if([xmlDic valueForKeyPath:@"RoutesForStopData.Error"] != nil)
    {
        NSString *queryError = [xmlDic valueForKeyPath:@"RoutesForStopData.Error"];
        if(queryError.length > 0)
        {
            MTLog(@"RoutesForStopData Error: %@", queryError);
            return NO;
        }
    }
       
    
    for(NSDictionary *route in [xmlDic valueForKeyPath:@"RoutesForStopData.Routes.Route"])
    {
        MTBus *bus = [[MTBus alloc] initWithLanguage:_language];
        
        bus.BusNumber = [route valueForKey:@"RouteNo"];
        bus.DisplayHeading = [route valueForKey:@"RouteHeading"];
        
        NSString *directionId = [route valueForKey:@"DirectionID"];
        
        if(directionId.length > 0)
        {
            switch ([directionId intValue]) {
                case 0:
                    bus.BusHeading = MTDIRECTION_EAST;
                    break;
                case 1:
                    bus.BusHeading = MTDIRECTION_WEST;
                    break;
                case 2:
                    bus.BusHeading = MTDIRECTION_NORTH;
                    break;
                case 3:
                    bus.BusHeading = MTDIRECTION_SOUTH;
                    break;
            }
        }
        
        [stop.BusIds addObject:bus];
    }
    
    return YES;
}

- (BOOL)getStop:(MTStop *)stop
{
    return NO;
}

- (BOOL)getStopsForBus:(MTBus *)bus
{
    return NO;
}

- (BOOL)getAllStops:(NSMutableArray*)stops
{
    return NO;
}

- (BOOL)getAllStopsForBuses:(NSMutableArray *)buses
{
    return NO;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
               With:(NSString*)identifier
               Page:(int)page
{
    return NO;
}

- (BOOL)getAllStops:(NSMutableArray *)stops 
               Page:(int)page
{
    return NO;
}

#pragma mark - TIMES

- (BOOL)getStop:(MTStop*)stop 
          Route:(MTBus*)bus 
          Times:(NSDate*)date
        Results:(NSDictionary*)results
{
    if(stop == nil || bus == nil)
        return NO;
    
    //is the date request today?
    if(![MTHelper IsDateToday:date])
        return NO;
    
    if(stop.cancelQueue || bus.cancelQueue)
        return NO;

    NSData* xmlData = [self sendSoapRequest:[NSString stringWithFormat:@"appID=%@&apiKey=%@&routeNo=%@&stopNo=%d"
                                             , _applicationId
                                             , _apiKey
                                             , bus.BusNumber
                                             , stop.StopNumber]
                                 WithAction:@"GetNextTripsForStop"];
     
     if(xmlData == nil)
         return NO;
    
    NSDictionary *xmlDic = [XMLReader dictionaryForXMLData:xmlData error:nil];
    
    if(xmlDic == nil)
    {
        MTLog(@"XML Data Error");
        return NO;
    }
    
    if([xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Error"] != nil)
    {
        NSString *queryError = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Error"];
        if(queryError.length > 0)
        {
            MTLog(@"StopInfoData Error: %@", queryError);
            return NO;
        }
    }
    
    [bus clearLiveTimes];
    
    //we now have to determine which bus we want because you can only pass it a stop & a number, in most cases this will return 1 bus however
    //at larger stops BASELINE STATION for example the bus 95 goes both ways. Based on the data given we can take 2 approaches:
    //1 compare bus number and route label
    //2 compare bus number and direction if step 1 fails?

    NSArray *routes = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Route.RouteDirection.node"]; 
    if(routes == nil)
    {
        NSDictionary* tmpRoutes = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Route.RouteDirection"];
        if(tmpRoutes == nil)
            return NO;
        routes = [NSArray arrayWithObject:tmpRoutes]; //only 1 routedirection
    }
    NSArray *trips = nil; //trip match
    
    for(NSDictionary *routeDirection in routes)
    {
        if([routeDirection valueForKey:@"Error"] != nil)
        {
            NSString *queryError = [routeDirection valueForKey:@"Error"];
            if(queryError.length > 0)
            {
                MTLog(@"StopInfoData.Route.RouteDirection Error: %@", queryError);
                continue; //just because a route errors doesnt mean the others will, if other exist
            }
        }
        
        //check number & route label
        NSString *routeNumber = [routeDirection valueForKey:@"RouteNo"];
        NSString *routeLabel = [routeDirection valueForKey:@"RouteLabel"];
        NSString *routeHeading = [routeDirection valueForKey:@"Direction"];
        
        if(routeNumber == nil || routeLabel == nil) //not possible?
            continue;
        
        if(routeHeading != nil)
            bus.BusHeading = [MTHelper convertOCBusHeading:routeHeading];
        
        if([bus.BusNumber isEqualToString:routeNumber] && [bus.DisplayHeading isEqualToString:routeLabel])
        {
            trips = [routeDirection valueForKeyPath:@"Trips.Trip.node"];
            if(trips != nil)
                break;
        }
        
        //didnt break, didnt find it
        if([bus.BusNumber isEqualToString:routeNumber] && [[bus getBusHeadingOCStyle] isEqualToString:routeHeading])
        {
            trips = [routeDirection valueForKeyPath:@"Trips.Trip.node"];
            if(trips != nil)
                break;
        }
    }

    NSMutableArray *_trips = [[NSMutableArray alloc] init];
    if(trips != nil && trips.count > 0)
    {
        NSDateFormatter *dateFormatter = [MTHelper TimeFormatter];
        
        for(NSDictionary *trip in trips)
        {
            MTTime* newTrip = [[MTTime alloc] init];
            //MTTrip* newTrip = [[MTTrip alloc] initWithLanguage:_language];
            
            NSString *destination = [trip valueForKey:@"TripDestination"];
            if(destination != nil)
            {
                bus.TrueDisplayHeading = destination;
                newTrip.EndStopHeader = destination;
            }
            
            NSString *GPSSpeed = [trip valueForKey:@"GPSSpeed"];
            if(GPSSpeed != nil)
                bus.BusSpeed = [NSString stringWithFormat:@"%d km/h", [GPSSpeed intValue]];
            
            //Is GPS?
            if([trip objectForKey:@"AdjustmentAge"] != nil)
            {
                if([(NSString*)[trip valueForKey:@"AdjustmentAge"] floatValue] >= 0.0)
                {
                    newTrip.IsLive = YES;
                    //GPS Time            
                    NSTimeInterval minutesAdjusted = ([trip objectForKey:@"AdjustedScheduleTime"] != nil) ? [[trip objectForKey:@"AdjustedScheduleTime"] doubleValue] * 60 : 0;
                    newTrip.Time = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:minutesAdjusted]];
                    newTrip.Time = [MTHelper convertOC24HourTime:newTrip.Time];
                    MTLog(@"GPS Live Time: %@", newTrip.Time);
                }
                else
                {
                    newTrip.IsLive = NO;
                    //GPS Time            
                    NSTimeInterval minutesAdjusted = ([trip objectForKey:@"AdjustedScheduleTime"] != nil) ? [[trip objectForKey:@"AdjustedScheduleTime"] doubleValue] * 60 : 0;
                    newTrip.Time = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:minutesAdjusted]];
                    newTrip.Time = [MTHelper convertOC24HourTime:newTrip.Time];
                    MTLog(@"GPS Schedule Time: %@", newTrip.Time);
                }
            }
            else
            {
                return NO;
            }
            
            [_trips addObject:newTrip];
        }
        
        [bus addLiveTimes:_trips];
    }
    
    return (_trips.count);
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

//ToDo: Bus Type
- (BOOL)getNextTrips:(NSMutableArray*)_trips
             ForTrip:(MTTrip*)stop
            ForRoute:(MTBus*)bus
{
    if(_trips == nil || stop == nil || bus == nil)
        return NO;
    
    if(stop.cancelQueue || bus.cancelQueue)
        return NO;
    
    NSData* xmlData = [self sendSoapRequest:[NSString stringWithFormat:@"appID=%@&apiKey=%@&routeNo=%@&stopNo=%d"
                                             , _applicationId
                                             , _apiKey
                                             , bus.BusNumber
                                             , stop.StopNumber]
                                                            WithAction:@"GetNextTripsForStop"];
    
    if(xmlData == nil)
        return NO;
    
    NSDictionary *xmlDic = [XMLReader dictionaryForXMLData:xmlData error:nil];
    
    if(xmlDic == nil)
    {
        MTLog(@"XML Data Error");
        return NO;
    }
    
    if([xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Error"] != nil)
    {
        NSString *queryError = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Error"];
        if(queryError.length > 0)
        {
            MTLog(@"GetNextTripsForStopResult Error: %@", queryError);
            return NO;
        }
    }
    
    
    [bus clearLiveTimes];
    
    //we now have to determine which bus we want because you can only pass it a stop & a number, in most cases this will return 1 bus however
    //at larger stops BASELINE STATION for example the bus 95 goes both ways. Based on the data given we can take 2 approaches:
    //1 compare bus number and route label
    //2 compare bus number and direction if step 1 fails?
    
    NSArray *routes = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Route.RouteDirection.node"]; 
    if(routes == nil)
    {
        NSDictionary* tmpRoutes = [xmlDic valueForKeyPath:@"GetNextTripsForStopResult.Route.RouteDirection"];
        if(tmpRoutes == nil)
            return NO;
        routes = [NSArray arrayWithObject:tmpRoutes]; //only 1 routedirection
    }
    NSArray *trips = nil; //trip match
    
    for(NSDictionary *routeDirection in routes)
    {
        if([routeDirection valueForKey:@"Error"] != nil)
        {
            NSString *queryError = [routeDirection valueForKey:@"Error"];
            if(queryError.length > 0)
            {
                MTLog(@"StopInfoData.Route.RouteDirection Error: %@", queryError);
                continue; //just because a route errors doesnt mean the others will, if other exist
            }
        }
        
        //check number & route label
        NSString *routeNumber = [routeDirection valueForKey:@"RouteNo"];
        NSString *routeLabel = [routeDirection valueForKey:@"RouteLabel"];
        NSString *routeHeading = [routeDirection valueForKey:@"Direction"];
        
        if(routeNumber == nil || routeLabel == nil) //not possible?
            continue;
        
        if([bus.BusNumber isEqualToString:routeNumber] && [bus.DisplayHeading isEqualToString:routeLabel])
        {
            trips = [routeDirection valueForKeyPath:@"Trips.Trip.node"];
            if(trips != nil)
                break;
        }
        
        //didnt break, didnt find it
        if([bus.BusNumber isEqualToString:routeNumber] && [[bus getBusHeadingOCStyle] isEqualToString:routeHeading])
        {
            trips = [routeDirection valueForKeyPath:@"Trips.Trip.node"];
            if(trips != nil)
                break;
        }
    }
    
    if(trips != nil && trips.count > 0)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
        
        for(NSDictionary *trip in trips)
        {
            //MTTime* newTrip = [[MTTime alloc] init];
            MTTrip* newTrip = [[MTTrip alloc] initWithLanguage:_language];
            
            //Is GPS?
            if([trip objectForKey:@"AdjustmentAge"] != nil)
            {
                if([(NSString*)[trip valueForKey:@"AdjustmentAge"] floatValue] >= 0.0)
                    newTrip.Time.IsLive = YES;
                else
                    return NO; //no API, why do we want this data than?
            }
            else
            {
                return NO; //no API, why do we want this data than?
            }
            
            
            newTrip.Destination = ([trip valueForKey:@"TripDestination"] != nil) ? [trip valueForKey:@"TripDestination"] : @"";
            newTrip.StartTime = ([trip valueForKey:@"TripStartTime"] != nil) ? [trip valueForKey:@"TripStartTime"] : @"";
            
            newTrip.LastTrip = NO;
            NSString *sLastTrip = [trip valueForKey:@"LastTripOfSchedule"];
            if(sLastTrip != nil)
            {
                if([sLastTrip isEqualToString:@"false"])
                    newTrip.LastTrip = NO;
                else newTrip.LastTrip = YES;
            }
            
            //Bus Type here
            
            //GPS Time
            NSTimeInterval minutesAdjusted = ([trip objectForKey:@"AdjustedScheduleTime"] != nil) ? [[trip objectForKey:@"AdjustedScheduleTime"] doubleValue] * 60 : 0;
            newTrip.Time.Time = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:minutesAdjusted]];
            
            MTLog(@"GPSTime Trip: %@ Live: %d", newTrip.Time.Time, newTrip.Time.IsLive);

            newTrip.BusSpeed = ([trip valueForKey:@"Speed"] != nil) ? [(NSString*)[trip valueForKey:@"Speed"] floatValue] : 0.0;
            newTrip.Latitude = ([trip valueForKey:@"Latitude"] != nil) ? [(NSString*)[trip valueForKey:@"Latitude"] doubleValue] : 0.0;
            newTrip.Longitude = ([trip valueForKey:@"Longitude"] != nil) ? [(NSString*)[trip valueForKey:@"Longitude"] doubleValue] : 0.0;
            
            [_trips addObject:newTrip];
        }
    }
    
    return (_trips.count > 0);
}

- (BOOL)getPrevTrip:(MTTime*)trip
            ForStop:(MTStop*)stop
           ForRoute:(MTBus*)bus
{
    return NO;
}

@end
