//
//  OTrainViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-11.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "OTrainViewController.h"

@interface OTrainViewController()
- (void)resizeTableAndMap;
- (void)swapRoutes:(id)sender;
- (void)setTrainLocation:(id)sender;
- (void)updateStopAnnotations:(id)senders;
- (void)updateTrainAnnotationForPrevTrip:(MTTrip*)prevTrip NextTrip:(MTTrip*)nextTrip;
- (void)getTrainLocation:(id)sender;
- (void)startMonitor:(id)sender;
- (void)stopMonitor:(id)sender;
- (void)trainMonitorTick:(id)sender;
@end

@implementation OTrainViewController
@synthesize tableView           = _tableView;
@synthesize chosenDate          = _chosenDate;
@synthesize futureTrip          = _futureTrip;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _trainAnnotation = [[MTBusAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0)];
        _trainAnnotation.busNumber = @"OTrn";
        _trainLastLocation = -1;
        _chosenDate = [NSDate date];
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
    
    //setup stop
    _stop = [[MTStop alloc] initWithLanguage:_language];
    _stop.StopId = @"RF990"; //Greenborrow
    _stop.StopNumber = 3037;
    _stop.StopName = @"OTRAIN GREENBORO";
    _stop.Latitude = 45.409195;
    _stop.Longitude = -75.721931;
    MTBus* bus = [[MTBus alloc] initWithLanguage:_language];
    bus.BusId = @"750-125";
    bus.BusNumber = @"750";
    bus.DisplayHeading = @"Bayview";
    [_stop.BusIds addObject:bus];
    
    _stop2 = [[MTStop alloc] initWithLanguage:_language];
    _stop2.StopId = @"NA990"; //Bayview
    _stop2.StopNumber = 3060;
    _stop2.StopName = @"BAYVIEW";
    _stop2.Latitude = 45.359711;
    _stop2.Longitude = -75.659401;
    MTBus* bus2 = [[MTBus alloc] initWithLanguage:_language];
    bus2.BusId = @"750-125";
    bus2.BusNumber = @"750";
    bus2.DisplayHeading = @"Greenboro";
    [_stop2.BusIds addObject:bus2];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:self action:@selector(swapRoutes:)];
    
    //view
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    self.title = @"OTrain";
    
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
    
    //mapvoew
    _mapView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self cancelQueues];
    
    _tableView = nil;
    _trips = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    _transpo.delegate = self;
    [self swapRoutes:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopMonitor:nil];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        cell.alertSelected = NO;
        cell.useForTrain = YES;
    }
    
    MTTrip* trip = [_trips objectAtIndex:indexPath.row];
    
    int stopSequence = trip.StopSequence;
    int lastStop = _trips.count;
    
    [cell updateCellBackgroundWithStopSequence:((stopSequence == 1) ? MTTRIPSEQUENCE_FIRST : ((stopSequence >= lastStop) ? MTTRIPSEQUENCE_LAST : MTTRIPSEQUENCE_MIDDLE))];
    
    [cell updateCellDetails:trip];
    
    BOOL busHere = NO;
    if(trip.StopNumber == _trainLastLocation)
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* tableViewHeaderLabel = (UILabel*)[_tableViewHeader viewWithTag:100];
    if(tableViewHeaderLabel)
    {
        if(_trips.count <= 0)
            return _tableViewHeader;
        
        MTTrip* trip = [_trips objectAtIndex:_trips.count - 1];
            
        NSString *headerTime = trip.StopName;
        if(headerTime == nil)
            headerTime = @"";
        tableViewHeaderLabel.text = [NSString stringWithFormat:@"%@: %@", [MTHelper DateDashesYYYYMMDD:_chosenDate], headerTime];
        
        if(_trainAnnotation != nil)
        {
            _trainAnnotation.busHeading = trip.StopName;
        }
    }
    
    return _tableViewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kMTTRIPHEADERHEIGHT;
}

