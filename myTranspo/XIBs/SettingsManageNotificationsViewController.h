//
//  SettingsManageNotificationsViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-08.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"
#import "MTDefinitions.h"
#import "MTHelper.h"
#import "MTRightButton.h"

typedef NSComparisonResult(^SortNotifications)(id obj1, id obj2);

@interface SettingsManageNotificationsViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray*                            _data;
    NSMutableArray*                     _selectedRows;
    SortNotifications                   _sortNotifications;
    
    //ui components
    IBOutlet UITableView*               _tableView;
    IBOutlet UIToolbar*                 _toolBar;
    IBOutlet UIBarButtonItem*           _removeAllButton;
    IBOutlet UIBarButtonItem*           _removeSelectedButton;
    UIBarButtonItem*                    _editButton;
    UIBarButtonItem*                    _doneButton;
}

@property (nonatomic, copy) SortNotifications sortNotifications;

- (IBAction)removeAllNotificationsClicked:(id)sender;
- (IBAction)removeSelectedNotificationsClicked:(id)sender;

@end
