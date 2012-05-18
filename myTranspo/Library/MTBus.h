//
//  MTBus.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTypes.h"
#import "MTDefinitions.h"
#import "MTTime.h"
#import "MTHelper.h"
#import "MTBase.h"
#import "myTranspoOC.h"

@interface MTBus : MTBase <NSCopying>
{
    NSString*           _busId;
    NSString*           _busNumber;
    MTDirection         _busHeading;
    NSString*           _busDisplayHeading;
    BOOL                _hasGpsTime;
    NSMutableArray*     _stopIds; //MTStop stops within route
    MTLanguage          _language;
    MTTimes*            _times; //used for static times
    MTTimeLive*         _liveTimes; //used to track live times, needs to be cleared before update
    NSNumberFormatter*  _numFormatter;
}

@property (nonatomic, strong)   NSString*               BusId;
@property (nonatomic, strong)   NSString*               BusNumber;
@property (nonatomic)           MTDirection             BusHeading;
@property (nonatomic, strong)   NSString*               DisplayHeading;
@property (nonatomic)           BOOL                    GPSTime;
@property (nonatomic, strong)   NSMutableArray*         StopIds;
@property (nonatomic)           MTLanguage              Language;
@property (nonatomic, strong)   MTTimes*                Times;
@property (nonatomic, strong)   NSDate*                 chosenDate;
@property (nonatomic, strong)   NSString*               BusSpeed; //km/hr
@property (nonatomic, strong)   NSString*               TrueDisplayHeading;

@property (readonly, getter = getNextTime)          MTTime*   NextTime;
@property (readonly, getter = getPrevTime)          NSString*   PrevTime;
@property (readonly, getter = getNextThreeTimes)    NSArray*    NextThreeTimes;
@property (readonly, getter = getCurrentTrip)       MTTime*     CurrentTrip;
@property (readonly)                                NSString*   BusNumberDisplay;

//display vars
@property (nonatomic, strong)   NSString*               PrevTimeDisplay;
@property (nonatomic, strong)   MTTime*                 NextTimeDisplay;
@property (nonatomic, strong)   NSArray*                NextThreeTimesDisplay;

//methods
- (id)initWithLanguage:(MTLanguage)lang;
- (BOOL)clearLiveTimes;
- (BOOL)addLiveTimes:(NSArray*)times; //once the gps value is used it must be removed from the array

//ui helper methods
- (NSString *)getBusHeading; //generic mode used internally in app
- (NSString *)getBusHeadingOCStyle; //used to match OC Transpo provided headings
- (NSString *)getBusHeadingShortForm;
- (int)getBusHeadingForFavorites;
- (BOOL)updateBusHeadingFromInt:(int)heading;
- (NSArray*)getWeekdayTimesForDisplay;
- (NSArray*)getSaturdayTimesForDisplay;
- (NSArray*)getSundayTimesForDisplay;
- (NSArray*)getNextTimesOfAmount:(int)count IncludeLiveTime:(BOOL)useLive;
- (void)updateDisplayObjects;
- (void)updatePrevNextObjects;

//debug helper methods
- (NSString *)description;

@end