- (void)swapRoutes:(id)sender
{
    if(_swap)
    {
        if(_stop2.Bus.Times.TimesAdded)
        {
            MTTime* time = _stop2.Bus.getCurrentTrip;
            
            [_loadingIndicator startAnimating];
            
            if(![_transpo getTripDetailsFor:time.TripId])
                [self myTranspo:nil State:MTRESULTSTATE_FAILED finishedGettingTrips:nil];
        }
        else
        {
            [_transpo getNewScheduleForStop:_stop2 WithRoute:_stop2.Bus];
        }
        
        _swap = NO;
    }
    else
    {
        if(_stop.Bus.Times.TimesAdded)
        {
            MTTime* time = _stop.Bus.getCurrentTrip;
            
            [_loadingIndicator startAnimating];
            
            if(![_transpo getTripDetailsFor:time.TripId])
                [self myTranspo:nil State:MTRESULTSTATE_FAILED finishedGettingTrips:nil];            
        }
        else
        {
            [_transpo getNewScheduleForStop:_stop WithRoute:_stop.Bus];
        }
        _swap = YES;
    }
}

#pragma mark - MY Transpo

- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingTrips:(NSArray *)trips
{
    [_loadingIndicator stopAnimating];
    

    
    if(state == MTRESULTSTATE_SUCCESS)
    {
        _trips = nil;
        _trips = trips;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        //determine where to scroll too my fav stop
        for(int x=0; x<_trips.count; x++)
        {
            MTTrip* trip = [_trips objectAtIndex:x];
            
            if([trip.StopId isEqualToString:_stop.StopId])
            {
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
        trip.Time.Time = _stop.Bus.NextTime;
        trip.Time.TripId = _trip.TripId;
        trip.Time.StopId = _stop.StopId;
        trip.Time.StopSequence = 0;
        trip.Time.IsLive = NO;
        
        _trips = nil;
        _trips = [NSArray arrayWithObject:trip];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if(_tableView.alpha != 1.0)
        _tableView.alpha = 1.0;
    
    [self setTrainLocation:nil];
    [self updateStopAnnotations:nil];
    [self getTrainLocation:nil];    
    [self startMonitor:nil];
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
            [self stopMonitor:nil];
            return;
        }
        //nextTrip = prevTrip;
        
        if(nextTrip == nil && prevTrip == nil)//uhoh
        {
            [self stopMonitor:nil];
            return;
        }
        
        [self updateTrainAnnotationForPrevTrip:prevTrip NextTrip:nextTrip];
        return;
    }
    
    MTTrip* prevTrip = [times objectAtIndex:0];
    [self updateTrainAnnotationForPrevTrip:prevTrip NextTrip:nil];
}

- (void)myTranspo:(MTResultState)state newScheduleForStop:(MTStop*)stop AndRoute:(MTBus*)bus
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        MTTime* time = bus.getCurrentTrip;
        
        [_loadingIndicator startAnimating];
        
        if(![_transpo getTripDetailsFor:time.TripId])
            [self myTranspo:nil State:MTRESULTSTATE_FAILED finishedGettingTrips:nil];
    }
}

#pragma mark - MAP STUFF

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
            int newHeight = 5*kMTTRIPCELLHEIGHT + kMTTRIPHEADERHEIGHT;
            
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

- (void)setTrainLocation:(id)sender
{
    MTTrip* trip = [_trips objectAtIndex:0];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = CLLocationCoordinate2DMake(trip.Latitude - 0.001, trip.Longitude);
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    [_mapView setRegion:mapRegion animated:YES];
}

#pragma mark - ANNOTATIONS

- (void)updateStopAnnotations:(id)senders
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
        stopAnnotation.stopStreetName = trip.StopName;
        
        [_mapView addAnnotation:stopAnnotation];
    }
}

