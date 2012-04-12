//
//  MTSettings.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTypes.h"
#import "KeychainItemWrapper.h"
#import "ViewControllers.h"

static NSString* kMTFistTimeUse = @"FirstTimeUse";
static NSString* kMTInstalledVersion = @"InstalledVersion";
static NSString* kMTDatabaseVersion = @"DatabaseVersion";
static NSString* kMTConnectionWarningSent = @"ConnectionWarningSent";
static NSString* kMTConnectionAvailable = @"ConnectionAvailable";
static NSString* kMTSettingsVersion = @"SettingsVersion";
static NSString* kMTLanguage = @"Language";
static NSString* kMTMyCity = @"myCity";
static NSString* kMTAccountName = @"AccountName";
static NSString* kMTPassword = @"Password";
static NSString* kMTNotificationTime = @"NotificationTime";
static NSString* kMTNotificationUpdate = @"NotificationUpdate";
static NSString* kMTNotificationStartupView = @"kMTNotificationStartupView";

//helper cards
static NSString* kMTHelperMyBuses = @"HelperMyBusesShown";
static NSString* kMTHelperTrips = @"HelperTripsShown";
static NSString* kMTHelperStops = @"HelperStopsShown";

//Info Bundle
static NSString* kMTISettingsVersion = @"Settings Version";
static NSString* kMTIDatabaseVersion = @"Database Version";

//DATA SETS
#define kMTDLanguage [NSArray arrayWithObjects:kMTLANGUAGEENGLISH, kMTLANGUAGEFRENCH, nil]
#define kMTDCity [NSArray arrayWithObjects:kMTCITYOTTAWA, nil]
#define kMTDAlerts [NSArray arrayWithObjects:kMTALERT5MINS, kMTALERT10MINS, kMTALERT15MINS, kMTALERT20MINS, kMTALERT30MINS, kMTALERT45MINS, kMTALERT60MINS, nil]
#define kMTDStartScreen(lang) [NSArray arrayWithObjects:\
                                NSLocalizedString(@"MTDEF_VIEWCONTROLLERMYBUSES", nil)\
                                , NSLocalizedString(@"MTDEF_STOPS", nil)\
                                , NSLocalizedString(@"MTDEF_VIEWCONTROLLERNOTICES", nil)\
                                , NSLocalizedString(@"MTDEF_VIEWCONTROLLERTRIPPLAN", nil)\
                                , NSLocalizedString(@"MTDEF_VIEWCONTROLLERTRAIN", nil)\
                                , NSLocalizedString(@"MTDEF_SETTINGSTITLE", nil)\
                                , nil]

@interface MTSettings : NSObject
{
    NSUserDefaults* userDefaults;
}

- (id)initWithoutInitialization;

//getters
- (BOOL)currentDatabaseNeedsUpdate;
- (BOOL)currentInstallVersionNeedsUpdate;
- (BOOL)currentSettingsNeedsUpdate;
- (MTLanguage)languagePreference;
- (MTCity)cityPreference;
- (NSString*)accountName;
- (NSString*)accountNameForArary;
- (NSString*)password;
- (NSString*)passwordForArray;
- (BOOL)helperCards;
- (BOOL)notificationUpdateTime;
- (MTAlertTimes)notificationAlertTime;
- (MTViewControllers)startupScreen;

//setters
- (void)updateDatabaseVersionToBundle;
- (void)updateLanguage:(MTLanguage)language;
- (void)updateCity:(MTCity)city;
- (void)updateAccountName:(NSString*)name;
- (void)updatePassword:(NSString*)password;
- (void)resetAllHelperPages;
- (void)updateAllHelperPages:(BOOL)choice;
- (void)updateNotificationAlertTime:(MTAlertTimes)time;
- (void)updateNotificationUpdateTimes:(BOOL)choice;
- (void)updateStartupScreen:(MTViewControllers)choice;

//quick calls - TODO doesnt work
+ (BOOL)showMyBusesHelper;
+ (BOOL)showStopsHelper;
+ (BOOL)showTripsHelper;
+ (MTLanguage)languagePreference;
+ (MTCity)cityPreference;
+ (NSString*)accountName;
+ (NSString*)password;
+ (BOOL)notificationUpdateTime;
+ (NSString*)notificationAlertTimeString;
+ (int)notificationAlertTimeInt;
+ (int)startupScreen;

@end
