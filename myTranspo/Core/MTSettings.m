//
//  MTSettings.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTSettings.h"

@interface MTSettings()
+ (NSUserDefaults*)settingsUserDefault;
- (void)initializeSettings;
@end

@implementation MTSettings

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initializeSettings];
    }
    return self;
}

- (id)initWithoutInitialization
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

- (void)initializeSettings
{
    NSDictionary *defaultValues = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myTranspoSettings" ofType:@"plist"]];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:defaultValues];
	[userDefaults setBool:false forKey:kMTConnectionWarningSent];
	[userDefaults setBool:true forKey:kMTConnectionAvailable];
	[userDefaults synchronize];
}

#pragma mark - GETTERS

- (BOOL)currentInstallVersionNeedsUpdate
{
    CGFloat bundleVersion = [(NSString*)[[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString*)kCFBundleVersionKey] floatValue];
    
    NSNumber* cBundleVersion = [userDefaults objectForKey:kMTInstalledVersion];
    if(cBundleVersion == nil)
        cBundleVersion = [NSNumber numberWithFloat:0.0];
    
    if(bundleVersion > [cBundleVersion floatValue])
    {
        //new bundle version
        return YES;
    }
    
    return NO;
}

- (BOOL)currentSettingsNeedsUpdate
{
    CGFloat settingsVersion = [(NSNumber*)[[[NSBundle mainBundle] infoDictionary] objectForKey:kMTISettingsVersion] floatValue];
    
    NSNumber* cSettingsVersion = [userDefaults objectForKey:kMTSettingsVersion];
    if(cSettingsVersion == nil)
        cSettingsVersion = [NSNumber numberWithFloat:0.0];
    
    if(settingsVersion > [cSettingsVersion floatValue])
    {
        //update new settings
        return YES;
    }
    
    return NO;
}

- (BOOL)currentDatabaseNeedsUpdate
{
    CGFloat databaseVersion = [(NSNumber*)[[[NSBundle mainBundle] infoDictionary] objectForKey:kMTIDatabaseVersion] floatValue];
    
    NSNumber* cDatabaseVersion = [userDefaults objectForKey:kMTDatabaseVersion];
    if(cDatabaseVersion == nil)
        cDatabaseVersion = [NSNumber numberWithFloat:0.0];
    
    if(databaseVersion > [cDatabaseVersion floatValue])
    {
        //update new database
        return YES;
    }
    
    return NO;
}

- (MTLanguage)languagePreference
{
#if 0
    NSString* language = [userDefaults valueForKey:kMTLanguage];
#endif
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if(language == nil)
        return MTLANGUAGE_ENGLISH;
#if 0
    else if([language isEqualToString:kMTLANGUAGEENGLISH])
        return MTLANGUAGE_ENGLISH;
    else if([language isEqualToString:kMTLANGUAGEFRENCH])
        return MTLANGUAGE_FRENCH;
#endif
    else if([language isEqualToString:@"fr"])
        return MTLANGUAGE_FRENCH;
    
    return MTLANGUAGE_ENGLISH;
}

- (MTCity)cityPreference
{
    NSString* city = [userDefaults valueForKey:kMTMyCity];
    
    if(city == nil)
        return MTCITYOTTAWA;
    else if([city isEqualToString:kMTCITYOTTAWA])
        return MTCITYOTTAWA;
    else if([city isEqualToString:kMTCITYTORONTO])
        return MTCITYTORONTO;
    else if([city isEqualToString:kMTCITYMONTREAL])
        return MTCITYMONTREAL;
    else if([city isEqualToString:kMTCITYVANCOUVER])
        return MTCITYVANCOUVER;
    
    return MTCITYOTTAWA;
}

