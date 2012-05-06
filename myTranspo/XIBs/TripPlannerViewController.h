//
//  TripPlannerViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MTBaseViewController.h"
#import "MTTripPlanner.h"
#import "MTQueueSafe.h"
#import "TripDetailsDisplay.h"
#import "TripTextField.h"
#import "TripDetailsCell.h"
#import "SettingsMultiType.h"
#import "SettingsListMultiViewController.h"
#import "MTRightButton.h"

#define kAccessible NSLocalizedString(@"ACCESSIBLE", nil)
#define kRegularFare NSLocalizedString(@"REGULAREFARE", nil)
#define kExcludeSTO NSLocalizedString(@"EXCLUDESTO", nil)
#define kBikeRacks NSLocalizedString(@"BIKERACK", nil)

#define kOptionsIndent 4

static NSString* CurrentLocation = @"(Current Location)";

typedef struct
{
    BOOL accessible;
    BOOL regularFare;
    BOOL excludeSto;
    BOOL bikeRacks;
} TPOptions;

@interface TripPlannerViewController : MTBaseViewController <MyTranspoDelegate, UITableViewDelegate, UITableViewDataSource, MTQueueSafe, UITextFieldDelegate>
{
    NSDictionary*               _tripDetails;
    MTTripPlanner*              _tripPlanner;
    NSMutableArray*             _data; //TripDetailsDisplay;
   // TPOptions                   _options;
    SettingsMultiType*          _options;
    CLGeocoder*                 _geoCoder;
    NSString*                   _currentLocation;
    BOOL                        _hasInputtedText;
    
    //UIComponents
    IBOutlet UITableView*               _tableView;
    IBOutlet TripTextField*             _startLocation;
    IBOutlet TripTextField*             _endLocation;
    IBOutlet UIButton*                  _flipLocations;
    IBOutlet UILabel*                   _tripDateLabel;
    IBOutlet UIButton*                  _changeDate;
    IBOutlet UIDatePicker*              _changeDateViewer;
    IBOutlet UIView*                    _headerView;
    IBOutlet UIButton*                  _optionsButton;
    IBOutlet UIView*                    _optionsView;
    IBOutlet UIActivityIndicatorView*   _loadingView;
}

- (IBAction)flipLocations:(id)sender;
- (IBAction)changeTripDate:(id)sender;
- (IBAction)toggleChangeDateViewer:(id)sender;
- (IBAction)changeOptions:(id)sender;

@end
