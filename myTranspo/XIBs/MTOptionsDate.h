//
//  MTOptionsDate.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTNavCell.h"
#import "MTNavFooter.h"
#import "ZUUIRevealController.h"

@protocol MTOptionsDateProtocol <NSObject>
@required
- (void)optionsDate:(id)options dateHasChanged:(NSDate*)newDate;
@end

@interface MTOptionsDate : UITableViewController
{
    NSArray*                _data;
    NSDateFormatter*        _dateFormatter;
}


@property (nonatomic, strong)   NSDate*     lastDate;
@property (nonatomic, strong)   NSDate*     selectedDate;
@property (nonatomic, weak)     id<MTOptionsDateProtocol>       delegateOptions;

@end