- (NSString*)accountName
{
    KeychainItemWrapper* accountName = [[KeychainItemWrapper alloc] initWithIdentifier:kMTAccountName accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(accountName == nil)
        return nil;
    
    NSString* accountValue = [accountName objectForKey:(__bridge id)kSecAttrAccount];
    
    if(accountValue == nil)
        return nil;
    
    if(accountValue.length <= 0)
        return nil;
    
    return accountValue;
}

- (NSString*)accountNameForArary
{
    NSString* accountName = [self accountName];
    if(accountName == nil)
        return @"";
    return accountName;
}

- (NSString *)password
{
    KeychainItemWrapper* password = [[KeychainItemWrapper alloc] initWithIdentifier:kMTPassword accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(password == nil)
        return nil;
    
    NSString* passwordValue = [password objectForKey:(__bridge id)kSecValueData];
    
    if(passwordValue == nil)
        return nil;
    
    if(passwordValue.length <= 0)
        return nil;
    
    return passwordValue;
}

- (NSString*)passwordForArray
{
    NSString* passwordValue = [self password];
    if(passwordValue == nil)
        return @"";
    return passwordValue;
}

//have we shown all the helper cards?
- (BOOL)helperCards
{
    BOOL status1 = [userDefaults boolForKey:kMTHelperStops];
    BOOL status2 = [userDefaults boolForKey:kMTHelperMyBuses];
    BOOL status3 = [userDefaults boolForKey:kMTHelperTrips];
    
    return (status1 && status2 && status3);
}

- (BOOL)notificationUpdateTime
{
    return [userDefaults boolForKey:kMTNotificationUpdate];
}

- (MTAlertTimes)notificationAlertTime
{
    return [userDefaults integerForKey:kMTNotificationTime];
}

- (MTViewControllers)startupScreen
{
    return [userDefaults integerForKey:kMTNotificationStartupView];
}

- (NSString*)cityString
{
    return [userDefaults valueForKey:kMTMyCity];
}

- (NSString*)notificationAlertTimeString
{
    switch ((MTAlertTimes)[userDefaults integerForKey:kMTNotificationTime]) {
        case MTALERT5MINS:
            return kMTALERT5MINS;
        case MTALERT10MINS:
            return kMTALERT10MINS;
        case MTALERT15MINS:
            return kMTALERT15MINS;
        case MTALERT20MINS:
            return kMTALERT20MINS;
        case MTALERT30MINS:
            return kMTALERT30MINS;
        case MTALERT45MINS:
            return kMTALERT45MINS;
        case MTALERT60MINS:
            return kMTALERT60MINS;
    }
    
    return @"";
}

- (NSString*)startupScreenString
{
    switch ((MTViewControllers)[userDefaults integerForKey:kMTNotificationStartupView]) {
        case MTVCSTOPS:
            return NSLocalizedString(@"MTDEF_STOPS", nil);
        case MTVCTRAIN:
            return NSLocalizedString(@"MTDEF_VIEWCONTROLLERTRAIN", nil);
        case MTVCMYBUSES:
            return NSLocalizedString(@"MTDEF_VIEWCONTROLLERMYBUSES", nil);
        case MTVCNOTICIES:
            return NSLocalizedString(@"MTDEF_VIEWCONTROLLERNOTICES", nil);
        case MTVCTRIPPLANNER:
            return NSLocalizedString(@"MTDEF_VIEWCONTROLLERTRIPPLAN", nil);
        case MTVCSETTINGS:
            return NSLocalizedString(@"MTDEF_SETTINGSTITLE", nil);
        case MTVCUNKNOWN:
        case MTVCMENU:
            return @"";
    }
    
    return @"";
}

- (BOOL)networkNotification
{
    return [userDefaults boolForKey:kMTRConnectionWarning];
}

#pragma mark - SETTERS

- (void)updateDatabaseVersionToBundle
{
    CGFloat databaseVersion = [(NSNumber*)[[[NSBundle mainBundle] infoDictionary] objectForKey:kMTIDatabaseVersion] floatValue];
    [userDefaults setFloat:databaseVersion forKey:kMTDatabaseVersion];
    [userDefaults synchronize];
}

- (void)updateLanguage:(MTLanguage)language
{
    NSString* newLanguage;
    
    switch (language) {
        case MTLANGUAGE_ENGLISH:
            newLanguage = kMTLANGUAGEENGLISH;
            break;
        case MTLANGUAGE_FRENCH:
            newLanguage = kMTLANGUAGEFRENCH;
            break;
    }
    
    if(newLanguage != nil)
    {
        [userDefaults setValue:newLanguage forKey:kMTLanguage];
        [userDefaults synchronize];
    }
}

- (void)updateCity:(MTCity)city
{
    NSString* newCity;
    
    switch (city) {
        case MTCITYOTTAWA:
            newCity = kMTCITYOTTAWA;
            break;
        case MTCITYTORONTO:
            newCity = kMTCITYTORONTO;
            break;
        case MTCITYMONTREAL:
            newCity = kMTCITYMONTREAL;
            break;
        case MTCITYVANCOUVER:
            newCity = kMTCITYVANCOUVER;
            break;
    }
    
    if(newCity != nil)
    {
        [userDefaults setValue:newCity forKey:kMTMyCity];
        [userDefaults synchronize];
    }
}

- (void)updateAccountName:(NSString *)name
{
    if(name == nil)
        return;
    
    if(name.length <= 0)
        return;
    
    KeychainItemWrapper* accountName = [[KeychainItemWrapper alloc] initWithIdentifier:kMTAccountName accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(accountName == nil)
        return;
    
    [accountName setObject:name forKey:(__bridge id)kSecAttrAccount];
}

- (void)updatePassword:(NSString *)password
{
    if(password == nil)
        return;
    
    if(password.length <= 0)
        return;
    
    KeychainItemWrapper* passwordName = [[KeychainItemWrapper alloc] initWithIdentifier:kMTPassword accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(passwordName == nil)
        return;
    
    [passwordName setObject:password forKey:(__bridge id)kSecValueData];
}

- (void)resetAllHelperPages
{
    [userDefaults setBool:NO forKey:kMTHelperStops];
    [userDefaults setBool:NO forKey:kMTHelperMyBuses];
    [userDefaults setBool:NO forKey:kMTHelperTrips];
    [userDefaults synchronize];
}

- (void)updateAllHelperPages:(BOOL)choice
{
    [userDefaults setBool:!choice forKey:kMTHelperStops];
    [userDefaults setBool:!choice forKey:kMTHelperMyBuses];
    [userDefaults setBool:!choice forKey:kMTHelperTrips];
    [userDefaults synchronize];
}

- (void)updateNotificationAlertTime:(MTAlertTimes)time
{
    [userDefaults setInteger:time forKey:kMTNotificationTime];
    [userDefaults synchronize];
}

- (void)updateNotificationUpdateTimes:(BOOL)choice
{
    [userDefaults setBool:choice forKey:kMTNotificationUpdate];
    [userDefaults synchronize];
}

- (void)updateStartupScreen:(MTViewControllers)choice
{
    [userDefaults setInteger:choice forKey:kMTNotificationStartupView];
    [userDefaults synchronize];
}

- (void)updateNetworkNotification:(BOOL)toggle
{
    [userDefaults setBool:toggle forKey:kMTRConnectionWarning];
    [userDefaults synchronize];
}

#pragma mark - QUICK CALLS

+ (NSUserDefaults*)settingsUserDefault
{
    NSDictionary *defaultValues = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myTranspoSettings" ofType:@"plist"]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:defaultValues];
    
    return userDefaults;
}

+ (BOOL)showMyBusesHelper
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    BOOL status = [userDefaults boolForKey:kMTHelperMyBuses];
    
    if(status == NO)
    {
        [userDefaults setBool:YES forKey:kMTHelperMyBuses];
        [userDefaults synchronize];
    }
    
    userDefaults = nil;
    
    return status;
}

+ (BOOL)showStopsHelper
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    BOOL status = [userDefaults boolForKey:kMTHelperStops];
    
    if(status == NO)
    {
        [userDefaults setBool:YES forKey:kMTHelperStops];
        [userDefaults synchronize];
    }
    
    userDefaults = nil;
    
    return status;
}

+ (BOOL)showTripsHelper
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    BOOL status = [userDefaults boolForKey:kMTHelperTrips];
    
    if(status == NO)
    {
        [userDefaults setBool:YES forKey:kMTHelperTrips];
        [userDefaults synchronize];
    }
    
    userDefaults = nil;
    
    return status;
}

+ (MTLanguage)languagePreference
{
#if 0
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    NSString* language = [userDefaults valueForKey:kMTLanguage];
#endif
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];

    if(language == nil)
        return MTLANGUAGE_ENGLISH;
    else if([language isEqualToString:@"fr"])
        return MTLANGUAGE_FRENCH;
    else
        return MTLANGUAGE_FRENCH;
#if 0
    userDefaults = nil;
#endif
    return MTLANGUAGE_ENGLISH;
}

