//
//  myTranspoOC.m
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//


#import "myTranspoOC.h"

#define MTLDEF_BGQUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define MTLDEF_MAINQUEUE dispatch_get_main_queue()

@interface myTranspoOC ()
- (void)initializeLocationManager;
@end

@implementation myTranspoOC

@synthesize Language       = _language;
@synthesize DBPath         = _dbPath;
@synthesize TranspoType    = _transpoType;
@synthesize WebDBPath      = _webDbPath;
@synthesize delegate       = _delegate;
@synthesize coordinates    = _coordinates;
@synthesize City           = _city;

- (id)initWithLanguage:(MTLanguage)lang 
             AndDBPath:(NSString *)dbpath 
               ForCity:(MTCity)city
{
    self = [super init];
    if (self) {
        _language = lang;
        _city = city;
        _transpoType = [MTHelper transpoTypeBasedOnCity:city];
        _dbPath = [NSString stringWithString:dbpath];
        _hasDB = NO;
        _hasAPI = NO;
        _hasWebDb = NO;
        _isConnected = YES;
        //_queue = [[NSOperationQueue alloc] init];
        //_queue = dispatch_queue_create("com.vice.ocqueue", NULL); //serial queue (FIFO)
        _queue = MTLDEF_BGQUEUE; //concurrent queue
        
        [self initializeLocationManager];
        
        if(![self validateData])
            return nil;
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
}

#pragma mark - INTERNAL METHOD CHECKS

- (BOOL)validateData
{
    
    if(_transpoType == MTTRANSPOTYPE_UNKNOWN)
    {
        MTLog(@"Transpo Type was set to unknown");
        return NO;
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:_dbPath])
    {
        _hasDB = NO;
        MTLog(@"Database was not found: %@", _dbPath);
    }
    else
    {
        _ocDb = [[MTOCDB alloc] initWithDBPath:_dbPath And:_language];
        _hasDB = YES;
    }
    
    return YES;
}

- (BOOL)addWebDBPath:(NSString*)urlPath
{
    _webDbPath = [NSString stringWithString:urlPath];
    
    _ocWebDb = [[MTWebDB alloc] initWithUrlPath:_webDbPath And:_language];
    
    if(![_ocWebDb connectToServer])
        return NO;
    
    _hasWebDb = YES;
    return YES;
}

- (BOOL)addAPI
{
    switch(_transpoType)
    {
        case MTTRANSPOTYPE_OC:
            _hasAPI = YES;
            _ocApi = [[MTOCApi alloc] initWithLanguage:_language AndUrlPath:@"https://api.octranspo1.com/v1.0/" UsingAPIKey:@"2010d75153a9bbfd1d4db0a1db70fcd0" UsingApplicationID:@"4d8b9165"];
            return YES;
        default: break;
    }
    
    return NO;
}

- (void)kill
{
    [self turnOffLocationTracking];
    
    _ocApi = nil;
    _ocDb = nil;
    _ocWebDb = nil;
    
    dispatch_suspend(_queue);
    dispatch_release(_queue);
}

#pragma mark - LOCATION MANAGER

- (void)initializeLocationManager
{
    switch (_city) {
        case MTCITYOTTAWA:
            _coordinates = kDefaultCoordinatesOttawa;
            break;
        default:
            _coordinates = kDefaultCoordinatesOttawa;
            break;
    }
    
	_locationManager = [[CLLocationManager alloc] init];
	
	if([CLLocationManager locationServicesEnabled])
	{
		_locationManager.delegate = self;
		_locationManager.distanceFilter = kCLDistanceFilterNone;
		_locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
		_locationManager.purpose = @"Users Location";
	}
}

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation 
{
    MTLog(@"Received location, update variables");
    _coordinates = newLocation.coordinate;
    _hasRealCoordinates = YES;
    if([_delegate respondsToSelector:@selector(myTranspo:State:updatedUserCoordinates:)])
        [_delegate myTranspo:self State:MTRESULTSTATE_SUCCESS updatedUserCoordinates:newLocation.coordinate];
}

