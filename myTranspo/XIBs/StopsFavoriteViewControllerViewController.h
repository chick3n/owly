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
    //ui components
    IBOutlet MTRefreshTableView*            _tableView;
}

@property (nonatomic, strong)       NSArray *data;
@property (nonatomic, strong)       MTStop *stop;

@end
