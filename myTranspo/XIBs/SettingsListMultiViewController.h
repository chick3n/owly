//
//  SettingsListMultiViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-01.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsType.h"
#import "MTBaseViewController.h"
#import "MTRightButton.h"
#import "SettingsMultiType.h"

@interface SettingsListMultiViewController : MTBaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray*            _data;
}

@property (nonatomic, weak)         IBOutlet UITableView*           tableView;
@property (nonatomic, weak)         SettingsMultiType*              multiSettings;

@end
