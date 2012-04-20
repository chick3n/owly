//
//  TripViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-27.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//
#import "TripViewController.h"

@interface TripViewController ()
- (void)changeTripScheduleTime:(id)sender;
- (void)cancelTripScheduleTime:(id)sender;
- (void)doneTripScheduleTime:(id)sender;
- (void)updateAnnotations;
- (void)setSelectedRowForPickerView;
- (void)updateBusAnnotationsPrevTrip:(MTTrip*)prevTrip AndNextTrip:(MTTrip*)nextTrip;
- (void)getBusLocation;
- (void)startBusMonitor;
- (void)stopBusMonitor;
- (void)busMonitorTick:(id)sender;
- (void)resizeTableAndMap;
- (void)resetTrip;
- (void)goBack:(id)sender;
@end

@implementation TripViewController
@synthesize tableView				= _tableView;
@synthesize stop					= _stop;
@synthesize bus						= _bus;
@synthesize chosenDate              = _chosenDate;
@synthesize futureTrip              = _futureTrip;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _timesOptions = [NSArray arrayWithObjects:@"Weekday", @"Saturday", @"Sunday", nil];
        //_busTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(getBusLocation) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _trips = nil;
    //_timesDisplayTimes = [_bus getWeekdayTimesForDisplay];
    switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
        case 1: //Sunday
            _timesDisplayTimes = [_bus getSundayTimesForDisplay];
            break;
        case 7:
            _timesDisplayTimes = [_bus getSaturdayTimesForDisplay];
            break;
        default:
            _timesDisplayTimes = [_bus getWeekdayTimesForDisplay];
            break;
    }
    _tripNotifications = [_transpo tripNotifications];
    
    CGRect frame = _timesPickerView.frame;
    frame.origin.y = _timesPickerView.frame.origin.y + _timesPickerView.frame.size.height;
    _timesPickerView.frame = frame;
    
    //view
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]];
	
	//setup tableview
	[self.tableView setDelaysContentTouches:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)]];
    [self.tableView addSubview:_backgroundImage];
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y = _mapView.frame.origin.y + _mapView.frame.size.height;
    self.tableView.frame = tableViewFrame;
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    gesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:gesture];
    
    //setup tableview header
    _tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kMTTRIPHEADERHEIGHT)];
    [_tableViewHeader addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_category_bar.png"]]];
    UILabel *tableViewHeadlerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, 312, 17)];
    tableViewHeadlerLabel.tag = 100;
    tableViewHeadlerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    tableViewHeadlerLabel.textColor = [UIColor whiteColor];
    tableViewHeadlerLabel.backgroundColor = [UIColor clearColor];
    tableViewHeadlerLabel.shadowColor = [UIColor colorWithRed:38./255. green:154./255. blue:201./255. alpha:1.0];
    tableViewHeadlerLabel.shadowOffset = CGSizeMake(0, 1);
    [_tableViewHeader addSubview:tableViewHeadlerLabel];
	
	//setup pickerView
	[_timesPickerView setDelegate:self];
	[_timesPickerView setDataSource:self];
    [self performSelector:@selector(setSelectedRowForPickerView) withObject:nil afterDelay:0.5];
	
	//setup navigation bar
	self.title = [NSString stringWithFormat:@"%@ %@", _bus.BusNumber, _bus.DisplayHeading];
	
    MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];
    [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton* navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setImage:[UIImage imageNamed:@"global_time_btn.png"] forState:UIControlStateNormal];
    [navButton addTarget:self action:@selector(changeTripScheduleTime:) forControlEvents:UIControlEventTouchUpInside];
    [navButton setFrame:CGRectMake(0, 0, 41, 29)];
    _timesChangeButton = [[UIBarButtonItem alloc] initWithCustomView:navButton];
    self.navigationItem.rightBarButtonItem = _timesChangeButton;
    
    MTRightButton* cancelButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [cancelButton setTitle:NSLocalizedString(@"EXTERNALCANCEL", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelTripScheduleTime:) forControlEvents:UIControlEventTouchUpInside];
    _timesCancelButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];    
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneTripScheduleTime:) forControlEvents:UIControlEventTouchUpInside];
    _timesDoneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
	_initialLeftButton = self.navigationItem.leftBarButtonItem;
    
    //mapview
    _mapView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self stopBusMonitor];
    [self cancelQueues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _transpo.delegate = self;
    
    [self resetTrip];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[_loadingIndicator stopAnimating];
    
    _timesPickerView.hidden = YES;
    
    [self stopBusMonitor];
    [self cancelQueues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

- (void)resetTrip
{
    _trip = _bus.getCurrentTrip;
    _busTripLocation = 0;
    
    [_loadingIndicator startAnimating];
    
    if(![_transpo getTripDetailsFor:_trip.TripId])
        [self myTranspo:nil State:MTRESULTSTATE_FAILED finishedGettingTrips:nil];
    
    _timesPickerView.hidden = YES;
    [self stopBusMonitor];
}

#pragma mark - UIPickerView Delegate / Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component;
{
	if(component == 0) //day choices
	{
		if(_timesOptions != nil)
			return _timesOptions.count;
	}
	else if(component == 1) //display times
	{
		if(_timesDisplayTimes != nil)
			return _timesDisplayTimes.count;
	}
    
	return 0;
}

- (void)pickerView:(UIPickerView *)pickerView 
	  didSelectRow:(NSInteger)row 
	   inComponent:(NSInteger)component
{
    if(component == 0)//change date
	{
		switch(row)
		{
			case 1: //saturday
				_timesDisplayTimes = [_bus getSaturdayTimesForDisplay];
				break;
			case 2: //sunday
				_timesDisplayTimes = [_bus getSundayTimesForDisplay];
				break;
			default:
				_timesDisplayTimes = [_bus getWeekdayTimesForDisplay];
				break;
		}
		
        [_timesPickerView selectRow:0 inComponent:1 animated:NO];
		[_timesPickerView reloadComponent:1];
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView 
			 titleForRow:(NSInteger)row 
			forComponent:(NSInteger)component;
{
    if(component == 0)
        return [_timesOptions objectAtIndex:row];
    
    return [_timesDisplayTimes objectAtIndex:row];
}

- (void)setSelectedRowForPickerView
{
    if(_pickerViewSelectedRow >= 0)
    {
        switch ([MTHelper DayOfWeekForDate:_chosenDate]) {
            case 1://sunday
                [_timesPickerView selectRow:2 inComponent:0 animated:NO];
                break;
            case 7:
                [_timesPickerView selectRow:1 inComponent:0 animated:NO];
                break;
            default:
                [_timesPickerView selectRow:0 inComponent:0 animated:NO];
                break;
        }
        
        for(int x= 0; x<_timesDisplayTimes.count; x++)
        {
            NSString *time = [_timesDisplayTimes objectAtIndex:x];
            if([time isEqualToString:[_trip getTimeForDisplay]])
                _pickerViewSelectedRow = x;
        }
        
        [_timesPickerView selectRow:_pickerViewSelectedRow inComponent:1 animated:NO];
    }
    
    _pickerViewSelectedRow = -1; //never do this again, as we have run it now once
}

#pragma mark - UIPickerView Helpers

- (void)changeTripScheduleTime:(id)sender
{
    //slide frame up
    CGRect frame = _timesPickerView.frame;
    frame.origin.y = frame.origin.y - frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        _timesPickerView.frame = frame;
    }];
    
    _timesPickerView.hidden = NO;
	_tempTimesChanged = _timesDisplayTimes;
	[self.navigationItem setRightBarButtonItem:_timesDoneButton];
	[self.navigationItem setLeftBarButtonItem:_timesCancelButton];
}

- (void)cancelTripScheduleTime:(id)sender
{
    //slide frame down
    CGRect frame = _timesPickerView.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        _timesPickerView.frame = frame;
    }];
    
	if(_tempTimesChanged != _timesDisplayTimes)
	{
		_timesDisplayTimes = _tempTimesChanged;
		[_timesPickerView reloadComponent:1];
	}
    
	[self.navigationItem setRightBarButtonItem:_timesChangeButton];
	[self.navigationItem setLeftBarButtonItem:_initialLeftButton];
}

