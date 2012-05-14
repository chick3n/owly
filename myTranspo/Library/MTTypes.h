//
//  MTTypes.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#ifndef myTranspoOC_MTTypes_h
#define myTranspoOC_MTTypes_h

typedef enum
{
    MTDIRECTION_NORTH = 0
    , MTDIRECTION_SOUTH
    , MTDIRECTION_EAST
    , MTDIRECTION_WEST
    , MTDIRECTION_UNKNOWN
} MTDirection;

#define kMTLANGUAGEENGLISH @"English"
#define kMTLANGUAGEFRENCH @"Francais"
typedef enum
{
    MTLANGUAGE_ENGLISH = 0
    , MTLANGUAGE_FRENCH
} MTLanguage;

typedef enum
{
    MTTRANSPOTYPE_OC = 0
    , MTTRANSPOTYPE_TORONTO
    , MTTRANSPOTYPE_MONTREAL
    , MTTRANSPOTYPE_VANCOUVER
    , MTTRANSPOTYPE_UNKNOWN
} MTTranspoTypes;

typedef enum
{
    MTBUSTYPES_40FOOT = 0 //40 only
    , MTBUSTYPES_60FOOT //60 only
    , MTBUSTYPES_40AND60 //either or
    , MTBUSTYPES_DD //double decker
    , MTBUSTYPES_EA //low floor & easy access
    , MTBUSTYPES_B //bike rack
    , MTBUSTYPES_DEH //diesel electric hybrid
    , MTBUSTYPES_UNKNOWN
} MTBusTypes;

typedef enum
{
    MTRESULTSTATE_SUCCESS = 0
    , MTRESULTSTATE_FAILED
    , MTRESULTSTATE_DONE
} MTResultState;

typedef enum
{
    MTUPDATETYPE_ALL = 0
    , MTUPDATETYPE_API
    , MTUPDATETYPE_TIMES
    , MTUPDATETYPE_DISTANCE
    , MTUPDATETYPE_DIRECTION
    , MTUPDATETYPE_TITLE_AND_DISTANCE
} MTUpdateType;

#define kMTCITYOTTAWA @"Ottawa"
#define kMTCITYTORONTO @"Toronto"
#define kMTCITYMONTREAL @"Montreal"
#define kMTCITYVANCOUVER @"Vancouver"

typedef enum
{
    MTCITYOTTAWA = 0
    , MTCITYTORONTO
    , MTCITYMONTREAL
    , MTCITYVANCOUVER
} MTCity;

#define kMTALERT5MINS @"5 mins"
#define kMTALERT10MINS @"10 mins"
#define kMTALERT15MINS @"15 mins"
#define kMTALERT20MINS @"20 mins"
#define kMTALERT30MINS @"30 mins"
#define kMTALERT45MINS @"45 mins"
#define kMTALERT60MINS @"60 mins"

typedef enum
{
    MTALERT5MINS = 0
    , MTALERT10MINS
    , MTALERT15MINS
    , MTALERT20MINS
    , MTALERT30MINS
    , MTALERT45MINS
    , MTALERT60MINS
} MTAlertTimes;

#pragma mark - NOTIFICATION STUFF

static NSString* kMTNotificationUpdateTypeKey = @"MTNotificationUpdate";
static NSString* kMTNotificationAlertTypeKey = @"MTNotificationAlert";
static NSString* kMTNotificationTypeKey = @"MTNotificationType";

static NSString* kMTNotificationStopKey = @"MTNotificationStop";
static NSString* kMTNotificationBusKey = @"MTNotificationBus";

static NSString* kMTNotificationBusNumberKey = @"MTNotificationBusNumber";
static NSString* kMTNotificationStopNumberKey = @"MTNotificationStopNumber";

static NSString* kMTNotificationTripKey = @"MTNotificationTrip";
static NSString* kMTNotificationBusDisplayHeading = @"MTNotificationBusDisplayHeading";
static NSString* kMTNotificationStopStreetName = @"MTNotificationStopStreetName";
static NSString* kMTNotificationTripTimeKey = @"MTNotificationTripTime";

static NSString* kMTNotificationTripAlertTimeKey = @"MTNotificationTripAlertTimeKey";
static NSString* kMTNotificationDayOfWeek = @"MTNotificationDayOfWeek";

#endif