- (void)updateTrainAnnotationForPrevTrip:(MTTrip*)prevTrip NextTrip:(MTTrip*)nextTrip;
{
#if 0
    for(id<MKAnnotation> annotation in _mapView.annotations)
    {
        if([annotation isKindOfClass:[MTBusAnnotation class]])
            [_mapView removeAnnotation:annotation];
    }
#endif
    
    //can be used to calculate distance and estimate where the bus should be along a path between point A and B???
    //otherwise just show the bus at the previous stop
    if(_trainAnnotation != nil)
        [_mapView removeAnnotation:_trainAnnotation];
    else
    {
        _trainAnnotation = [[MTBusAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(prevTrip.Latitude, prevTrip.Longitude)];
    }    
    
    _trainAnnotation.coordinates = CLLocationCoordinate2DMake(prevTrip.Latitude, prevTrip.Longitude);
    [_mapView addAnnotation:_trainAnnotation];
    
    _trainLastLocation = prevTrip.StopNumber;
    [_tableView reloadData];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = CLLocationCoordinate2DMake(prevTrip.Latitude - 0.001, prevTrip.Longitude);
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    [_mapView setRegion:mapRegion animated:YES];
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
        annotationView.image=[UIImage imageNamed:@"global_train_pin.png"];
        
        return annotationView;
    }
	else if([annotation isKindOfClass:[MTBusAnnotation class]]) 
	{
		static NSString *identifier = @"MTBusAnnotation";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
		if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.pinColor = MKPinAnnotationColorPurple;
        //annotationView.image=[UIImage imageNamed:@""];
        
        return annotationView;
    }
    
    return nil;    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MTLog(@"Show Card manager??"); //i dont think this is a good idea for this screen
}

- (void)getTrainLocation:(id)sender
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
    
    if(![_transpo getLiveNextTripsForTrip:nextTrip WithRoute:(_swap == NO) ? _stop2.Bus : _stop.Bus])
    {
        [self updateTrainAnnotationForPrevTrip:prevTrip NextTrip:nextTrip];
    }
}

#pragma mark - TRAIN MONITOR

- (void)startMonitor:(id)sender
{
    if(_chosenDate != nil)
    {
        if(![MTHelper IsDateToday:_chosenDate])
            return;
    }
    
    if(_trainTimer == nil)
    {
        _trainTimer = [NSTimer scheduledTimerWithTimeInterval:kMTTrainTimerInterval target:self selector:@selector(trainMonitorTick:) userInfo:nil repeats:YES];
    }
    else if([_trainTimer isValid])
    {
        [self stopMonitor:nil];
        _trainTimer = [NSTimer scheduledTimerWithTimeInterval:kMTTrainTimerInterval target:self selector:@selector(trainMonitorTick:) userInfo:nil repeats:YES];
    }
    else if(![_trainTimer isValid])
    {
        _trainTimer = [NSTimer scheduledTimerWithTimeInterval:kMTTrainTimerInterval target:self selector:@selector(trainMonitorTick:) userInfo:nil repeats:YES];
    }
}

- (void)stopMonitor:(id)sender
{
    if(_trainTimer)
    {
        if([_trainTimer isValid])
            [_trainTimer invalidate];
    }
    
    _trainTimer = nil;
}

- (void)trainMonitorTick:(id)sender
{
    NSString* currentTime = [MTHelper CurrentTimeHHMMSS];
    MTTrip* trip = [_trips objectAtIndex:_trips.count - 1];
    if([trip.Time compareTimesHHMMSS:currentTime Ordering:1] < 0) //end of the trip
    {
        _swap = !_swap, [self swapRoutes:nil];
        [self stopMonitor:nil];
        return;
    }
    
    //other wise update the train location
    [self getTrainLocation:nil];
}

#pragma mark - QUEUE SAFE

- (void)cancelQueues
{
    _stop.cancelQueue = YES;
    _stop2.cancelQueue = YES;
    
    [_stop cancelQueuesForBuses];
    [_stop2 cancelQueuesForBuses];
}

@end
