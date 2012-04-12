//
//  MTOCApi.h
//  myTranspoOC - This is direct access to the external API provided by OC Transpo
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTInteraction.h"
#import "MTDefinitions.h"
#import "XMLReader.h"

@interface MTOCApi : NSObject <MTInteraction>
{
    NSString*           _urlPath;
    NSURL*              _url;
    MTLanguage          _language;
    BOOL                _isAvailable;
    NSString*           _apiKey;
}

@property (nonatomic, strong)   NSString*               UrlPath;

- (id)initWithLanguage:(MTLanguage)lang AndUrlPath:(NSString*)urlPath UsingAPIKey:(NSString*)apiKey;
- (BOOL)getNextTrips:(NSMutableArray*)_trips ForTrip:(MTTrip*)stop ForRoute:(MTBus*)bus;

@end
