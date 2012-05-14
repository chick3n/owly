//
//  myTranspoOC.m
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//


#import "myTranspoOC.h"

static myTranspoOC *gInstance = NULL;

#define MTLDEF_BGQUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define MTLDEF_MAINQUEUE dispatch_get_main_queue()

@interface myTranspoOC ()
- (void)initializeLocationManager;
- (BOOL)updateFavoriteHeader:(MTStop*)stop FullUpdate:(BOOL)fullUpdate;
- (BOOL)updateFavorite:(MTStop*)stop ForDate:(NSDate*)date StoreTimes:(BOOL)store;
- (BOOL)updateStopFavorite:(MTStop*)stop;
- (BOOL)startGPSRefresh:(id)sender;
- (void)gpsRefreshTick:(id)sender;
@end

@implementation myTranspoOC

@synthesize Language       = _language;
@synthesize DBPath         = _dbPath;
@synthesize TranspoType    = _transpoType;
@synthesize WebDBPath      = _webDbPath;
@synthesize delegate       = _delegate;
@synthesize coordinates    = _coordinates;
@synthesize City           = _city;
@synthesize hasRealCoordinates = _hasRealCoordinates;
@synthesize gpsRefreshRate = _gpsRefreshRate;

- (void)setGpsRefreshRate:(NSTimeInterval)gpsRefreshRate
{
    if(_gpsRefreshRate != gpsRefreshRate)
    {
        _gpsRefreshRate = gpsRefreshRate;
    
        [self startGPSRefresh:nil];   
    }
}


- (CLLocation*)clLocation
{
    if(_locationManager != nil)
        return _locationManager.location;
    return nil;
}

//Do not use
+ (myTranspoOC*)sharedSingleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[self alloc] init];
            [gInstance initialize];
        }
    }
    
    return gInstance;
}

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
        _semaphore = dispatch_semaphore_create((long)kAsyncLimit);
        _gpsRefreshRate = 300;
        
        [self initializeLocationManager];
        
        if(![self validateData])
            return nil;
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
    dispatch_release(_semaphore);
    [self endGpsRefresh:nil];
}

#pragma mark - INTERNAL METHOD CHECKS

- (void)initialize
{
    
}

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

- (BOOL)addDBPath:(NSString*)dbPath
{
    _dbPath = [NSString stringWithString:dbPath];
    
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

- (BOOL)addOfflineTimes
{
    NSString* dbName = nil;
    
    switch (_city) {
        case MTCITYOTTAWA:
            dbName = @"OCTranspoOffline.sqlite";
            break;
            
        default:
            break;
    }
    
    _hasOfflineTimes = NO;
    _ocOfflineTimes = nil;
    
    if(dbName == nil)
        return NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDir stringByAppendingPathComponent:dbName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        _hasOfflineTimes = YES;
        _ocOfflineTimes = [[MTOCDB alloc] initWithDBPath:dbPath And:_language];
        
        if(_ocOfflineTimes.isConnected)
            return YES;
    }
    
    return NO;
}

- (BOOL)addWebDBPath:(NSString*)urlPath
{
    _webDbPath = [NSString stringWithString:urlPath];
    
    _ocWebDb = [[MTWebDB alloc] initWithUrlPath:_webDbPath And:_language];
    
    if(![_ocWebDb connectToServer])
        return NO;
    
    _hasWebDb = YES;
    _ocWebDb.isSet = YES;
    return YES;
}

