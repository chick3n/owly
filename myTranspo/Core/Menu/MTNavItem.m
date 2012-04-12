//
//  MTNavItem.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTNavItem.h"

@interface MTNavItem ()
- (void)parseIconType:(NSNumber*)type;
- (void)parseNotificationType:(NSNumber*)type;
- (void)parseSelectorType:(NSNumber*)type;
@end

@implementation MTNavItem

@synthesize icon                    = _icon;
@synthesize title                   = _title;
@synthesize notificationMessage     = _notificationMessage;
@synthesize type                    = _type;
@synthesize hasAlert                = _hasAlert;
@synthesize language                = _language;
@synthesize viewController          = _viewController;

- (id)initWithTitle:(NSString*)title WithIcon:(MTNavIcon)icon WithLanguage:(MTLanguage)language
{
    self = [super init];
    if(self)
    {
        _icon = icon;
        _title = title;
        _notificationMessage = nil;
        _type = MTNAVNOTIFICATIONTYPENONE;
        _hasAlert = NO;
        _language = language;
        _viewController = MTVCMENU;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dic WithLanguage:(MTLanguage)language
{
    self = [super init];
    if(self)
    {
        _language = language;
        [self parseIconType:[dic objectForKey:@"NavIcon"]];
        [self parseNotificationType:[dic objectForKey:@"NotificationType"]];
        [self parseSelectorType:[dic objectForKey:@"Selector"]];
        _title = (_language == MTLANGUAGE_ENGLISH) ? [dic valueForKey:@"NavTitle"] : [dic valueForKey:@"NavTitleFrench"];
        _hasAlert = NO;
        _notificationMessage = nil;
    }
    return self;
}

- (void)parseIconType:(NSNumber*)type
{
    switch ([type intValue]) {
        case 0: //Account
            _icon = MTNAVICONACCOUNT;
            break;
        case 1: //My Buses
            _icon = MTNAVICONFAVORITES;
            break;
        case 2: //Trains
            _icon = MTNAVICONTRAINS;
            break;
        case 4: //Stops
            _icon = MTNAVICONSTOPS;
            break;
        case 5: //Notices
            _icon = MTNAVICONNOTICES;
            break;
        case 6: //Trip Planner
            _icon = MTNAVICONTRIPPLANNER;
            break;
            
    }
}

- (void)parseNotificationType:(NSNumber*)type
{
    switch ([type intValue]) {
        case 1: //Message Type
            _type = MTNAVNOTIFICATIONTYPECOUNT;
            break;
        case 2: //alert Type
            _type = MTNAVNOTIFICATIONTYPEALERT;
            break;
        default:
            _type = MTNAVNOTIFICATIONTYPENONE;
            break;
    }
}

- (void)parseSelectorType:(NSNumber*)type
{
    switch ([type intValue]) {
        case 0: //Menu
            _viewController = MTVCMENU;
            break;
        case 1: //favorites
            _viewController = MTVCMYBUSES;
            break;
        case 2: //stops
            _viewController = MTVCSTOPS;
            break;       
        case 4: //trains
            _viewController = MTVCTRAIN;
            break;
        case 5: //settings
            _viewController = MTVCSETTINGS;
            break;
        default: //unknown
            _viewController = MTVCUNKNOWN;
            break;
    }
}

@end
