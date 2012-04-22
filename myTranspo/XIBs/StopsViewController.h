//
//  StopsViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MTBaseViewController.h"
#import "myTranspoOC.h"
#import "MTIncludes.h"
#import "MTBusAnnotation.h"
#import "MTStopAnnotation.h"
#import "MTSearchBar.h"
#import "MTCardManager.h"
#import "MTSearchCell.h"
#import "CustomCallout.h"
#import "MTRightButton.h"
//#import "MTOptionsDate.h"

@interface StopsViewController : MTBaseViewController <MyTranspoDelegate, MTQueueSafe, MyTranspoDelegate, MKMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, MTCardManagerDelegate>//, MTOptionsDateProtocol>
{
    NSArray*                                _searchResults;
    BOOL                                    _isSearchInProgress;
    NSTimer*                                _searchRefresh;
    BOOL                                    _mapAutomaticAnimation;
    CLLocationCoordinate2D                  _mapLastSearchedCoordinate;
    NSDate*                                 _chosenDate;
    
    //ui components
    IBOutlet MTSearchBar*                   _searchBar;
    IBOutlet MKMapView*                     _mapView;
    MTCardManager*                          _cardManager;
    UIBarButtonItem*                        _cardManagerFavorite;
    UIBarButtonItem*                        _cardManagerFavoriteAlready;
    UIBarButtonItem*                        _cardManagerClose;
    UIBarButtonItem*                        _leftBarButton;
    UIBarButtonItem*                        _resetMapLocationButton;
    IBOutlet UIDatePicker*                  _dateSelector;
}

@end