- (void)locationManager:(CLLocationManager *)manager 
	   didFailWithError:(NSError *)error 
{
    MTLog(@"Location Manager Error: %@", [error description]);
    //_coordinates = kDefaultCoordinatesOttawa;
    //retain old coordinates
    _hasRealCoordinates = NO;
}

- (void)turnOnLocationTracking
{
	if(_locationManager != nil && [CLLocationManager locationServicesEnabled])
		[_locationManager startUpdatingLocation];
}

- (void)turnOffLocationTracking
{
	if(_locationManager != nil)
		[_locationManager stopUpdatingLocation];
}

#pragma mark - STOPS DATA

- (BOOL)getStops:(NSMutableArray*)stops AtPage:(int)page
{
    if(_hasDB)
    {
        return [_ocDb getAllStops:stops Page:page];
    }
    
    return NO;
}

- (BOOL)getStops:(NSMutableArray*)stops 
      WithSearch:(NSString*)identifier
         ForPage:(int)page
{
    if(_hasDB)
    {
        return [_ocDb getAllStops:stops With:identifier Page:page];
    }
    
    return NO;
}

- (BOOL)getStop:(MTStop *)stop
{
    if(_hasWebDb)
    {
        return [_ocWebDb getStop:stop];
    }
    
    if(_hasDB)
    {
        return [_ocDb getStop:stop];
    }
    
    return NO;
}

- (BOOL)getStopsForBus:(MTBus *)bus
{
    if(_hasDB)
    {
        return [_ocDb getStopsForBus:bus];
    }
    
    return NO;
}

- (BOOL)getAllStops:(NSMutableArray *)stops
{
    if(_hasDB)
    {
        return [_ocDb getAllStops:stops];
    }
    
    return NO;
}

- (BOOL)getAllStopsForBuses:(NSMutableArray*)buses
{
    if(_hasDB)
    {
        return [_ocDb getAllStopsForBuses:buses];
    }
    
    return NO;
}


- (BOOL)getAllBusesForStops:(NSMutableArray*)stops
{
    if(_hasDB)
    {
        return [_ocDb getAllBusesForStops:stops];
    }
    
    return NO;
}

#pragma mark - TIMES DATA

- (NSMutableArray*)getNextTimesForStop:(MTStop*)stop ForBus:(MTBus*)bus
{
    NSMutableArray* trips = [[NSMutableArray alloc] init];
    
    if(_hasAPI)
    {
        if([_ocApi getNextTrips:trips ForStop:stop ForRoute:bus])
            return trips;
    }
    
    if(_hasDB)
    {
        if([_ocDb getNextTrips:trips ForStop:stop ForRoute:bus])
            return trips;
    }
    
    if(_hasWebDb)
    {
        if([_ocWebDb getNextTrips:trips ForStop:stop ForRoute:bus])
            return trips;
    }
    
    return nil;
}

- (MTTime*)getPrevTimeForStop:(MTStop*)stop ForBus:(MTBus*)bus
{
    MTTime* prevTime = [[MTTime alloc] init];
    
    if(_hasDB)
    {
        if([_ocDb getPrevTrip:prevTime ForStop:stop ForRoute:bus])
            return prevTime;
    }
    
    if(_hasWebDb)
    {
        if([_ocWebDb getPrevTrip:prevTime ForStop:stop ForRoute:bus])
            return prevTime;
    }
    
    return nil;
}

#pragma mark - GENERAL QUERIES

- (BOOL)getScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus
{
    dispatch_async(_queue, ^{
        BOOL status = NO;
        stop.IsUpdating = YES;
        
        if(_hasDB) //check if full time schedule exists, if so grab it from here
        {
            status = [_ocDb getStop:stop Route:bus Times:[NSDate date] Results:nil];
        }
        if(!status && _hasWebDb) //couldnt get the full schedule locally try non locally
        {
            NSDictionary *results = [[NSMutableDictionary alloc] init];
            status = [_ocWebDb getStop:stop Route:bus Times:[NSDate date] Results:results];
            if(status && _hasDB)
            {
                [_ocDb addTimes:results ToLocalDatabaseForStop:stop AndBus:bus];
            }
            results = nil;
        }
        
        stop.IsUpdating = NO;
        
        dispatch_async(MTLDEF_MAINQUEUE, ^(void){
            if(!stop.cancelQueue && !bus.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:scheduleForStop:AndRoute:)])
                [_delegate myTranspo:[MTHelper QuickResultState:status] scheduleForStop:stop AndRoute:bus];
        });
    });
    
    return YES;
}

