//
//  NoticesViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"
#import "MTIncludes.h"
#import "NoticesSectionViewController.h"

@interface NoticesViewController : MTBaseViewController <UITableViewDataSource, UITableViewDelegate, MyTranspoDelegate>
{
    NSDictionary*                       _data;
    NSArray*                            _keys; //to ensure that the order is always the same as [dic allKeys] deosnt garauntee that
    
    //UI Components
    IBOutlet UITableView*               _tableView;
    IBOutlet UIActivityIndicatorView*   _loader;
}
@end
