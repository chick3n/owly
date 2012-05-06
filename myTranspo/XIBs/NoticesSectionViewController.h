//
//  NoticesSectionViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"
#import "MTRightButton.h"
#import "NoticesDataViewController.h"
#import "MTSearchCell.h"

@interface NoticesSectionViewController : MTBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    //UI Components
    IBOutlet UITableView*           _tableView;
    IBOutlet UILabel*               _emptyTable;
}

@property (nonatomic, weak)     NSArray*        data;

@end