- (BOOL)getNewScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus
{
    return [self getNewScheduleForStop:stop WithRoute:bus ForDate:[NSDate date] StoreTimes:YES];
}

- (BOOL)getNewScheduleForStop:(MTStop *)stop WithRoute:(MTBus *)bus ForDate:(NSDate*)date
{
    BOOL storeTimes = [MTHelper IsDateToday:date];
    return [self getNewScheduleForStop:stop WithRoute:bus ForDate:date StoreTimes:storeTimes];
}

- (BOOL)getNewScheduleForStop:(MTStop *)stop WithRoute:(MTBus *)bus ForDate:(NSDate*)date StoreTimes:(BOOL)store
{
    dispatch_async(_queue, ^{
        NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
        BOOL status = NO;
        
        if(_hasDB) //check if full time schedule exists, if so grab it from here
        {
            bus.IsUpdating = YES;
            status = [_ocDb getStop:stop Route:bus Times:date Results:nil];
            bus.IsUpdating = NO;
        }
        if(status == NO)
        {
            if(_hasWebDb)
            {
                bus.IsUpdating = YES;
                status = [_ocWebDb getStop:stop Route:bus Times:date Results:results];
                bus.IsUpdating = NO;
                
                if(status && _hasDB && store == YES)
                {
                    [_ocDb addTimes:results ToLocalDatabaseForStop:stop AndBus:bus];
                }
            }
        }
        results = nil;
        
        dispatch_async(MTLDEF_MAINQUEUE, ^(void){
            if(!stop.cancelQueue && !bus.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:newScheduleForStop:AndRoute:)])
                [_delegate myTranspo:[MTHelper QuickResultState:status] newScheduleForStop:stop AndRoute:bus];
        });
    });
    
    return (_hasWebDb || _hasDB);
}

- (BOOL)getLiveScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus
{
    return [self getLiveScheduleForStop:stop WithRoute:bus ForDate:[NSDate date]];
}

- (BOOL)getLiveScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus ForDate:(NSDate*)date
{
    if(_hasAPI) //get next times live
    {
        stop.IsUpdating = YES;
        
        dispatch_async(_queue, ^{
            BOOL status = [_ocApi getStop:stop Route:bus Times:date Results:nil];
            stop.IsUpdating = NO;
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && !bus.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:liveScheduleForStop:AndRoute:)])
                    [_delegate myTranspo:[MTHelper QuickResultState:status] liveScheduleForStop:stop AndRoute:bus];
            });
        });
        
        return YES;
    }   
    
    return NO;
}

- (BOOL)getLiveNextTripsForTrip:(MTTrip*)stop WithRoute:(MTBus*)bus
{
    if(_hasAPI) //get next times live
    {
        stop.IsUpdating = YES;
        
        dispatch_async(_queue, ^{
            NSMutableArray *times = [[NSMutableArray alloc] init];
            BOOL status = [_ocApi getNextTrips:times ForTrip:stop ForRoute:bus];
            stop.IsUpdating = NO;
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if([_delegate respondsToSelector:@selector(myTranspo:State:finishedGettingNextLiveTimes:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] finishedGettingNextLiveTimes:times];
            });
        });
        
        return YES;
    }   
    
    return NO;
}

- (BOOL)getDistanceFromStop:(MTStop*)stop
{
    if(_hasDB)
    {
        stop.IsUpdating = YES;
        
        dispatch_async(_queue, ^{
            BOOL status = [_ocDb getDistanceFromStop:stop];
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:updateStop:ForType:)])
                    [_delegate myTranspo:[MTHelper QuickResultState:status]
                              updateStop:stop
                                 ForType:MTUPDATETYPE_DISTANCE];
            });
        });
    }
    
    return NO;
}

#pragma mark - STOPS

