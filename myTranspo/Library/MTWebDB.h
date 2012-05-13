//
//  MTWebDB.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-12.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTInteraction.h"
#import "MTDefinitions.h"
#import "NSString+URLEncoding.h"

#import <sqlite3.h>
#import "sqlite3_distance.c"

#include <mach/mach_time.h>
#include <stdint.h>

@interface MTWebDB : NSObject <MTInteraction>
{
    NSString*           _urlPath;
    NSURL*              _url;
    MTLanguage          _language;
    uint                _stopsLimit;
    uint                _busLimit;
    float               _locationDistance;
}

@property (nonatomic) BOOL      isSet;

- (id)initWithUrlPath:(NSString*)urlPath And:(MTLanguage)lang;
- (BOOL)connectToServer;

- (BOOL)getNotices:(NSMutableDictionary*)notices ForLanguage:(MTLanguage)language;
- (BOOL)getRoutesForNotices:(NSMutableArray*)notices;
- (BOOL)getStopTimes:(MTStop*)stop;

//TRIP PLANNER
- (BOOL)getOCTripPlanner:(MTTripPlanner*)tripPlanner WithResults:(NSMutableDictionary*)results;

@end
