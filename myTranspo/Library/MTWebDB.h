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
#import <sqlite3.h>
#import "sqlite3_distance.c"

@interface MTWebDB : NSObject <MTInteraction>
{
    NSString*           _urlPath;
    NSURL*              _url;
    MTLanguage          _language;
    uint                _stopsLimit;
    uint                _busLimit;
    float               _locationDistance;
}

- (id)initWithUrlPath:(NSString*)urlPath And:(MTLanguage)lang;
- (BOOL)connectToServer;

- (BOOL)getBusNotices:(NSMutableArray*)notices;
- (BOOL)getRoutesForNotices:(NSMutableArray*)notices;

@end
