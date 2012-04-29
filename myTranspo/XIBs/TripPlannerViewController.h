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
#import "TripTextField.h"
#import "TripDetailsCell.h"

#define kTripDetialsDisplaySize CGSizeMake(210, 2000)

@interface TripPlannerViewController : MTBaseViewController <MyTranspoDelegate, UITableViewDelegate, UITableViewDataSource, MTQueueSafe, UITextFieldDelegate>
{
    NSDictionary*               _tripDetails;
    MTTripPlanner*              _tripPlanner;
    NSMutableArray*             _data; //TripDetailsDisplay;
    
    //UIComponents
    IBOutlet UITableView*               _tableView;
    IBOutlet TripTextField*             _startLocation;
    IBOutlet TripTextField*             _endLocation;
    IBOutlet UIButton*                  _flipLocations;
    IBOutlet UILabel*                   _tripDateLabel;
    IBOutlet UIButton*                  _changeDate;
    IBOutlet UIDatePicker*              _changeDateViewer;
}

- (IBAction)flipLocations:(id)sender;
- (IBAction)changeTripDate:(id)sender;
- (IBAction)toggleChangeDateViewer:(id)sender;

@end
