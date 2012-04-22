//
//  TripPlannerViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBaseViewController.h"
#import "MTTripPlanner.h"
#import "MTQueueSafe.h"
#import "TripDetailsDisplay.h"

#define kTripDetialsDisplaySize CGSizeMake(280, 2000)

@interface TripPlannerViewController : MTBaseViewController <MyTranspoDelegate, UITableViewDelegate, UITableViewDataSource, MTQueueSafe>
{
    NSDictionary*               _tripDetails;
    MTTripPlanner*              _tripPlanner;
    NSMutableArray*             _data; //TripDetailsDisplay;
    
    //UIComponents
    IBOutlet UITableView*                _tableView;
}
@end