+ (MTCity)cityPreference
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    NSString* city = [userDefaults valueForKey:kMTMyCity];
    
    if(city == nil)
        return MTCITYOTTAWA;
    else if([city isEqualToString:kMTCITYOTTAWA])
        return MTCITYOTTAWA;
    else if([city isEqualToString:kMTCITYTORONTO])
        return MTCITYTORONTO;
    else if([city isEqualToString:kMTCITYMONTREAL])
        return MTCITYMONTREAL;
    else if([city isEqualToString:kMTCITYVANCOUVER])
        return MTCITYVANCOUVER;
    
    userDefaults = nil;
    
    return MTCITYOTTAWA;
}

+ (NSString*)accountName
{
    KeychainItemWrapper* accountName = [[KeychainItemWrapper alloc] initWithIdentifier:kMTAccountName accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(accountName == nil)
        return nil;
    
    NSString* accountValue = [accountName objectForKey:(__bridge id)kSecAttrAccount];
    
    if(accountValue == nil)
        return nil;
    
    if(accountValue.length <= 0)
        return nil;
    
    return accountValue;
}

+ (NSString*)password
{
    KeychainItemWrapper* passwordName = [[KeychainItemWrapper alloc] initWithIdentifier:kMTPassword accessGroup:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]];
    
    if(passwordName == nil)
        return nil;
    
    NSString* passwordValue = [passwordName objectForKey:(__bridge id)kSecValueData];
    
    if(passwordValue == nil)
        return nil;
    
    if(passwordValue.length <= 0)
        return nil;
    
    return passwordValue;
}

