//
//  StopsFavoriteViewControllerViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-12.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRefreshTableView.h"
#import "MTSearchCell.h"
#import "MTTime.h"
#import "MTStop.h"
#import "MTBaseViewController.h"
#import "MTRightButton.h"

@interface StopsFavoriteViewControllerViewController : MTBaseViewController <UITableViewDataSource, UITableViewDelegate, MyTranspoDelegate, MTRefreshDelegate>
{
    BOOL                            _clearing;
    BOOL                            _filterMode;
    //ui components
    IBOutlet MTRefreshTableView*    _tableView;
    UIBarButtonItem                 *_filterButton, *_doneButton;
    UILabel                         *_accessoryViewTime;
    IBOutlet UIBarButtonItem        *_selectNone, *_selectAll;
    IBOutlet UIToolbar              *_tabBar;
    MTRightButton                   *_doneButtonView;
}

@property (nonatomic, strong)       NSArray *data;
@property (nonatomic, strong)       MTStop *stop;

- (IBAction)selectNone:(id)sender;
- (IBAction)selectAll:(id)sender;

@end
