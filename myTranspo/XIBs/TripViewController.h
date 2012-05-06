//
//  TripViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-27.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MTBaseViewController.h"
#import "MTIncludes.h"
#import "MTTripCell.h"
#import "MTTrip.h"
#import "MTTime.h"
#import "MTBusAnnotation.h"
#import "MTStopAnnotation.h"
#import "MTRightButton.h"
#import "MTCardTimes.h"
#import "MTCellAlert.h"

#define kMTBusTimerInterval 60

@interface TripViewController : MTBaseViewController 
<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MTQueueSafe, MyTranspoDelegate, MTTripCellDelegate, MKMapViewDelegate, CardTimesDelegate>
{
    NSArray*							_trips;
	NSArray*							_timesDisplayTimes;
	NSArray*							_timesOptions;
	NSArray*							_tempTimesChanged;
    MTTime*                             _trip;
    MTTrip*                             _currentTrip;
    NSInteger                           _pickerViewSelectedRow; //only used for the initial setting of picker view.
    NSTimer*                            _busTimer;
    MTBusAnnotation*                    _busAnnotation;
    int                                 _busTripLocation;
    NSArray*                            _tripNotifications;
    CGPoint                             _tripFrame;
    CGPoint                             _timeTableFrame;
    
	//ui components
	IBOutlet UITableView*				_tableView;
	IBOutlet UIActivityIndicatorView*   _loadingIndicator;
	IBOutlet MKMapView*					_mapView;
	IBOutlet UIPickerView*				_timesPickerView;
	UIBarButtonItem*					_timesChangeButton;
	UIBarButtonItem*					_timesDoneButton;
	UIBarButtonItem*					_timesCancelButton;
	UIBarButtonItem*					_initialLeftButton;
    UIButton*                           _rightButton;
    UIView*                             _tableViewHeader;
    UIImageView*                        _backgroundImage;
    UIImageView*                        _backgroundImage2;
    IBOutlet MTCardTimes*               _timeTable;
}


@property (nonatomic, strong)	UITableView*		tableView;
@property (nonatomic, weak)		MTStop*				stop;
@property (nonatomic, weak)		MTBus*				bus;
@property (nonatomic, strong)   NSDate*             chosenDate;
@property (nonatomic)           BOOL                futureTrip;

@end