+ (BOOL)notificationUpdateTime
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    return [userDefaults boolForKey:kMTNotificationUpdate];
}

+ (NSString*)notificationAlertTimeString
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    MTAlertTimes alertTime = [userDefaults integerForKey:kMTNotificationTime];
    
    switch (alertTime) {
        case MTALERT5MINS:
            return kMTALERT5MINS;
        case MTALERT10MINS:
            return kMTALERT10MINS;
        case MTALERT15MINS:
            return kMTALERT15MINS;
        case MTALERT20MINS:
            return kMTALERT20MINS;
        case MTALERT30MINS:
            return kMTALERT30MINS;
        case MTALERT45MINS:
            return kMTALERT45MINS;
        case MTALERT60MINS:
            return kMTALERT60MINS;
    }
    
    return nil;
}

+ (int)notificationAlertTimeInt
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    MTAlertTimes alertTime = [userDefaults integerForKey:kMTNotificationTime];
    
    switch (alertTime) {
        case MTALERT5MINS:
            return 5;
        case MTALERT10MINS:
            return 10;
        case MTALERT15MINS:
            return 15;
        case MTALERT20MINS:
            return 20;
        case MTALERT30MINS:
            return 30;
        case MTALERT45MINS:
            return 45;
        case MTALERT60MINS:
            return 60;
    }
    
    return 15;
}

+ (int)startupScreen
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    return [userDefaults integerForKey:kMTNotificationStartupView];
}

+ (BOOL)networkNotification
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    
    return [userDefaults boolForKey:kMTRConnectionWarning];
}

+ (void)networkNotificationStatus:(BOOL)status
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    [userDefaults setBool:status forKey:kMTRConnectionWarning];
    [userDefaults synchronize];
}

+ (CGFloat)ocOfflineVersion
{
    NSUserDefaults* userDefaults = [MTSettings settingsUserDefault];
    CGFloat version = [userDefaults floatForKey:kMTOCOfflineVersion];
    return version;
}

@end