- (BOOL)getStopsForRoute:(MTBus*)bus
           ByDistanceLat:(double)lat
                     Lon:(double)lon
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            BOOL status = [_ocDb getStopsForBus:bus ByDistanceLat:lat Lon:lon];
            
            if(status)
            {
                for(MTStop* stop in bus.StopIds)
                {
                    for(MTBus* bus2 in stop.BusIds)
                    {
                        [_ocDb isFavoriteForStop:stop AndBus:bus2];
                    }
                }
            }
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!bus.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:State:receivedStopsForRoute:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedStopsForRoute:bus];
            });
        });
        
        return YES;
    }
    
    return NO;
}

- (BOOL)getRoutesForStop:(MTStop*)stop
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            BOOL status = [_ocDb getRoutesForStop:stop];
#if 0
            if(status)
            {
                for(MTBus* bus in stop.BusIds)
                    [_ocDb isFavoriteForStop:stop AndBus:bus];
            }
#endif       
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:State:receivedRoutesForStop:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedRoutesForStop:stop];
            });
        });
        return YES;
    }
    
    return NO;
}


- (BOOL)getALLStopsNearBy:(double)lat
                      Lon:(double)lon 
                 Distance:(double)kms
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            NSMutableArray* results = [[NSMutableArray alloc] init];
            BOOL status = [_ocDb getAllStops:results NearLon:lon AndLat:lat Distance:kms];
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if([_delegate respondsToSelector:@selector(myTranspo:State:receivedStops:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedStops:results];
            });
        });
        
        return YES;
    }
    
    return NO;
}

- (BOOL)getMoreStopsNearBy:(double)lat
                       Lon:(double)lon
                  Distance:(double)kms
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            NSMutableArray* results = [[NSMutableArray alloc] init];
            BOOL status = [_ocDb getAllStops:results NearLon:lon AndLat:lat Distance:kms];
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if([_delegate respondsToSelector:@selector(myTranspo:State:receivedMoreStops:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedMoreStops:results];
            });
        });
        
        return YES;
    }
    
    return NO;
}

#pragma mark - SEARCHES

- (BOOL)getStopsForQuery:(NSString *)identifier AtPage:(NSInteger)page
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            NSMutableArray* results = [[NSMutableArray alloc] init];
            BOOL status = [_ocDb getAllStops:results With:identifier Page:page];
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if([_delegate respondsToSelector:@selector(myTranspo:State:receivedSearchResults:ForType:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedSearchResults:results ForType:0];
            });
        });
        
        return YES;
    }
    
    return NO;
}

#pragma mark - TRIPS

- (BOOL)getTripDetailsFor:(NSString*)trip
{
    if(_hasWebDb && _isConnected && trip != nil)
    {
        dispatch_async(_queue, ^{
            NSMutableArray* trips = [[NSMutableArray alloc] init];
            BOOL status = [_ocWebDb getTrips:trips ForTrip:trip];
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if([_delegate respondsToSelector:@selector(myTranspo:State:finishedGettingTrips:)])
                    [_delegate myTranspo:self State:[MTHelper QuickResultState:status] finishedGettingTrips:trips];
            });
        });
        
        return YES;
    }
    
    return NO;
}

#pragma mark - FAVORITES

- (BOOL)getFavorites //populated with MTStops 
{
    NSMutableArray* favorites = [[NSMutableArray alloc] init];
    
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            if([_ocDb getFavorites:favorites])
            {
                dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                    if([_delegate respondsToSelector:@selector(myTranspo:receivedFavorites:)])
                        [_delegate myTranspo:MTRESULTSTATE_SUCCESS receivedFavorites:favorites];
                });
            }
            else
            {
                dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                    if([_delegate respondsToSelector:@selector(myTranspo:receivedFavorites:)])
                        [_delegate myTranspo:MTRESULTSTATE_FAILED receivedFavorites:nil];
                });
            }
        });
        
        return YES;
    }
        
    return NO;
}

//updates data on the stop object for live feed mostly, however also to get other tidbits?
- (BOOL)updateFavoriteData:(MTStop*)stop
{
    return [self updateFavoriteData:stop ForDate:[NSDate date] StoreTimes:YES];
}

