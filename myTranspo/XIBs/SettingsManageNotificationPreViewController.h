//
//  SettingsManageNotificationPreViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBaseViewController.h"
#import "MTDefinitions.h"
#import "MTHelper.h"
#import "MTRightButton.h"
#import "SettingsManageNotificationsViewController.h"

#define kAlertsCellHeight 72

typedef NSComparisonResult(^SortNotificationsDayOfWeek)(id obj1, id obj2);
typedef NSComparisonResult(^SortNotificationsBusNumber)(id obj1, id obj2);

@interface SettingsManageNotificationPreViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    //ui components
    IBOutlet UITableView             *_tableView;
}

@property (nonatomic, strong) NSArray       *data;
@property (nonatomic, strong) NSDictionary  *tripData;
@property (nonatomic, copy)   SortNotificationsDayOfWeek sortNotificationsDayOfWeek;

@end