- (BOOL)addAPI
{
    switch(_transpoType)
    {
        case MTTRANSPOTYPE_OC:
            _hasAPI = YES;
            _ocApi = [[MTOCApi alloc] initWithLanguage:_language AndUrlPath:@"https://api.octranspo1.com/v1.0/" UsingAPIKey:@"2010d75153a9bbfd1d4db0a1db70fcd0" UsingApplicationID:@"4d8b9165"];
            _ocApi.isSet = YES;
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
    dispatch_release(_semaphore);
}

- (void)turnOffNetworkMethods
{
    _hasWebDb = NO;
    _hasAPI = NO;
}

- (void)turnOnNetworkMethods
{
    if(_ocApi && _ocApi.isSet)
        _hasAPI = YES;
    
    if(_ocWebDb && _ocWebDb.isSet)
        _hasWebDb = YES;
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
    _coordinates = newLocation.coordinate;
    _hasRealCoordinates = YES;
    if([_delegate respondsToSelector:@selector(myTranspo:State:updatedUserCoordinates:)])
        [_delegate myTranspo:self State:MTRESULTSTATE_SUCCESS updatedUserCoordinates:newLocation.coordinate];
    
    [self turnOffLocationTracking];
}

- (void)locationManager:(CLLocationManager *)manager 
	   didFailWithError:(NSError *)error 
{
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

- (BOOL)isFavorite:(MTStop*)stop WithBus:(MTBus*)bus
{
    if(_hasDB)
    {
        return [_ocDb isFavoriteForStop:stop AndBus:bus];
    }
    
    return NO;
}

- (BOOL)updateAllFavorites:(NSArray*)favorites
{
    return [self updateAllFavorites:favorites FullUpdate:YES];
}

- (BOOL)updateAllFavorites:(NSArray*)favorites FullUpdate:(BOOL)fullUpdate
{
    dispatch_async(_queue
                   , ^{
                       NSDate* today = [NSDate date];
                       for(MTStop* favorite in favorites)
                       {
                           [self updateFavoriteHeader:favorite FullUpdate:fullUpdate];
                           [self updateFavorite:favorite ForDate:today StoreTimes:YES];
                       }
                       
                       dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                           if([_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                               [_delegate myTranspo:MTRESULTSTATE_DONE UpdateType:MTUPDATETYPE_ALL updatedFavorite:nil];
                       });
                   });
    
    return YES;    
}

- (BOOL)updateFavorite:(MTStop *)favorite FullUpdate:(BOOL)fullUpdate
{
    dispatch_async(_queue, ^{
#if 0
        int r = arc4random() % 25;
        sleep(r);
#endif
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(_semaphore);
        
        if(!favorite.isUpdating)
        {
            favorite.isUpdating = YES;

            NSDate *today = [NSDate date];
            if(favorite.Bus == nil) //stop as favorite
            {
                [self updateFavoriteHeader:favorite FullUpdate:fullUpdate];
                [self updateStopFavorite:favorite];
            }
            else
            {
                [self updateFavoriteHeader:favorite FullUpdate:fullUpdate];
                [self updateFavorite:favorite ForDate:today StoreTimes:YES];
            }
            
            favorite.isUpdating = NO;
        }
        
        dispatch_async(MTLDEF_MAINQUEUE, ^{
            if([_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                [_delegate myTranspo:MTRESULTSTATE_DONE UpdateType:MTUPDATETYPE_ALL updatedFavorite:favorite];
        });
    });
    
    return YES;
}

- (BOOL)updateFavoriteHeader:(MTStop*)stop FullUpdate:(BOOL)fullUpdate
{
    //get stop information
    if(_hasDB)
    {        
        if(fullUpdate)
        {
            [_ocDb getStop:stop];
            [_ocDb getBus:stop.Bus ForStop:stop];
        }
        
        if(_hasRealCoordinates)
        {
            stop.CurrentLat = _coordinates.latitude;
            stop.CurrentLon = _coordinates.longitude;
            [_ocDb getDistanceFromStop:stop];
        }
        
        return YES;
    }
    return NO;
}

- (BOOL)updateStopFavorite:(MTStop*)stop
{
    if(_hasWebDb)
    {
        MTLog(@"GETTING STOP TIMES WEB");
        [_ocWebDb getStopTimes:stop];
    }    
    return NO;
}

- (BOOL)updateFavorite:(MTStop *)stop ForDate:(NSDate *)date StoreTimes:(BOOL)store
{
    [stop.Bus clearLiveTimes];
    
    BOOL status = NO;
    if(![MTHelper IsDateToday:stop.Bus.Times.TimesAddedOn])
    {
        if(_hasOfflineTimes)
        {
            MTLog(@"GETTING OFFLINE TIMES");
            status = [_ocOfflineTimes getOfflineStop:stop Route:stop.Bus Times:date Results:nil];
        }
        
        //get stop information
        if(status == NO && _hasDB)
        {
            MTLog(@"GETTING TIMES LOCAL");
            status = [_ocDb getStop:stop Route:stop.Bus Times:date Results:nil];
        }
        
        if(status == NO && _hasWebDb) //couldnt get the full schedule locally try non locally
        {
            MTLog(@"GETTING TIMES WEB");
            NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
            status = [_ocWebDb getStop:stop Route:stop.Bus Times:date Results:results];
            if(status == YES && _hasDB && store == YES)
            {
                [_ocDb addTimes:results ToLocalDatabaseForStop:stop AndBus:stop.Bus];
                if([MTSettings notificationUpdateTime] && !_hasOfflineTimes)
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
        }
    } 
    
    if(_hasAPI && [MTHelper IsDateToday:date]) //get next times live
    {
        MTLog(@"GETTING TIMES API");
        status = [_ocApi getStop:stop Route:stop.Bus Times:date Results:nil];
        if(status && _hasDB && [stop.Bus getBusHeadingForFavorites] != MTDIRECTION_UNKNOWN)
        {
            [_ocDb updateFavorite:stop AndBus:stop.Bus];
        }  
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
    [stop.Bus clearLiveTimes];
    
    dispatch_async(_queue, ^{
        BOOL status = NO;
        if(!stop.Bus.Times.TimesAdded)
        {
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
        else //information updates only
        {
            if(_hasDB)
            {
                stop.IsUpdating = YES;
                
                if(_hasRealCoordinates)
                {
                    stop.CurrentLat = _coordinates.latitude;
                    stop.CurrentLon = _coordinates.longitude;
                    [_ocDb getDistanceFromStop:stop];
                }
                
                stop.IsUpdating = NO;
            }
        }
        
        if(_hasAPI && [MTHelper IsDateToday:date]) //get next times live
        {
            stop.IsUpdating = YES;
            status = [_ocApi getStop:stop Route:stop.Bus Times:date Results:nil];
            if(status && _hasDB && [stop.Bus getBusHeadingForFavorites] != MTDIRECTION_UNKNOWN)
            {
                [_ocDb updateFavorite:stop AndBus:stop.Bus];
            }
            stop.IsUpdating = NO;       
        }      
        
        stop.IsUpdating = NO;
        dispatch_async(MTLDEF_MAINQUEUE, ^(void){
            if(!stop.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:UpdateType:updatedFavorite:)])
                [_delegate myTranspo:[MTHelper QuickResultState:status] UpdateType:MTUPDATETYPE_API updatedFavorite:stop];
        });
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
                [_ocDb addTimes:[NSDictionary dictionary] ToLocalDatabaseForStop:stop AndBus:bus]; //will remove times and not add any
                [self removeUpdateNotificationForStop:stop AndRoute:bus];
                [self removeTripNotificationsForStop:stop AndRoute:bus];
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
    
    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"MTDEF_ALERTUPDATEMESSAGE", nil), route.BusNumber, stop.StopNumber];
    
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
        
        notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"MTDEF_ALERTUPDATEMESSAGE", nil), busNumber, stopNumber];
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

- (NSArray*)tripNotificationsForStop:(MTStop*)stop AndRoute:(MTBus*)route
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
        {
            NSString* stopId = [userInfo valueForKey:kMTNotificationStopKey];
            NSString* routeId = [userInfo valueForKey:kMTNotificationBusKey];
            
            if(stopId == nil || routeId == nil)
                continue;
            
            if([stopId isEqualToString:stop.StopId]
               && [routeId isEqualToString:route.BusId])
            {
                [tripNotifications addObject:notification];
            }
        }
            
    }
    
    return tripNotifications;
}

- (UILocalNotification*)addTripNotificationForTrip:(MTTrip*)trip DayOfWeek:(NSInteger)dayOfWeek ForStop:(MTStop*)stop AndRoute:(MTBus*)route AtStartDate:(NSDate*)startDate AndTime:(MTTime*)time
{
    if(trip == nil || stop == nil || route == nil || startDate == nil || time == nil)
        return nil;
    
    if(dayOfWeek < 0 || dayOfWeek > 2)
        return nil;
    
    NSString* alertTime = [MTSettings notificationAlertTimeString];
    if(alertTime == nil)
        return nil;
        
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    
    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"MTDEF_ALERTTIMEMESSAGE", nil)
                              , route.BusNumber
                              , route.DisplayHeading
                              , stop.StopNumber
                              , alertTime];
    
    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             kMTNotificationAlertTypeKey, kMTNotificationTypeKey,
                             stop.StopId, kMTNotificationStopKey,
                             route.BusId, kMTNotificationBusKey,
                             [NSString stringWithFormat:@"%d", stop.StopNumber], kMTNotificationStopNumberKey,
                             route.BusNumber, kMTNotificationBusNumberKey,
                             trip.TripId, kMTNotificationTripKey,
                             [time getTimeForDisplay], kMTNotificationTripTimeKey,
                             [NSNumber numberWithInt:[MTSettings notificationAlertTimeInt]], kMTNotificationTripAlertTimeKey,
                             [NSNumber numberWithInt:dayOfWeek], kMTNotificationDayOfWeek,
                             route.DisplayHeading, kMTNotificationBusDisplayHeading,
                             stop.StopName, kMTNotificationStopStreetName,
                             nil];
    notification.userInfo = userDic;
    notification.repeatInterval = NSWeekCalendarUnit;
    
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
                return nil;
            
            fireDate = [self addTime:[time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
            if(fireDate == nil)
                return nil;
            
            notification.fireDate = fireDate;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }       
    }
    else if(dayOfWeek == 1) //saturday
    {
        [dateComp setDay:7 - currentWeekday];
        fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:weekdayComponents toDate:startDate options:0];
        if(fireDate == nil)
            return nil;
        
        fireDate = [self addTime:[time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
        if(fireDate == nil)
            return nil;
        
        notification.fireDate = fireDate;        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else //sunday
    {
        [dateComp setDay:8 - currentWeekday];
        
        fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:startDate options:0];
        if(fireDate == nil)
            return nil;
        
        fireDate = [self addTime:[time getTimeForDisplay] toDate:fireDate withInterval:[MTSettings notificationAlertTimeInt]];
        if(fireDate == nil)
            return nil;
        
        notification.fireDate = fireDate;        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    return notification;
}

- (BOOL)tripNotificationMatchForStop:(MTStop*)stop AndRoute:(MTBus*)route AndDayOfWeek:(NSInteger)dayOfWeek AndTime:(NSString*)time AgainstUserInfo:(NSDictionary*)dic
{
    NSNumber* day = [dic valueForKey:kMTNotificationDayOfWeek];
    NSString* stopId = [dic valueForKey:kMTNotificationStopKey];
    NSString* routeId = [dic valueForKey:kMTNotificationBusKey];
    NSString* stopNumber = [dic valueForKey:kMTNotificationStopNumberKey];
    NSString* tripTime = [dic valueForKey:kMTNotificationTripTimeKey];
    
    if(day == nil || stopId == nil || routeId == nil || stopNumber == nil || tripTime == nil)
        return NO;
    
    if([day intValue] == dayOfWeek
       && [stopId isEqualToString:stop.StopId]
       && [routeId isEqualToString:route.BusId]
       && [stopNumber isEqualToString:[NSString stringWithFormat:@"%d", stop.StopNumber]]
       && [tripTime isEqualToString:time])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)removeTripNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route AndDayOfWeek:(NSInteger)dayOfWeek AndTime:(NSString*)time
{
    if(stop == nil || route == nil || time == nil)
        return NO;
    
    if(dayOfWeek < 0 || dayOfWeek > 2)
        return NO;
    
    NSArray* notifications = [self tripNotificationsForStop:stop AndRoute:route];
    
    for(UILocalNotification* notification in notifications)
    {
        NSDictionary* userDic = notification.userInfo;
        BOOL status = [self tripNotificationMatchForStop:stop AndRoute:route AndDayOfWeek:dayOfWeek AndTime:time AgainstUserInfo:userDic];
        if(status)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    return YES;
}

- (BOOL)removeTripNotificationsForStop:(MTStop*)stop AndRoute:(MTBus*)route
{
    if(stop == nil || route == nil)
        return NO;
    
    
    NSArray* notifications = [self tripNotificationsForStop:stop AndRoute:route];
    
    for(UILocalNotification* notification in notifications)
    {
       [[UIApplication sharedApplication] cancelLocalNotification:notification];
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

- (MTTrip*)getClosestTrip:(NSArray*)trips ToLat:(double)latitude Lon:(double)longitude
{
    if(_hasDB)
    {
        return [_ocDb getClosestTrip:trips ToLat:latitude Lon:longitude];
    }
    
    return nil;
}

#pragma mark - Notices

- (BOOL)getNotices
{
    if(_hasWebDb)
    {
        dispatch_async(_queue
                       , ^(void){
                           NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
                           BOOL status = [_ocWebDb getNotices:results ForLanguage:_language];
                           dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                               if([_delegate respondsToSelector:@selector(myTranspo:State:receivedNotices:)])
                                   [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedNotices:results];
                           });
                       });
        return YES;
    }
    
    return NO;
}

- (BOOL)getRouteNotices
{
    return [self getRouteNoticesForTempDelegate:_delegate];
}

- (BOOL)getRouteNoticesForTempDelegate:(id<MyTranspoDelegate>)delegate
{
    if(_hasWebDb)
    {
        dispatch_async(_queue
                       , ^(void){
                           NSMutableArray* results = [[NSMutableArray alloc] init];
                           BOOL status = [_ocWebDb getRoutesForNotices:results];
                           BOOL hasFavorite = [_ocDb compareFavoritesToNotices:results];
                           dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                               if([delegate respondsToSelector:@selector(myTranspo:State:receivedRouteNotices:forFavoriteRoute:)])
                                   [delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedRouteNotices:results forFavoriteRoute:hasFavorite];
                           });
                       });
        return YES;
    }
    
    return NO;
}

