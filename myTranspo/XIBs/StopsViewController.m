//
//  StopsViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "StopsViewController.h"

@interface StopsViewController ()
- (void)refreshStopSearch:(id)sender;
- (void)updateMapAnnotations:(NSArray*)annotations animated:(BOOL)animated;
- (void)updateCloseStops:(id)sender;
- (void)displayCardManager:(id)sender;
- (void)hideCardManager:(id)sender;
- (void)addFavoriteClicked:(id)sender;
- (void)removeFavoriteClicked:(id)sender;
- (void)moveMapBackToLocation:(id)sender;
@end

@implementation StopsViewController

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
    
    //mapview
    _mapView.delegate = self;
    
    //navigationBar
    self.title = NSLocalizedString(@"MTDEF_STOPS", nil);
    UIButton* navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setImage:[UIImage imageNamed:@"global_heart_btn.png"] forState:UIControlStateNormal];
    [navButton addTarget:self action:@selector(addFavoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [navButton setFrame:CGRectMake(0, 0, 40, 29)];
    _cardManagerFavorite = [[UIBarButtonItem alloc] initWithCustomView:navButton];    
    UIButton* navButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton2 setImage:[UIImage imageNamed:@"global_heartselected_btn.png"] forState:UIControlStateNormal];
    [navButton2 addTarget:self action:@selector(removeFavoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [navButton2 setFrame:CGRectMake(0, 0, 40, 29)];
    _cardManagerFavoriteAlready = [[UIBarButtonItem alloc] initWithCustomView:navButton2]; 
    _resetMapLocationButton = [[UIBarButtonItem alloc] initWithTitle:@"ME" style:UIBarButtonItemStylePlain target:self action:@selector(moveMapBackToLocation:)];
    [self.navigationItem setRightBarButtonItem:_resetMapLocationButton];
    
    //view
    [self.view addGestureRecognizer:_panGesture];
    
    //searchcontroller
    [_searchBar setPlaceholder:NSLocalizedString(@"MTDEF_SEARCHPLANCEHOLDER", nil)];
    [_searchBar setSelectedScopeButtonIndex:0];
    [_searchBar sizeToFit];
    //[self.searchDisplayController.searchResultsTableView addSubview:_searchLoading];
    
    //date stuff
    _chosenDate = [NSDate date];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if(_searchRefresh != nil)
    {
        [_searchRefresh invalidate];
        _searchRefresh = nil;
    }
    [_searchBar stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _transpo.delegate = self;
    
    if(_mapView.annotations.count <= 0)
    {
        [self updateCloseStops:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_searchRefresh != nil)
    {
        [_searchRefresh invalidate];
        _searchRefresh = nil;
    }
    
    [_searchBar stopAnimating];
    [self cancelQueues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - QUEUE SAFE

- (void)cancelQueues
{
    
}

#pragma mark - SEARCH DISPLAY DELEGATE

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _searchResults = nil;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if(_searchRefresh != nil && [_searchRefresh isValid])
    {
        [_searchRefresh invalidate];
        _searchRefresh = nil;
    }
    
    [_searchBar stopAnimating];
    
    if(controller.searchBar.text.length == 0)
    {
        [_mapView removeAnnotations:_mapView.annotations];
        [self mapView:_mapView regionDidChangeAnimated:YES]; //update to near by stops as we arent search anything anymore?
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if(searchBar.text.length == 0) //should always return true on cancel?
    {
        [_mapView removeAnnotations:_mapView.annotations];
        [self mapView:_mapView regionDidChangeAnimated:YES]; //update to near by stops as we arent search anything anymore?
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(!_isSearchInProgress) //set timer to call on it 1 second after
    {
        [_transpo getStopsForQuery:searchString AtPage:0];
        _isSearchInProgress = YES;
        
        if(_searchRefresh != nil && [_searchRefresh isValid])
        {
            [_searchRefresh invalidate];
            _searchRefresh = nil;
        }
    }
    else
    {
        if(_searchRefresh != nil && [_searchRefresh isValid])
        {
            [_searchRefresh invalidate];
            _searchRefresh = nil;
        }
        
        _searchRefresh = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshStopSearch:) userInfo:nil repeats:NO];
    }
    
    //[_searchBar sizeToFit];
    [_searchBar startAnimating];
    
    return NO;
}

#pragma mark - Search Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_searchResults == nil)
        return 0;
    
    return _searchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_searchResults == nil)
        return 0;
    
    NSArray* sectionResults = [_searchResults objectAtIndex:section];
    
    if(section == 0 && (_searchBar.selectedScopeButtonIndex == 0 || _searchBar.selectedScopeButtonIndex == 1))
        return sectionResults.count;
    else if(section == 1 && (_searchBar.selectedScopeButtonIndex == 0 || _searchBar.selectedScopeButtonIndex == 2))
        return sectionResults.count;
    else if(section == 2 && (_searchBar.selectedScopeButtonIndex == 0 || _searchBar.selectedScopeButtonIndex == 3))
        return sectionResults.count;
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
   
    if(_searchResults == nil)
        return cell;
    
    NSArray* sectionResults = [_searchResults objectAtIndex:indexPath.section];
    
    if(indexPath.section == 0) //buses
    {
        MTBus *bus = [sectionResults objectAtIndex:indexPath.row];
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", bus.BusNumber, bus.DisplayHeading];
        cell.title = bus.BusNumber;
        cell.subtitle = bus.DisplayHeading;
        cell.type = CELLBUS;
    }
    else if(indexPath.section == 1 || indexPath.section == 2) //stops & streets
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        
        cell.title = [NSString stringWithFormat:@"%d", stop.StopNumber];
        cell.subtitle = stop.StopName;
        
        if(indexPath.section == 2)
            cell.type = CELLSTREET;
        else cell.type = CELLSTOP;
    }
    
    [cell update];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray* sectionResults = [_searchResults objectAtIndex:section];
    if(sectionResults.count <= 0)
       return 0;
       
    if(_searchBar.selectedScopeButtonIndex > 0)
        return 0;
    
    return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerLabel = @"";
    
    switch (section) {
        case 0:
            headerLabel = NSLocalizedString(@"MTDEF_BUS", nil);
            break;            
        case 1:
            headerLabel = NSLocalizedString(@"MTDEF_STOPS", nil);
            break;
        case 2:
            headerLabel = NSLocalizedString(@"MTDEF_STREET", nil);
            break;
    }
    
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)];
    [header addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_category_bar.png"]]];
    UILabel *tableViewHeadlerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, 312, 17)];
    tableViewHeadlerLabel.tag = 100;
    tableViewHeadlerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    tableViewHeadlerLabel.textColor = [UIColor whiteColor];
    tableViewHeadlerLabel.backgroundColor = [UIColor clearColor];
    tableViewHeadlerLabel.shadowColor = [UIColor colorWithRed:38./255. green:154./255. blue:201./255. alpha:1.0];
    tableViewHeadlerLabel.shadowOffset = CGSizeMake(0, 1);
    tableViewHeadlerLabel.text = headerLabel;
    
    [header addSubview:tableViewHeadlerLabel];
    
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* searchBarText = nil;
    
    NSArray *sectionResults = [_searchResults objectAtIndex:indexPath.section];
    if(indexPath.section == 0) //bus
    {
        MTBus * bus = (MTBus*)[sectionResults objectAtIndex:indexPath.row];
        [_transpo getStopsForRoute:bus ByDistanceLat:_transpo.coordinates.latitude Lon:_transpo.coordinates.longitude];
        searchBarText = bus.BusNumber;
    }
    else if(indexPath.section == 1 || indexPath.section == 2)
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        [_transpo getRoutesForStop:stop];
        searchBarText = [NSString stringWithFormat:@"%d", stop.StopNumber];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    if(searchBarText != nil)
        _searchBar.text = searchBarText;
}

