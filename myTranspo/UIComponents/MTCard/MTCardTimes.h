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

#define kCardTimesHeaderHeight 23

@interface MTCardTimes : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)     MTCellAlert*        cellAlert;
@property (nonatomic, strong)     NSArray*            timesWeekday;
@property (nonatomic, strong)     NSArray*            timesSaturday;
@property (nonatomic, strong)     NSArray*            timesSunday;
@property (nonatomic, weak)       id<CardTimesRowCellDelegate> cellDelegate;

- (float)heightForTablesData;
- (void)displayCellAlert:(NSString*)headingForAlert Row:(int)row Section:(int)section Center:(int)center;

@end