#pragma mark - Trip Planner

- (BOOL)getTripPlanner:(MTTripPlanner*)trip
{
    if(_hasWebDb)
    {
        dispatch_async(_queue
                       , ^(void){
                           BOOL transpTypeFound = NO;
                           BOOL status = NO;
                           NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
                           if(_transpoType == MTTRANSPOTYPE_OC)
                           {
                               status = [_ocWebDb getOCTripPlanner:trip WithResults:results];
                               transpTypeFound = YES;
                           }        
                           
                           if(transpTypeFound == NO)
                               results = nil;
                           
                           dispatch_async(MTLDEF_MAINQUEUE, ^(void){
                               if(!trip.cancelQueue && [_delegate respondsToSelector:@selector(myTranspo:State:receivedTripPlan:)])
                                   [_delegate myTranspo:self State:[MTHelper QuickResultState:status] receivedTripPlan:results];
                           });

                       });
        
    }
    
    return NO;
}

#pragma mark - GPS TIMER

- (BOOL)startGPSRefresh:(id)sender
{
    if(_gpsTimer != nil)
        [_gpsTimer invalidate];
    
    _gpsTimer = [NSTimer scheduledTimerWithTimeInterval:_gpsRefreshRate  target:self selector:@selector(gpsRefreshTick:) userInfo:nil repeats:YES];
    [_gpsTimer fire];
    return YES;
}

- (BOOL)endGpsRefresh:(id)sender
{
    if(_gpsTimer != nil)
        [_gpsTimer invalidate];
    
    _gpsTimer = nil;
    return YES;
}

- (void)gpsRefreshTick:(id)sender
{
    [self turnOnLocationTracking];
}

@end
