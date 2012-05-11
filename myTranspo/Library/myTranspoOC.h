//
//  myTranspoOC.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

//ToDo: make this a singleton

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MTTypes.h"
#import "MTDefinitions.h"
#import "MTBus.h"
#import "MTStop.h"
#import "MTOCApi.h"
#import "MTOCDB.h"
#import "MTWebDB.h"
#import "MTSettings.h"
#import "MTTripPlanner.h"

@protocol MyTranspoDelegate <NSObject>
//GENERAL
@optional
- (void)myTranspo:(MTResultState)state scheduleForStop:(MTStop*)stop AndRoute:(MTBus*)bus;
- (void)myTranspo:(MTResultState)state newScheduleForStop:(MTStop*)stop AndRoute:(MTBus*)bus;
- (void)myTranspo:(MTResultState)state liveScheduleForStop:(MTStop*)stop AndRoute:(MTBus*)bus;
- (void)myTranspo:(MTResultState)state updateStop:(MTStop*)stop ForType:(MTUpdateType)updateType;
- (void)myTranspo:(MTResultState)state updateStop:(MTStop*)stop AndRoute:(MTBus*)bus ForType:(MTUpdateType)updateType;
- (void)myTranspo:(MTResultState)state updateRoute:(MTBus*)bus ForType:(MTUpdateType)updateType;

//STOPS
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedStopsForRoute:(MTBus*)results;
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedStops:(NSArray*)results;
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedMoreStops:(NSArray*)results;
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedRoutesForStop:(MTStop*)results;

//SEARCH
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedSearchResults:(NSArray*)results ForType:(NSInteger)type;

//FAVORITES
@optional
- (void)myTranspo:(MTResultState)state removedFavorite:(MTStop*)favorite WithBus:(MTBus*)bus;
- (void)myTranspo:(MTResultState)state receivedFavorites:(NSMutableArray*)favorites;
- (void)myTranspo:(MTResultState)state addedFavorite:(MTStop*)favorite AndBus:(MTBus*)bus;
- (void)myTranspo:(MTResultState)state UpdateType:(MTUpdateType)updateType updatedFavorite:(MTStop*)favorite;

//TRIPS
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingTrips:(NSArray*)trips;

//API
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingNextLiveTimes:(NSArray*)times;

//GPS
@optional
-(void)myTranspo:(id)transpo State:(MTResultState)state updatedUserCoordinates:(CLLocationCoordinate2D)newCoordinates;

//notices
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedNotices:(NSDictionary*)notices;
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedRouteNotices:(NSArray*)notices forFavoriteRoute:(BOOL)hasFavorite;

//trip planner
@optional
- (void)myTranspo:(id)transpo State:(MTResultState)state receivedTripPlan:(NSDictionary*)trip;
@end

#define kDefaultCoordinatesOttawa CLLocationCoordinate2DMake(45.42158812329091, -75.69442749023438)
#define kAsyncLimit 5

@interface myTranspoOC : NSObject <CLLocationManagerDelegate>
{
    MTLanguage              _language;
    NSString*               _dbPath;
    NSString*               _webDbPath;
    MTTranspoTypes          _transpoType;
    BOOL                    _hasDB;
    BOOL                    _hasAPI;
    BOOL                    _hasWebDb;
    BOOL                    _hasOfflineTimes;
    BOOL                    _isConnected;
    BOOL                    _hasRealCoordinates;
    
    MTOCApi*                _ocApi;
    MTOCDB*                 _ocDb;
    MTWebDB*                _ocWebDb;
    MTOCDB*                 _ocOfflineTimes;
    CLLocationManager*      _locationManager;
    
//    NSOperationQueue*       _queue;
    dispatch_queue_t                _queue;
    dispatch_semaphore_t            _semaphore;
    id<MyTranspoDelegate> __weak    _delegate;
}

@property (nonatomic)           MTLanguage              Language;
@property (nonatomic)           MTCity                  City;
@property (nonatomic)           MTTranspoTypes          TranspoType;
@property (nonatomic, strong)   NSString*               DBPath;
@property (nonatomic, strong)   NSString*               WebDBPath;
@property (nonatomic, weak)     id<MyTranspoDelegate>   delegate;
@property (nonatomic)           CLLocationCoordinate2D  coordinates;
@property (nonatomic,readonly)  BOOL                    hasRealCoordinates;
@property (nonatomic, readonly) CLLocation*             clLocation;

//methods
+ (myTranspoOC*)sharedSingleton;

