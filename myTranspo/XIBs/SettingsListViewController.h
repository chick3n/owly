//
//  SettingsListViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsType.h"
#import "MTBaseViewController.h"

@interface SettingsListViewController : MTBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)         IBOutlet UITableView*           tableView;
@property (nonatomic, weak)         SettingsType*                   setting;

@end