- (BOOL)updateFavoriteData:(MTStop*)stop ForDate:(NSDate *)date
{
    BOOL storeTimes = [MTHelper IsDateToday:date];
    return [self updateFavoriteData:stop ForDate:date StoreTimes:storeTimes];
}

- (BOOL)updateFavoriteData:(MTStop*)stop ForDate:(NSDate*)date StoreTimes:(BOOL)store;
{
    dispatch_async(_queue, ^{
        BOOL status = NO;
        BOOL checkedScheduleTime = NO;
        if(!stop.Bus.Times.TimesAdded)
        {
            checkedScheduleTime = YES;
            
            //get stop information
            if(_hasDB)
            {
                stop.IsUpdating = YES;
                
                [_ocDb getStop:stop];
                [_ocDb getBus:stop.Bus ForStop:stop];
                if(_hasRealCoordinates)
                {
                    stop.CurrentLat = _coordinates.latitude;
                    stop.CurrentLon = _coordinates.longitude;
                    [_ocDb getDistanceFromStop:stop];
                }
                
                stop.IsUpdating = NO;
            }
            
            if(_hasDB) //check if full time schedule exists, if so grab it from here
            {
                stop.IsUpdating = YES;
                status = [_ocDb getStop:stop Route:stop.Bus Times:date Results:nil];
                stop.IsUpdating = NO;
            }
            if(status == NO && _hasWebDb) //couldnt get the full schedule locally try non locally
            {
                //this can take time so send back what we got
                dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                    if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                        [_delegate myTranspo:MTRESULTSTATE_SUCCESS UpdateType:MTUPDATETYPE_TITLE_AND_DISTANCE updatedFavorite:stop];
                });
                
                stop.IsUpdating = YES;
                NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
                status = [_ocWebDb getStop:stop Route:stop.Bus Times:date Results:results];
                if(status == YES && _hasDB && store == YES)
                {
                    [_ocDb addTimes:results ToLocalDatabaseForStop:stop AndBus:stop.Bus];
                    if([MTSettings notificationUpdateTime])
                    {
                        NSDate* localNotificationDate = [self stripNextDateFromJson:results];
                        if(localNotificationDate != nil)
                        {
                            [self removeUpdateNotificationForStop:stop AndRoute:stop.Bus];
                            [self addUpdateNotificationForStop:stop AndRoute:stop.Bus OnDate:localNotificationDate];
                        }
                    }
                }
                results = nil;
                stop.IsUpdating = NO;
            }
            
            //ok send back what weve got so far
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                    [_delegate myTranspo:[MTHelper QuickResultState:status] UpdateType:MTUPDATETYPE_ALL updatedFavorite:stop];
            });
        }        
        
        if(_hasAPI) //get next times live
        {
            stop.IsUpdating = YES;
            status = [_ocApi getStop:stop Route:stop.Bus Times:date Results:nil];
            stop.IsUpdating = NO;       
        }      
        
        if(!checkedScheduleTime)
        {
            stop.IsUpdating = NO;
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                    [_delegate myTranspo:[MTHelper QuickResultState:status] UpdateType:MTUPDATETYPE_API updatedFavorite:stop];
            });
        }
    });
   
    
    return NO;
}

- (BOOL)addFavorite:(MTStop*)stop 
            WithBus:(MTBus*)bus
{
    if(_hasDB)
    {
        stop.IsUpdating = YES;
        
        dispatch_async(_queue, ^{
            if([_ocDb addFavoriteUsingStop:stop AndBus:bus])
            {
                stop.IsUpdating = NO;
                
                dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                    if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:addedFavorite:AndBus:)])
                        [_delegate myTranspo:MTRESULTSTATE_SUCCESS addedFavorite:stop AndBus:bus];
                });
            }
            else
            {
                stop.IsUpdating = NO;
                dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                    if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:addedFavorite:AndBus:)])
                        [_delegate myTranspo:MTRESULTSTATE_FAILED addedFavorite:nil AndBus:nil];
                });
            }
        });
        
        return YES;
    }
    
    return NO;
}