- (void)initialize;
- (id)initWithLanguage:(MTLanguage)lang AndDBPath:(NSString *)dbpath ForCity:(MTCity)city;
- (BOOL)addDBPath:(NSString*)dbPath;
- (BOOL)addWebDBPath:(NSString*)urlPath;
- (BOOL)addAPI;
- (BOOL)addOfflineTimes;
- (BOOL)validateData;
- (void)turnOnLocationTracking;
- (void)turnOffLocationTracking;
- (void)kill;
- (void)turnOffNetworkMethods;
- (void)turnOnNetworkMethods;

//general data
- (BOOL)getScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus;
- (BOOL)getLiveScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus;
- (BOOL)getNewScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus;//go online to get it
- (BOOL)getNewScheduleForStop:(MTStop *)stop WithRoute:(MTBus *)bus ForDate:(NSDate*)date;
- (BOOL)getNewScheduleForStop:(MTStop *)stop WithRoute:(MTBus *)bus ForDate:(NSDate*)date StoreTimes:(BOOL)store;
- (BOOL)getLiveNextTripsForTrip:(MTTrip*)stop WithRoute:(MTBus*)bus;
- (BOOL)getLiveScheduleForStop:(MTStop*)stop WithRoute:(MTBus*)bus ForDate:(NSDate*)date;

- (BOOL)getDistanceFromStop:(MTStop*)stop;

//stops
- (BOOL)getStopsForRoute:(MTBus*)bus ByDistanceLat:(double)lat Lon:(double)lon;
- (BOOL)getRoutesForStop:(MTStop*)stop;
- (BOOL)getALLStopsNearBy:(double)lat Lon:(double)lon Distance:(double)kms;
- (BOOL)getMoreStopsNearBy:(double)lat Lon:(double)lon Distance:(double)kms;

//searching
- (BOOL)getStopsForQuery:(NSString *)identifier AtPage:(NSInteger)page;

//trips
- (BOOL)getTripDetailsFor:(NSString*)trip;

//favorite specific methods
- (BOOL)getFavorites;
- (BOOL)updateAllFavorites:(NSArray*)favorites;
- (BOOL)updateAllFavorites:(NSArray*)favorites FullUpdate:(BOOL)fullUpdate;
- (BOOL)updateFavorite:(MTStop*)favorite FullUpdate:(BOOL)fullUpdate;
- (BOOL)updateFavoriteData:(MTStop*)stop; //stop acts as favorite, firstBus in busids = bus for favorite
- (BOOL)updateFavoriteData:(MTStop*)stop ForDate:(NSDate*)date;
- (BOOL)updateFavoriteData:(MTStop*)stop ForDate:(NSDate*)date StoreTimes:(BOOL)store;
- (BOOL)addFavorite:(MTStop*)stop WithBus:(MTBus*)bus;
- (BOOL)removeFavorite:(MTStop*)stop WithBus:(MTBus*)bus; //stop acts as favorite, firstBus in busids = bus for favorite

//notifications
- (BOOL)removeAllUpdateNotifications;
- (BOOL)removeUpdateNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route;
- (BOOL)addUpdateNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route OnDate:(NSDate*)date;
- (BOOL)updateUpdateNotificationsOnLanguageChange;
- (UILocalNotification*)addTripNotificationForTrip:(MTTrip*)trip DayOfWeek:(NSInteger)dayOfWeek ForStop:(MTStop*)stop AndRoute:(MTBus*)route AtStartDate:(NSDate*)startDate AndTime:(MTTime*)time;
- (BOOL)removeTripNotificationForStop:(MTStop*)stop AndRoute:(MTBus*)route AndDayOfWeek:(NSInteger)dayOfWeek AndTime:(NSString*)time;
- (BOOL)tripNotificationMatchForStop:(MTStop*)stop AndRoute:(MTBus*)route AndDayOfWeek:(NSInteger)dayOfWeek AndTime:(NSString*)time AgainstUserInfo:(NSDictionary*)dic;
- (NSArray*)tripNotifications;
- (NSArray*)tripNotificationsForStop:(MTStop*)stop AndRoute:(MTBus*)route;
- (BOOL)removeAllTripNotifications;
- (BOOL)removeTripNotificationsForStop:(MTStop*)stop AndRoute:(MTBus*)route;
- (BOOL)removeNotifications:(NSArray*)notifications;

//tripplanner
- (BOOL)getTripPlanner:(MTTripPlanner*)trip;

//helpers
- (NSDate*)stripNextDateFromJson:(NSDictionary*)json;
- (NSDate*)addTime:(NSString*)time toDate:(NSDate*)date withInterval:(int)interval;
- (MTTrip*)getClosestTrip:(NSArray*)trips ToLat:(double)latitude Lon:(double)longitude; //not threaded

//options
- (NSDate*)getLastSupportedDate;

//notices
- (BOOL)getNotices;
- (BOOL)getRouteNotices;
- (BOOL)getRouteNoticesForTempDelegate:(id<MyTranspoDelegate>)delegate;

@end
