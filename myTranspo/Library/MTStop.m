//
//  MTStop.m
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTStop.h"

@implementation MTStop

@synthesize StopId                  = _stopId;
@synthesize StopNumber              = _stopNumber;
@synthesize Longitude               = _stopLongitude;
@synthesize Latitude                = _stopLatitude;
@synthesize StopName                = _stopName;
@synthesize BusIds                  = _busIds;
@synthesize Language                = _language;
@synthesize DistanceFromOrigin      = _distanceFromOrigin;
@synthesize IsUpdating              = _isUpdating;
@synthesize CurrentLat              = _currentLat;
@synthesize CurrentLon              = _currentLon;
@synthesize UpdateCount             = _updatedCount;
@synthesize MTCardCellHelper        = _MTCardCellHelper;
@synthesize MTCardCellIsAnimating   = _MTCardCellIsAnimating;
@synthesize isFavorite              = _isFavorite;
@synthesize upcomingBuses           = _upcomingBuses;

- (void)setIsUpdating:(BOOL)IsUpdating
{
    _isUpdating = IsUpdating;
    if(!IsUpdating)
        _updatedCount += 1;
}

- (NSString*)StopNameDisplay
{
    //Upper case first lower case rest all words
    //NSString* original = _stopName;
    
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [[_stopName lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [firstCharacters appendString:[firstLetter uppercaseString]];
            [firstCharacters appendString:[word substringFromIndex:1]];
            [firstCharacters appendString:@" "];
        }
    }
    
    return (NSString*)firstCharacters;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _stopId = @"";
        _stopNumber = -1;
        _stopLatitude = 0;
        _stopLongitude = 0;
        _stopName = NSLocalizedString(@"MTDEF_STOPNAMEUNKNOWN", nil);
        _busIds = [[NSMutableArray alloc] init];
        _language = MTLANGUAGE_ENGLISH;
        _distanceFromOrigin = -1;
        _isUpdating = YES;
        _currentLat = 0;
        _currentLon = 0;
        _updatedCount = 0;
        _MTCardCellHelper = NO;
        _MTCardCellIsAnimating = NO;
        _isFavorite = NO;
        _upcomingBuses = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithLanguage:(MTLanguage)lang
{
    self = [super init];
    
    if (self) {
        _stopId = @"";
        _stopNumber = -1;
        _stopLongitude = 0;
        _stopLatitude = 0;
        _stopName = NSLocalizedString(@"MTDEF_STOPNAMEUNKNOWN", nil);
        _busIds = [[NSMutableArray alloc] init];
        _language = MTLANGUAGE_ENGLISH;
        _distanceFromOrigin = -1;
        _isUpdating = YES;
        _currentLat = 0;
        _currentLon = 0;
        _updatedCount = 0;
        _MTCardCellHelper = NO;
        _MTCardCellIsAnimating = NO;
        _isFavorite = NO;
        _upcomingBuses = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString*)getDistanceOfStop
{
    if(_distanceFromOrigin < 0)
        return MTDEF_STOPDISTANCEUNKNOWN;
    
    return [NSString stringWithFormat:@"%2.1f km", _distanceFromOrigin];
}

- (MTBus*)getFirstBus
{
    if(_busIds == nil)
        return nil;
    
    if(_busIds.count <= 0)
        return nil;
    
    if(_isFavorite)
        return nil;
    
    return [_busIds objectAtIndex:0];
}

- (void)updatingState:(BOOL)state
{
    _isUpdating = state;
    if(!state)
        _updatedCount += 1;
}

- (void)cancelQueuesForBuses
{
    for(MTBus* bus in _busIds)
    {
        bus.cancelQueue = YES;
    }
}

- (void)restoreQueuesForBuses
{
    for(MTBus* bus in _busIds)
    {
        bus.cancelQueue = NO;
    }
}

#pragma mark - DEBUG HELPERS

- (NSString *)description
{
    return [NSString stringWithFormat:@"STOP: %@ , %@", _stopId, _stopName];
}

@end
