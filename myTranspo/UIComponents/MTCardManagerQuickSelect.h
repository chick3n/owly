//
//  MTCardManagerQuickSelect.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTIncludes.h"

@protocol MTCardManagerQuickSelectDelegate <NSObject>
@required
- (void)quickSelect:(id)owner receivedClick:(int)row;
@end

@interface MTCardManagerQuickSelect : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView* headerBar;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) NSArray* data;
@property (nonatomic, weak) id<MTCardManagerQuickSelectDelegate> delegateQuick;

@end