- (void)doneTripScheduleTime:(id)sender
{
    //slide frame down
    CGRect frame = _timesPickerView.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        _timesPickerView.frame = frame;
    }];
    
	//get new trip data based on new selected time
    MTTime* tripTime = nil;
    switch ([_timesPickerView selectedRowInComponent:0]) {
        case 0: //weekday
            tripTime = (MTTime*)[_bus.Times.Times objectAtIndex:[_timesPickerView selectedRowInComponent:1]];
            break;
        case 1: //saturday
            tripTime = (MTTime*)[_bus.Times.TimesSat objectAtIndex:[_timesPickerView selectedRowInComponent:1]];
            break;
        case 2:
            tripTime = (MTTime*)[_bus.Times.TimesSun objectAtIndex:[_timesPickerView selectedRowInComponent:1]];
            break;
    }
    
    if(tripTime != nil)
    {
        NSString *newTripId = tripTime.TripId;
        if(![_trip.TripId isEqualToString:newTripId])
        {
            _trip = tripTime;
            
            [_loadingIndicator startAnimating];
            [_tableView setAlpha:0.6];
            
            [self stopBusMonitor];
            
            [_transpo getTripDetailsFor:_trip.TripId];
            
            [self stopBusMonitor];
        }
    }
    
	[self.navigationItem setRightBarButtonItem:_timesChangeButton];
	[self.navigationItem setLeftBarButtonItem:_initialLeftButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_trips == nil) ? 0 : _trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    MTTripCell *cell = (MTTripCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[MTTripCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier WithLanguage:_language];
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTTripCell" owner:self options:nil];
        cell = [mtCardCellXib objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.language = _language;
        cell.delegate = self;
        cell.alertSelected = NO;
    }
    
    MTTrip* trip = [_trips objectAtIndex:indexPath.row];
    
    int stopSequence = trip.StopSequence;
    int lastStop = _trips.count;
    
    [cell updateCellBackgroundWithStopSequence:((stopSequence == 1) ? MTTRIPSEQUENCE_FIRST : ((stopSequence >= lastStop) ? MTTRIPSEQUENCE_LAST : MTTRIPSEQUENCE_MIDDLE))];
    
    [cell updateCellDetails:trip];
    
    BOOL busHere = NO;
    if(trip.StopNumber == _busTripLocation)
        busHere = YES;
    
    [cell updateBusImage:!busHere];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMTTRIPCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTTrip* trip = [_trips objectAtIndex:indexPath.row];
    
    MKCoordinateRegion mapRegion;
    if(trip.StopNumber == _busTripLocation) //zoom map to
    {
        mapRegion.center = CLLocationCoordinate2DMake(_busAnnotation.coordinates.latitude - 0.002, _busAnnotation.coordinates.longitude);
    }
    else
    {
        mapRegion.center = CLLocationCoordinate2DMake(trip.Latitude - 0.002, trip.Longitude);
    }
    
    mapRegion.span.latitudeDelta = 0.004;
    mapRegion.span.longitudeDelta = 0.004;
    
    [_mapView setRegion:mapRegion animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* tableViewHeaderLabel = (UILabel*)[_tableViewHeader viewWithTag:100];
    if(tableViewHeaderLabel)
    {
        NSString *headerTime = [_trip getTimeForDisplay];
        if(headerTime == nil)
            headerTime = @"";
        tableViewHeaderLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"MTDEF_SCHEDULEDTIME", nil), headerTime];
    }
    
    return _tableViewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kMTTRIPHEADERHEIGHT;
}