#pragma mark - MY TRANSPO DELEGATE

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedSearchResults:(NSArray *)results ForType:(NSInteger)type
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        _searchResults = nil; //make sure to free up retained results
        _searchResults = results;
    }
    
    _isSearchInProgress = NO;
    
    [_searchBar stopAnimating];
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedStopsForRoute:(MTBus*)results
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [self updateMapAnnotations:results.StopIds animated:YES];
    }
    else
    {
        MTLog(@"Failed receivedStopsForRutes");
    }
}

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedStops:(NSArray*)results
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [self updateMapAnnotations:results animated:YES];
    }
    else
    {
        MTLog(@"Failed receivedStops");
    }
}

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedMoreStops:(NSArray*)results
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [self updateMapAnnotations:results animated:NO];
    }
    else
    {
        MTLog(@"Failed receivedStops");
    }
}

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedRoutesForStop:(MTStop *)results
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [self updateMapAnnotations:[NSArray arrayWithObject:results] animated:YES];
    }
    else
    {
        MTLog(@"Failed receivedRoutesForStop");
    }
}

- (void)myTranspo:(MTResultState)state newScheduleForStop:(MTStop *)stop AndRoute:(MTBus *)bus
{
    [_cardManager updateDetailsForStop:stop WithRoute:bus];
}

