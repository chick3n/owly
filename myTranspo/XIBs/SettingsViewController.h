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

#define kFullAppRefresh @"MTAPPREFRESH"

@interface SettingsViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate, SettingsTypeDelegate>
{
    MTSettings*                 _settings;
    NSMutableArray*             _data;
    
    //ui compinents
    IBOutlet UITextField*       _keyboardDismisser;
    IBOutlet UIWebView*         _webView;
}

@property (nonatomic, weak)     IBOutlet MTSettingsTableView*            tableView;

@end
