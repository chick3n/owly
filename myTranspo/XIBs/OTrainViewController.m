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
@end

@implementation OTrainViewController
@synthesize tableView           = _tableView;
@synthesize chosenDate          = _chosenDate;
@synthesize futureTrip          = _futureTrip;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    _stop.Latitude = 45.409195;
    _stop.Longitude = -75.721931;
    MTBus* bus = [[MTBus alloc] initWithLanguage:_language];
    bus.BusId = @"750-125";
    bus.BusNumber = @"OTrain";
    [_stop.BusIds addObject:bus];
    
    _stop2 = [[MTStop alloc] initWithLanguage:_language];
    _stop2.StopId = @"NA990"; //Bayview
    _stop2.StopNumber = 3060;
    _stop2.Latitude = 45.359711;
    _stop2.Longitude = -75.659401;
    MTBus* bus2 = [[MTBus alloc] initWithLanguage:_language];
    bus2.BusId = @"750-125";
    bus2.BusNumber = @"OTrain";
    [_stop2.BusIds addObject:bus2];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:self action:@selector(swapRoutes:)];
    
    //view
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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
        cell.delegate = self;
        cell.alertSelected = NO;
    }
    
    MTTrip* trip = [_trips objectAtIndex:indexPath.row];
    
    int stopSequence = trip.StopSequence;
    int lastStop = _trips.count;
    
    [cell updateCellBackgroundWithStopSequence:((stopSequence == 1) ? MTTRIPSEQUENCE_FIRST : ((stopSequence >= lastStop) ? MTTRIPSEQUENCE_LAST : MTTRIPSEQUENCE_MIDDLE))];
    
    [cell updateCellDetails:trip];
    
    BOOL busHere = NO;
    
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
        MTTrip* trip = [_trips objectAtIndex:_trips.count - 1];
            
        NSString *headerTime = trip.StopName;
        if(headerTime == nil)
            headerTime = @"";
        tableViewHeaderLabel.text = headerTime;
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
        [_tableView reloadData];
        
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
        [_tableView reloadData];
    }
    
    if(_tableView.alpha != 1.0)
        _tableView.alpha = 1.0;
    
    [self setTrainLocation:nil];
    [self performSelector:@selector(resizeTableAndMap) withObject:nil afterDelay:1.0];
    
    //[self resizeTableAndMap];
}

- (void)myTranspo:(id)transpo State:(MTResultState)state finishedGettingNextLiveTimes:(NSArray*)times
{
    
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
}

@end