- (BOOL)removeFavorite:(MTStop*)stop WithBus:(MTBus*)bus
{
    if(_hasDB)
    {
        dispatch_async(_queue, ^{
            stop.IsUpdating = YES;
            BOOL status = [_ocDb removeFavoriteForStop:stop AndBus:bus];
            if(status)
            {
                [self removeUpdateNotificationForStop:stop AndRoute:bus];
            }
            stop.IsUpdating = NO;
            
            dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:removedFavorite:WithBus:)])
                    [_delegate myTranspo:[MTHelper QuickResultState:status] removedFavorite:stop WithBus:bus];
            });
        });
        
        return YES;
    }
    
    return NO;
}

#pragma  mark - OPTIONS

- (NSDate*)getLastSupportedDate
{
    return [_ocDb getLastSupportedDate];
}

#pragma mark - NOTIFICATIONS

- (BOOL)removeAllUpdateNotifications
{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSArray* notifications = [application scheduledLocalNotifications];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userInfo = notification.userInfo;
        
        if(userInfo == nil)
            continue;
        
        NSString* notificationType = (NSString*)[userInfo valueForKey:kMTNotificationTypeKey];
        if(notificationType == nil)
            continue;
        
        if([notificationType isEqualToString:kMTNotificationUpdateTypeKey])
            [application cancelLocalNotification:notification];
    }
    
    return YES;
}

- (BOOL)removeUpdateNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route
{
    if(stop == nil || route == nil)
        return NO;
    
    UIApplication* application = [UIApplication sharedApplication];
    
    NSArray* notifications = [application scheduledLocalNotifications];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userInfo = notification.userInfo;
        
        if(userInfo == nil)
            continue;
        
        NSString* notificationType = (NSString*)[userInfo valueForKey:kMTNotificationTypeKey];
        if(notificationType == nil)
            continue;
        
        if([notificationType isEqualToString:kMTNotificationUpdateTypeKey])
        {
            NSString * notificationStopId = [userInfo valueForKey:kMTNotificationStopKey];
            NSString* notificationBusId = [userInfo valueForKey:kMTNotificationBusKey];
            
            if(notificationStopId == nil || notificationBusId == nil)
                continue;
            
            if([notificationBusId isEqualToString:route.BusId] && [notificationStopId isEqualToString:stop.StopId])
                [application cancelLocalNotification:notification];
        }
    }
    
    return YES;
}

- (BOOL)addUpdateNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route OnDate:(NSDate*)date
{
    if(stop == nil || route == nil)
        return NO;
    
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    notification.alertBody = [NSString stringWithFormat:@"%@ @ %d: %@", route.BusNumber, stop.StopNumber, NSLocalizedString(@"MTDEF_ALERTUPDATEMESSAGE", nil)];
    
    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             kMTNotificationUpdateTypeKey, kMTNotificationTypeKey,
                             stop.StopId, kMTNotificationStopKey,
                             route.BusId, kMTNotificationBusKey,
                             [NSString stringWithFormat:@"%d", stop.StopNumber], kMTNotificationStopNumberKey,
                             route.BusNumber, kMTNotificationBusNumberKey,
                             nil];
    notification.userInfo = userDic;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    return YES;
}

- (BOOL)updateUpdateNotificationsOnLanguageChange
{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSArray* notifications = [application scheduledLocalNotifications];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userInfo = notification.userInfo;
        
        if(userInfo == nil)
            continue;
        
        NSString* notificationType = (NSString*)[userInfo valueForKey:kMTNotificationTypeKey];
        if(notificationType == nil)
            continue;
        
        if(![notificationType isEqualToString:kMTNotificationUpdateTypeKey])
            continue;
        
        NSString* busNumber = (NSString*)[userInfo valueForKey:kMTNotificationBusNumberKey];
        NSString* stopNumber = (NSString*)[userInfo valueForKey:kMTNotificationStopNumberKey];
        
        if(busNumber == nil || stopNumber == nil)
            return NO;
        
        if(busNumber.length <= 0 || stopNumber.length <= 0)
            return NO;
        
        notification.alertBody = [NSString stringWithFormat:@"%@ @ %d: %@", busNumber, stopNumber, NSLocalizedString(@"MTDEF_ALERTUPDATEMESSAGE", nil)];
    }
    
    return YES;
}

