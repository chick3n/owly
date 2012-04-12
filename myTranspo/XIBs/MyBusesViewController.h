//
//  MyBusesViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZUUIRevealController.h"
#import "MTCardCell.h"
#import "MTIncludes.h"
#import "MTBaseViewController.h"
#import "MTRefreshTableView.h"
#import "TripViewController.h"
#import "MenuTableViewController.h"
#import "MTOptionsDate.h"

@interface MyBusesViewController : MTBaseViewController<MyTranspoDelegate, MTCardCellDelegate, MTQueueSafe, UITableViewDataSource, UITableViewDelegate, MTRefreshDelegate, MTOptionsDateProtocol>
{
    NSMutableArray*                     _favorites;
    BOOL                                _editing;
    int                                 _loadingCounter;
    NSDate*                             _chosenDate;
    
    //UIComponents
    UIBarButtonItem*                    _editButton;
}

@property (nonatomic, strong)   IBOutlet MTRefreshTableView*   tableView;

@end