#pragma mark - TRIP CELL DELEGATE

- (void)mtTripCell:(id)tripCell AlertAddedForTrip:(MTTrip *)trip
{
    if([_transpo addTripNotificationForTrip:trip DayOfWeek:[_timesPickerView selectedRowInComponent:0] ForStop:_stop AndRoute:_stop.Bus AtStartDate:_chosenDate])
    {
        ((MTTripCell*)tripCell).alertSelected = YES;
        _tripNotifications = nil;
        _tripNotifications = [_transpo tripNotifications];
    }
}

- (void)mtTripCell:(id)tripCell AlertRemovedForTrip:(MTTrip *)trip
{
    if([_transpo removeTripNotificationForTrip:trip ForStop:_stop AndRoute:_stop.Bus])
    {
        ((MTTripCell*)tripCell).alertSelected = NO;
        _tripNotifications = nil;
        _tripNotifications = [_transpo tripNotifications];
    }
}


#pragma mark - QUEUE SAFE

- (void)cancelQueues
{
    if(_trips == nil)
        return;
    
    _stop.cancelQueue = YES;
    [_stop cancelQueuesForBuses];
}

#pragma mark - MY Transpo

- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingTrips:(NSArray *)trips
{
    [_loadingIndicator stopAnimating];
    
    if(state == MTRESULTSTATE_SUCCESS)
    {
        _trips = nil;
        _trips = trips;
        [_tableView reloadData];
        
        //determine where to scroll too my fav stop
        for(int x=0; x<_trips.count; x++)
        {
            MTTrip* trip = [_trips objectAtIndex:x];
            
            if([trip.StopId isEqualToString:_stop.StopId])
            {
                _currentTrip = trip;
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
                break;
            }
        }
    }
    else
    {
        MTLog(@"Failed finished Getting Trips, setting stop as trip");
        MTTrip* trip = [[MTTrip alloc] initWithLanguage:_language];
        trip.StopId = _stop.StopId;
        trip.StopNumber = _stop.StopNumber;
        trip.Longitude = _stop.Longitude;
        trip.Latitude = _stop.Latitude;
        trip.StopName = _stop.StopName;
        trip.Language = _language;
        trip.TripId = _trip.TripId;
        trip.StopSequence = 0;
        trip.Time.Time = _bus.NextTime;
        trip.Time.TripId = _trip.TripId;
        trip.Time.StopId = _stop.StopId;
        trip.Time.StopSequence = 0;
        trip.Time.IsLive = NO;
        
        _trips = nil;
        _trips = [NSArray arrayWithObject:trip];
        _currentTrip = trip;
        [_tableView reloadData];
    }
    
    if(_tableView.alpha != 1.0)
        _tableView.alpha = 1.0;
    
    [self updateAnnotations];
    
    [self getBusLocation];    
    [self startBusMonitor];
    [self performSelector:@selector(resizeTableAndMap) withObject:nil afterDelay:1.0];
    
    //[self resizeTableAndMap];
}

- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingNextLiveTimes:(NSArray*)times
{
    if(state == MTRESULTSTATE_FAILED) //get schedule time to determine where bus should be beacuse API failed
    {
        NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
        MTTrip *nextTrip = nil;
        MTTrip *prevTrip = nil;
        
        for(MTTrip *trip in _trips)
        {
            if([trip.Time compareTimesHHMMSS:currentTime Ordering:1] > 0)
            {
                nextTrip = trip;
                break;
            }
            prevTrip = trip;
        }
        
        if(prevTrip == nil) //first Trip
            prevTrip = nextTrip;
        
        if(nextTrip == nil) //last Trip shouldnt be on map anymore?
        {
            [self stopBusMonitor];
            return;
        }
        //nextTrip = prevTrip;
        
        if(nextTrip == nil && prevTrip == nil)//uhoh
        {
            [self stopBusMonitor];
            return;
        }
        
        [self updateBusAnnotationsPrevTrip:prevTrip AndNextTrip:nextTrip];
        return;
    }
    
    MTTrip* prevTrip = [times objectAtIndex:0];
    
    if(prevTrip.StopNumber <= 0)
    {
        //determine where it should go based on time get all lat/lon of each stop and get the closest one tot he lat/lon of the trip
        MTTrip* closest = [_transpo getClosestTrip:_trips ToLat:prevTrip.Latitude Lon:prevTrip.Longitude];
        prevTrip.StopId = closest.StopId;
        prevTrip.StopName = closest.StopName;
        prevTrip.StopNumber = closest.StopNumber;
    }
    
    [self updateBusAnnotationsPrevTrip:prevTrip AndNextTrip:nil];
}