- (void)myTranspo:(MTResultState)state addedFavorite:(MTStop *)favorite AndBus:(MTBus*)bus
{
    MTBus *busT = [_cardManager getCurrentBus];
        
    if(bus == busT)
    {
        if(bus.isFavorite)
        {
            self.navigationItem.rightBarButtonItem = _cardManagerFavoriteAlready;
        }
        else if(!bus.isFavorite)
        {
            self.navigationItem.rightBarButtonItem = _cardManagerFavorite;
        }
    }
}

- (void)myTranspo:(MTResultState)state removedFavorite:(MTStop *)favorite WithBus:(MTBus *)bus
{
    MTBus *busT = [_cardManager getCurrentBus];
    
    if(bus == busT)
    {
        if(bus.isFavorite)
        {
            self.navigationItem.rightBarButtonItem = _cardManagerFavoriteAlready;
        }
        else if(!bus.isFavorite)
        {
            self.navigationItem.rightBarButtonItem = _cardManagerFavorite;
        }
    }
}

#pragma mark - Timer Search Refresh

- (void)refreshStopSearch:(id)sender
{
    if(self.searchDisplayController.searchBar.text.length <= 0)
        return;
    
    [_transpo getStopsForQuery:self.searchDisplayController.searchBar.text AtPage:0];
    
    [_searchRefresh invalidate];
}

#pragma mark - MAPView Stuff

