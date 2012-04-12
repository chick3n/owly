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

#define kMTBusTimerInterval 60

@interface TripViewController : MTBaseViewController 
<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MTQueueSafe, MyTranspoDelegate, MTTripCellDelegate, MKMapViewDelegate>
{
    NSArray*							_trips;
	NSArray*							_timesDisplayTimes;
	NSArray*							_timesOptions;
	NSArray*							_tempTimesChanged;
    MTTime*                             _trip;
    NSInteger                           _pickerViewSelectedRow; //only used for the initial setting of picker view.
    NSTimer*                            _busTimer;
    MTBusAnnotation*                    _busAnnotation;
    int                                 _busTripLocation;
    NSArray*                            _tripNotifications;
    
	//ui components
	IBOutlet UITableView*				_tableView;
	IBOutlet UIActivityIndicatorView*   _loadingIndicator;
	IBOutlet MKMapView*					_mapView;
	IBOutlet UIPickerView*				_timesPickerView;
	UIBarButtonItem*					_timesChangeButton;
	UIBarButtonItem*					_timesDoneButton;
	UIBarButtonItem*					_timesCancelButton;
	UIBarButtonItem*					_initialLeftButton;
    UIView*                             _tableViewHeader;
    UIImageView*                        _backgroundImage;
}


@property (nonatomic, strong)	UITableView*		tableView;
@property (nonatomic, weak)		MTStop*				stop;
@property (nonatomic, weak)		MTBus*				bus;
@property (nonatomic, strong)   NSDate*             chosenDate;
@property (nonatomic)           BOOL                futureTrip;

@end