#pragma mark - MTTrip Cell Stuff

- (void)didSwipe:(UIGestureRecognizer*)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath* swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        if(swipedIndexPath != nil)
        {
            MTTripCell* cell = (MTTripCell*)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
            if(cell)
            {
                //UIView* detailsView = [cell viewWithTag:kMTTRIPDETAILSVIEWTAG];
                if(cell.trip == nil)
                    return;
                
                if(cell.trip.TripId == nil)
                    return;
                
                //determine if we have this already set
                BOOL status = NO;
                for(UILocalNotification* notification in _tripNotifications)
                {
                    if([_transpo tripNotificationMatchTrip:cell.trip ForStop:_stop AndRoute:_stop.Bus AgainstUserInfo:notification.userInfo])
                    {
                        status = YES;
                        break;
                    }
                }
                
                cell.alertSelected = status;
                [cell toggleDisplayViews];
            }
        }
    }
}

- (void)updateAnnotations
{
    for(id<MKAnnotation> annotation in _mapView.annotations)
    {
        if([annotation isKindOfClass:[MTStopAnnotation class]])
            [_mapView removeAnnotation:annotation];
    }
    
    for(MTTrip* trip in _trips)
    {
        MTStopAnnotation* stopAnnotation = [[MTStopAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(trip.Latitude, trip.Longitude)];
        stopAnnotation.stopCode = [NSString stringWithFormat:@"%d", trip.StopNumber];
        stopAnnotation.stopStreetName = trip.StopNameDisplay;
        
        [_mapView addAnnotation:stopAnnotation];
    }
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = CLLocationCoordinate2DMake(_stop.Latitude - 0.002, _stop.Longitude);
    mapRegion.span.latitudeDelta = 0.004;
    mapRegion.span.longitudeDelta = 0.004;

    [_mapView setRegion:mapRegion animated:YES];
    
}

- (void)updateBusAnnotationsPrevTrip:(MTTrip *)prevTrip AndNextTrip:(MTTrip *)nextTrip
{
    //can be used to calculate distance and estimate where the bus should be along a path between point A and B???
    //otherwise just show the bus at the previous stop
    if(_busAnnotation != nil)
        [_mapView removeAnnotation:_busAnnotation];
    else
    {
        _busAnnotation = [[MTBusAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(prevTrip.Latitude, prevTrip.Longitude)];
    }    
    
    _busAnnotation.coordinates = CLLocationCoordinate2DMake(prevTrip.Latitude, prevTrip.Longitude);
    _busAnnotation.busNumber = _bus.BusNumber;
    _busAnnotation.busHeading = _bus.DisplayHeading;
    [_mapView addAnnotation:_busAnnotation];
    
    _busTripLocation = prevTrip.StopNumber;
    NSLog(@"Update bus annotations stop: %d", prevTrip.StopNumber);
    [_tableView reloadData];
}

- (void)getBusLocation
{
    _bus.cancelQueue = NO;
    _currentTrip.cancelQueue = NO;
    if(![_transpo getLiveNextTripsForTrip:_currentTrip WithRoute:_bus])
    {
        //For this we will have to determine the next stop in the sequence based on time, from there send that stop data and get where the bus
        //currently is
        NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
        MTTrip *nextTrip = nil;
        MTTrip *prevTrip = nil;
        
        for(MTTrip *trip in _trips)
        {
            if([trip.Time compareTimesHHMMSS:currentTime Ordering:1] > 0)
            {
                nextTrip = trip;
                break;
            }
            prevTrip = trip;
        }
        
        if(prevTrip == nil) //first Trip
            prevTrip = nextTrip;
        
        if(nextTrip == nil) //last Trip shouldnt be on map anymore?
            return;
        //nextTrip = prevTrip;
        
        if(nextTrip == nil && prevTrip == nil)//uhoh
            return;
        
        [self updateBusAnnotationsPrevTrip:prevTrip AndNextTrip:nextTrip];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
    if ([annotation isKindOfClass:[MTStopAnnotation class]]) 
	{
		static NSString *identifier = @"MTStopAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
		if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image=[UIImage imageNamed:@"global_bus_pin.png"];
        
        return annotationView;
    }
	else if([annotation isKindOfClass:[MTBusAnnotation class]]) 
	{
		static NSString *identifier = @"MTBusAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
		if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image=[UIImage imageNamed:@"bus_location_pin.png"];
        
        return annotationView;
    }
    
    return nil;    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MTLog(@"Show Card manager??"); //i dont think this is a good idea for this screen
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views 
{
    for (MKAnnotationView * annView in views) 
    {
        if([annView.annotation class] == [MTStopAnnotation class])
        {
            [[annView superview] sendSubviewToBack:annView];
        }
    }
}

- (void)startBusMonitor
{
    if(_chosenDate != nil)
    {
        if(![MTHelper IsDateToday:_chosenDate])
            return;
    }
    
    if(_busTimer == nil)
    {
        _busTimer = [NSTimer scheduledTimerWithTimeInterval:kMTBusTimerInterval target:self selector:@selector(busMonitorTick:) userInfo:nil repeats:YES];
    }
    else if([_busTimer isValid])
    {
        [self stopBusMonitor];
        _busTimer = [NSTimer scheduledTimerWithTimeInterval:kMTBusTimerInterval target:self selector:@selector(busMonitorTick:) userInfo:nil repeats:YES];
    }
    else if(![_busTimer isValid])
    {
        _busTimer = [NSTimer scheduledTimerWithTimeInterval:kMTBusTimerInterval target:self selector:@selector(busMonitorTick:) userInfo:nil repeats:YES];
    }
}

- (void)stopBusMonitor
{
    if(_busTimer)
    {
        if([_busTimer isValid])
            [_busTimer invalidate];
    }
    
    _busTimer = nil;
}

- (void)busMonitorTick:(id)sender
{
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    if([_trip compareTimesHHMMSS:currentTime Ordering:1] < 0)
    {
        [self resetTrip];
        [self stopBusMonitor];
        return;
    }
    
    [self getBusLocation];
}

- (void)resizeTableAndMap
{
    CGRect newTableFrame = CGRectZero;
    CGRect newMapFrame = CGRectZero;
    
    if(_trips == nil)
    {
        newMapFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        newTableFrame = CGRectMake(0, self.view.frame.size.height, 320, 0);
    }
    else
    {
        int totalTrips = _trips.count;
        if(totalTrips < 3)
        {
            int newHeight = 3*kMTTRIPCELLHEIGHT + kMTTRIPHEADERHEIGHT;
            newTableFrame = CGRectMake(0, self.view.frame.size.height - newHeight, 320, newHeight);
            newMapFrame = CGRectMake(0, 0, 320, self.view.frame.size.height - newHeight);
        }
        else
        {
            int newHeight = 6*kMTTRIPCELLHEIGHT + kMTTRIPHEADERHEIGHT;
            
            newTableFrame = CGRectMake(0, self.view.frame.size.height - newHeight, 320, newHeight);
            newMapFrame = CGRectMake(0, 0, 320, self.view.frame.size.height - newHeight);
        }
    }
    
    //attach scrolling background
    CGRect backgroundImageFrame = _backgroundImage.frame;
    backgroundImageFrame.origin.y = _tableView.contentSize.height;
    _backgroundImage.frame = backgroundImageFrame;    
    
    [UIView animateWithDuration:0.5 animations:^(void){
       // _mapView.frame = newMapFrame;
        _tableView.frame = newTableFrame; 
    }];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"%f", scrollView.contentOffset.y);
}

#pragma mark - Navigation UI

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
