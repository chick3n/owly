//
//  OTrainViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-11.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"
#import <MapKit/MapKit.h>
#import "MTBaseViewController.h"
#import "MTIncludes.h"
#import "MTTripCell.h"
#import "MTTrip.h"
#import "MTTime.h"
#import "MTBusAnnotation.h"
#import "MTStopAnnotation.h"

@interface OTrainViewController : MTBaseViewController<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MTQueueSafe, MyTranspoDelegate, MTTripCellDelegate, MKMapViewDelegate>
{
    NSArray*                _trips;
    MTTrip*                 _trip;
    MTStop*                 _stop;
    MTStop*                 _stop2;
    BOOL                    _swap;
    
    //ui components
    UIView*                             _tableViewHeader;
    IBOutlet UIActivityIndicatorView*   _loadingIndicator;
    IBOutlet MKMapView*					_mapView;
    UIImageView*                        _backgroundImage;
}

@property (nonatomic, weak)	IBOutlet UITableView*		tableView;
@property (nonatomic, strong)   NSDate*             chosenDate;
@property (nonatomic)           BOOL                futureTrip;

@end
