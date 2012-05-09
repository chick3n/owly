//
//  SettingsType.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    SGACCOUNTINFO = 0
    , SGAPPLICATION = 1
    , SGDATA = 2
} SettingGroup;

typedef enum
{
    STLIST = 0
    , STCHECKBOX
    , STCHOICE
    , STTEXTBOX
    , STPASSWORD
    , STOTHER
    , STMULTI
    , STDOWNLOAD
} SettingTypes;

@protocol SettingsTypeDelegate <NSObject>
@required
- (void)settingsTypeHasChanged:(id)setting;
@end

@interface SettingsType : NSObject

@property (nonatomic)               SettingGroup            group;
@property (nonatomic)               SettingTypes            type;
@property (nonatomic, strong)       NSString*               title;
@property (nonatomic, strong)       NSString*               subTitle;
@property (nonatomic, strong)       NSArray*                data;
@property (nonatomic)               NSInteger               selected;
@property (nonatomic, weak)         id<SettingsTypeDelegate> delegate;
@property (nonatomic)               SEL                     modificationCaller;
@property (nonatomic)               SEL                     dataCaller;

+ (id)settingsTypeForGroup:(SettingGroup)group 
                      Type:(SettingTypes)type 
                     Title:(NSString*)title 
                  SubTitle:(NSString*)subTitle 
                      Data:(NSArray*)data 
                  Selected:(NSInteger)selected 
        ModificationCaller:(SEL)modificationCaller 
                  Delegate:(id<SettingsTypeDelegate>)delegate;

- (id)accessoryView;
- (void)selectedSettingHasChanged;

@end
