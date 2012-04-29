//
//  MTCardTimes.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCardTimesRowCell.h"
#import "MTCellAlert.h"
#import "MTTime.h"

#define kCardTimesHeaderHeight 23

@protocol CardTimesDelegate <NSObject>

@optional
- (void)cardTimes:(id)owner AddAlertForTime:(MTTime*)time;

@end

@interface MTCardTimes : UITableView <UITableViewDataSource, UITableViewDelegate, CellAlertDelegate, CardTimesRowCellDelegate>

@property (nonatomic, strong)       MTCellAlert*        cellAlert;
@property (nonatomic, weak)         NSArray*            timesWeekday;
@property (nonatomic, weak)         NSArray*            timesSaturday;
@property (nonatomic, weak)         NSArray*            timesSunday;
@property (nonatomic, weak)         NSArray*            alertNotifications;

@property (nonatomic, weak)         id<CardTimesDelegate>        cellAlertDelegate;

- (float)heightForTablesData;
- (void)displayCellAlert:(NSString*)headingForAlert ForCell:(MTCardCellButton*)cell;
- (void)hideAlert;

@end
