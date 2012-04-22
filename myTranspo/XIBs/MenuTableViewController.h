//
//  MenuTableViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTIncludes.h"
#import "MTNavItem.h"
#import "MTBaseViewController.h"

#include "../Core/ViewControllers.h"

@protocol MenuTableViewDelegate <NSObject>
@required
- (void)menuTable:(id)menuView selectedNewOption:(MTViewControllers)view;
@end

@interface MenuTableViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate, MyTranspoDelegate>
{
    NSTimer*                        _actionUpdates;
    NSMutableArray*                 _menu;
    IBOutlet UIButton*              _accountButton;
}

@property (nonatomic, weak)     IBOutlet UITableView*       tableView;
@property (nonatomic, weak)     id<MenuTableViewDelegate>   delegate;

- (IBAction)accountClicked:(id)sender;

@end