- (NSArray*)tripNotifications
{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSArray* notifications = [application scheduledLocalNotifications];
    NSMutableArray* tripNotifications = [[NSMutableArray alloc] init];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userInfo = notification.userInfo;
        
        if(userInfo == nil)
            continue;
        
        NSString* notificationType = (NSString*)[userInfo valueForKey:kMTNotificationTypeKey];
        if(notificationType == nil)
            continue;
        
        if([notificationType isEqualToString:kMTNotificationAlertTypeKey])
            [tripNotifications addObject:notification];
    }
    
    return tripNotifications;
}

- (BOOL)addTripNotificationForTrip:(MTTrip*)trip DayOfWeek:(NSInteger)dayOfWeek ForStop:(MTStop*)stop AndRoute:(MTBus*)route AtStartDate:(NSDate*)startDate
{
    if(trip == nil || stop == nil || route == nil || startDate == nil)
        return NO;
    
    if(dayOfWeek < 0 || dayOfWeek > 2)
        return NO;
    
    NSString* alertTime = [MTSettings notificationAlertTimeString];
    if(alertTime == nil)
        return NO;
        
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    
    notification.alertBody = [NSString stringWithFormat:@"%@ @ %d: %@ %@ min"
                              , route.BusNumber
                              , trip.StopNumber
                              , NSLocalizedString(@"MTDEF_ALERTTIMEMESSAGE", nil)
                              , alertTime];
    
    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             kMTNotificationAlertTypeKey, kMTNotificationTypeKey,
                             trip.StopId, kMTNotificationStopKey,
                             route.BusId, kMTNotificationBusKey,
                             [NSString stringWithFormat:@"%d", trip.StopNumber], kMTNotificationStopNumberKey,
                             route.BusNumber, kMTNotificationBusNumberKey,
                             trip.TripId, kMTNotificationTripKey,
                             [trip.Time getTimeForDisplay], kMTNotificationTripTimeKey,
                             [NSNumber numberWithInt:[MTSettings notificationAlertTimeInt]], kMTNotificationTripAlertTimeKey,
                             nil];
    notification.userInfo = userDic;
    notification.repeatInterval = NSWeekdayCalendarUnit;
    
    //create repeaters
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:startDate];
    weekdayComponents.timeZone = [NSTimeZone localTimeZone];
    int currentWeekday = [weekdayComponents weekday]; //[1;7] ... 1 is sunday, 7 is saturday in gregorian calendar
    NSDate* fireDate;
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];

    if(dayOfWeek == 0) //weekday
    {
        int weekdays[5];
        weekdays[0] = (currentWeekday <= 2) ? 2 - currentWeekday : 9 - currentWeekday;
        weekdays[1] = (currentWeekday <= 3) ? 3 - currentWeekday : 10 - currentWeekday;
        weekdays[2] = (currentWeekday <= 4) ? 4 - currentWeekday : 11 - currentWeekday;
        weekdays[3] = (currentWeekday <= 5) ? 5 - currentWeekday : 12 - currentWeekday;
        weekdays[4] = (currentWeekday <= 6) ? 6 - currentWeekday : 13 - currentWeekday;
        
        //create 5 new fire dates to use
        for(int x=0; x<5; x++)
        {
            [dateComp setDay:weekdays[x]];

            fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:startDate options:0];
            if(fireDate == nil)
                return NO;
            
            fireDate = [self addTime:[trip.Time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
            if(fireDate == nil)
                return NO;
            
            notification.fireDate = fireDate;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }       
    }
    else if(dayOfWeek == 1) //saturday
    {
        [dateComp setDay:7 - currentWeekday];
        fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:weekdayComponents toDate:startDate options:0];
        if(fireDate == nil)
            return NO;
        
        fireDate = [self addTime:[trip.Time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
        if(fireDate == nil)
            return NO;
        
        notification.fireDate = fireDate;        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else //sunday
    {
        [dateComp setDay:8 - currentWeekday];
        
        fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:startDate options:0];
        if(fireDate == nil)
            return NO;
        
        fireDate = [self addTime:[trip.Time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
        if(fireDate == nil)
            return NO;
        
        notification.fireDate = fireDate;        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    
    
    return YES;
}

- (BOOL)tripNotificationMatchTrip:(MTTrip*)trip ForStop:(MTStop*)stop AndRoute:(MTBus*)route AgainstUserInfo:(NSDictionary*)dic
{
    NSString* tripId = [dic valueForKey:kMTNotificationTripKey];
    NSString* stopId = [dic valueForKey:kMTNotificationStopKey];
    NSString* routeId = [dic valueForKey:kMTNotificationBusKey];
    NSString* stopNumber = [dic valueForKey:kMTNotificationStopNumberKey];
    NSString* tripTime = [dic valueForKey:kMTNotificationTripTimeKey];
    
    if(tripId == nil || stopId == nil || routeId == nil || stopNumber == nil || tripTime == nil)
        return NO;
    
    if([tripId isEqualToString:trip.TripId]
       && [stopId isEqualToString:trip.StopId]
       && [routeId isEqualToString:route.BusId]
       && [stopNumber isEqualToString:[NSString stringWithFormat:@"%d", trip.StopNumber]]
       && [tripTime isEqualToString:[trip.Time getTimeForDisplay]])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)removeTripNotificationForTrip:(MTTrip*)trip ForStop:(MTStop*)stop AndRoute:(MTBus*)route
{
    if(trip == nil || stop == nil || route == nil)
        return NO;
    
    NSArray* notifications = [self tripNotifications];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userDic = notification.userInfo;
        BOOL status = [self tripNotificationMatchTrip:trip ForStop:stop AndRoute:route AgainstUserInfo:userDic];
        if(status)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    return YES;
}

- (BOOL)removeAllTripNotifications
{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSArray* notifications = [application scheduledLocalNotifications];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userInfo = notification.userInfo;
        
        if(userInfo == nil)
            continue;
        
        NSString* notificationType = (NSString*)[userInfo valueForKey:kMTNotificationTypeKey];
        if(notificationType == nil)
            continue;
        
        if([notificationType isEqualToString:kMTNotificationAlertTypeKey])
            [application cancelLocalNotification:notification];
    }
    
    return YES;
}

- (BOOL)removeNotifications:(NSArray*)notifications
{
    if(notifications == nil)
        return NO;
    
    if(notifications.count <= 0)
        return NO;
    
    UIApplication* application = [UIApplication sharedApplication];
    
    for(UILocalNotification* notification in notifications)
    {
        [application cancelLocalNotification:notification];
    }
    
    return YES;
}

#pragma mark - Helper

- (NSDate*)stripNextDateFromJson:(NSDictionary *)json
{
    if(json == nil)
        return nil;
    
    NSString* nextDate;
    for(NSString *day in [json allKeys])
    {        
        for(NSDictionary *dic in [json objectForKey:day])
        {
            nextDate = [dic valueForKey:@"next_update"];
            break;
        }
        break;
    }
    
    if(nextDate == nil)
        return nil;
    
    NSDateFormatter* dateFormatter = [MTHelper MTDateFormatterDashesYYYYMMDD];
    
    //NSLog(@"Set Date: %@", [dateFormatter dateFromString:nextDate]);
    //NSLog(@"Test Date: %@", [[NSDate date] dateByAddingTimeInterval:60]);
    
    return [dateFormatter dateFromString:nextDate];
}

- (NSDate*)addTime:(NSString *)time toDate:(NSDate *)date withInterval:(int)interval
{
    if(time == nil)
        return nil;
    
    int hour = [[time substringToIndex:2] intValue];
    int min = [[time substringFromIndex:3] intValue];
    
    if(hour == 0 && min == 0)
        return nil;
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDate* begOfDay;
    BOOL status = [cal rangeOfUnit:NSDayCalendarUnit startDate:&begOfDay interval:NULL forDate:date];
    if(!status)
        return nil;
    
    NSDateComponents* timeComp = [cal components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:begOfDay];
    [timeComp setHour:hour];
    [timeComp setMinute:min];
    
    NSDate* scheduleDate = [[NSCalendar currentCalendar] dateByAddingComponents:timeComp toDate:begOfDay options:0];

    NSDate* notifyDate = [scheduleDate dateByAddingTimeInterval:-60*interval];
    
    return notifyDate;
}

@end
