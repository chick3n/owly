//
//  SettingsViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZUUIRevealController.h"
#import "MTBaseViewController.h"
#import "MTSettings.h"
#import "SettingsType.h"
#import "MTDefinitions.h"
#import "SettingsListViewController.h"
#import "MTSettingsTableView.h"
#import "SettingsManageNotificationsViewController.h"
#import "OfflineManager.h"

#define kFullAppRefresh @"MTAPPREFRESH"

@interface SettingsViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate, SettingsTypeDelegate, OfflineManagerDelegate>
{
    MTSettings*                 _settings;
    NSMutableArray*             _data;
    OfflineManager*             _offlineManager;
    
    //ui compinents
    IBOutlet UITextField*       _keyboardDismisser;
}

@property (nonatomic, weak)     IBOutlet MTSettingsTableView*            tableView;

@end