- (void)updateMapAnnotations:(NSArray*)annotations animated:(BOOL)animated
{
    if(animated)
        [_mapView removeAnnotations:[_mapView annotations]];
    
    if(annotations == nil)
        return;
    
    if(annotations.count == 0)
        return;
    
    MTStop* closestStop = [annotations objectAtIndex:0];
    
    for(MTStop* stop in annotations)
    {
        BOOL exists = NO;
        for(MTStopAnnotation *a in _mapView.annotations)
        {
            if(a.coordinate.latitude == stop.Latitude && a.coordinate.longitude == stop.Longitude)
            {
                exists = YES;
                break;
            }
        }
        
        if(exists)
            break;
        
        MTStopAnnotation* stopAnnotation = [[MTStopAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(stop.Latitude, stop.Longitude)];
        stopAnnotation.stopCode = [NSString stringWithFormat:@"%d", stop.StopNumber];
        stopAnnotation.stopStreetName = stop.StopName;
        stopAnnotation.stop = stop;
        stopAnnotation.stopRoutes = stop.BusIds;
        
        [_mapView addAnnotation:stopAnnotation];
    }
    
    if(animated)
    {
        MKCoordinateRegion mapRegion;
        mapRegion.center = CLLocationCoordinate2DMake(closestStop.Latitude, closestStop.Longitude);
        mapRegion.span.latitudeDelta = MTDEF_SPANLATITUDEDELTA;
        mapRegion.span.longitudeDelta = MTDEF_SPANLONGITUDEDELTA;
        [_mapView setRegion:mapRegion animated:YES];
        _mapAutomaticAnimation = YES;
    }
    
    if(annotations.count == 1) //auto popup schedule
    {
        
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
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(0, 0, 23, 23);
        [button setImage:[UIImage imageNamed:@"menu_news_icon.png"] forState:UIControlStateNormal];
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        //annotationView.animatesDrop = YES;
        annotationView.rightCalloutAccessoryView = button;
        annotationView.image = [UIImage imageNamed:@"global_bus_pin.png"];
        
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

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    MKAnnotationView *aV; 
    
    for (aV in annotationViews) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(_mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[annotationViews indexOfObject:aV] options:UIViewAnimationCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([view.annotation isKindOfClass:[MTStopAnnotation class]])
    {
        MTStopAnnotation* stopAnnotation = (MTStopAnnotation*)view.annotation;
        
        if(stopAnnotation.stop != nil)
        {
            [self displayCardManager:nil];
            stopAnnotation.stop.cancelQueue = NO;
            [stopAnnotation.stop restoreQueuesForBuses];
            
            [_cardManager updateStop:stopAnnotation.stop UsingLanguage:_language];
        }
        
    }
}

- (void)updateCloseStops:(id)sender
{    
    if(![_transpo getALLStopsNearBy:_transpo.coordinates.latitude Lon:_transpo.coordinates.longitude Distance:0])
    {
        MKCoordinateRegion mapRegion;
        mapRegion.center = CLLocationCoordinate2DMake(_transpo.coordinates.latitude, _transpo.coordinates.longitude);
        mapRegion.span.latitudeDelta = MTDEF_SPANLATITUDEDELTA;
        mapRegion.span.longitudeDelta = MTDEF_SPANLONGITUDEDELTA;
        [_mapView setRegion:mapRegion animated:YES];
        _mapAutomaticAnimation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //MKCoordinateSpan span = mapView.region.span;
    //NSLog(@" 1 = ~111 km -> %f = ~ %f km ",span.latitudeDelta,span.latitudeDelta*111);
    if(_searchBar.text.length <= 0)
        [_transpo getMoreStopsNearBy:mapView.centerCoordinate.latitude Lon:mapView.centerCoordinate.longitude Distance:0];
}

- (void)moveMapBackToLocation:(id)sender
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = CLLocationCoordinate2DMake(_transpo.coordinates.latitude, _transpo.coordinates.longitude);
    mapRegion.span.latitudeDelta = MTDEF_SPANLATITUDEDELTA;
    mapRegion.span.longitudeDelta = MTDEF_SPANLONGITUDEDELTA;
    [_mapView setRegion:mapRegion animated:YES];
    _mapAutomaticAnimation = YES;
}

#pragma mark - CARD MANAGER

- (void)displayCardManager:(id)sender
{
    if(_cardManager == nil)
    {
        _cardManager = [[MTCardManager alloc] initWithLanguage:_language AndRect:self.view.frame];
        _cardManager.delegate = self;
    }    
    
    _cardManager.chosenDate = _chosenDate;
    
    _leftBarButton = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(hideCardManager:)];
    
    self.navigationItem.rightBarButtonItem = _cardManagerFavorite;
    
    [self.view removeGestureRecognizer:_panGesture];
    [self.view addSubview:_cardManager];
}

- (void)hideCardManager:(id)sender
{
    //cancel all queues
    _cardManager.stop.cancelQueue = YES;
    [_cardManager.stop cancelQueuesForBuses];
    _cardManager.stop = nil;
    
    [_cardManager removeFromSuperview];
    [self.view addGestureRecognizer:_panGesture];
    
    if(_leftBarButton != nil)
        self.navigationItem.leftBarButtonItem = _leftBarButton;
    
    self.navigationItem.rightBarButtonItem = _resetMapLocationButton;
    
    _leftBarButton = nil;
    
    [_cardManager unload];
}

- (void)addFavoriteClicked:(id)sender
{
    MTStop* stop = _cardManager.stop;
    MTBus* bus = [_cardManager getCurrentBus];
    
    if(stop != nil && bus != nil)
    {
        [_transpo addFavorite:stop WithBus:bus];
    }
}

- (void)removeFavoriteClicked:(id)sender
{
    MTStop* stop = _cardManager.stop;
    MTBus* bus = [_cardManager getCurrentBus];
    
    if(stop != nil && bus != nil)
    {
        [_transpo removeFavorite:stop WithBus:bus];
    }
}

- (void)cardManager:(id)owner UpdateTimesFor:(MTStop *)stop AndBus:(MTBus *)bus
{
    [_transpo getNewScheduleForStop:stop WithRoute:bus ForDate:_chosenDate];
}

- (void)cardManager:(id)card ChangedToStop:(MTStop*)stop AndBus:(MTBus*)bus
{
    if(bus.isFavorite)
    {
        self.navigationItem.rightBarButtonItem = _cardManagerFavoriteAlready;
    }
    else if(!bus.isFavorite)
    {
        self.navigationItem.rightBarButtonItem = _cardManagerFavorite;
    }
}

#pragma mark - OPTIONS DELEGATE

- (void)optionsDate:(id)options dateHasChanged:(NSDate *)newDate
{
    _chosenDate = newDate;
    
    if(_cardManager != nil)
    {
        _cardManager.chosenDate = _chosenDate;
        
        for(UIView* view in self.view.subviews)
        {
            if(view == _cardManager) //card manager is displayed
            {
                [_cardManager forceUpdate];
            }
        }
    }
}

@end
