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
- (void)changeTripScheduleTime:(id)sender;
- (void)dateHasChanged:(id)sender;
- (void)hideSearchBar:(id)sender;
- (void)showSearchBar:(id)sender;
- (void)scrollingRefreshTick:(id)sender;
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
#if 1
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
    UIButton* timesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [timesButton setImage:[UIImage imageNamed:@"global_findme_btn.png"] forState:UIControlStateNormal];
    [timesButton addTarget:self action:@selector(findMe:) forControlEvents:UIControlEventTouchUpInside];
    [timesButton setFrame:CGRectMake(0, 0, 41, 29)];
    _resetMapLocationButton = [[UIBarButtonItem alloc] initWithCustomView:timesButton];
    [self.navigationItem setRightBarButtonItem:_resetMapLocationButton];
    
    //view
    //[self.view addGestureRecognizer:_panGesture];

    //searchcontroller
    [_searchBar setPlaceholder:NSLocalizedString(@"MTDEF_SEARCHPLANCEHOLDER", nil)];
    [_searchBar setSelectedScopeButtonIndex:0];
    [_searchBar sizeToFit];
    //[[_searchBar.subviews objectAtIndex:0] setAlpha:0.0];
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"search_background.jpg"]];
    [_searchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"global_searchfilter_bg.jpg"]];
    [_searchBar setScopeBarButtonBackgroundImage:[UIImage imageNamed:@"global_searchfilter_selected_btn.png"] forState:UIControlStateNormal];
    [_searchBar setScopeBarButtonBackgroundImage:[UIImage imageNamed:@"global_searchfilter_default_btn.png"] forState:UIControlStateSelected];
    [_searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor
                                                      , [[UIColor blackColor] colorWithAlphaComponent:0.35], UITextAttributeTextShadowColor
                                                      , [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset
                                                      , [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0], UITextAttributeFont
                                                      , nil] 
                                            forState:UIControlStateNormal];
    [_searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor
                                                      , [[UIColor blackColor] colorWithAlphaComponent:0.35], UITextAttributeTextShadowColor
                                                      , [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset
                                                      , [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0], UITextAttributeFont
                                                      , nil] 
                                            forState:UIControlStateSelected];
    [_searchBar setScopeBarButtonDividerImage:[UIImage imageNamed:@"global_searchfilter_line.jpg"]
                          forLeftSegmentState:UIControlStateNormal
                            rightSegmentState:UIControlStateSelected];
    //[self.searchDisplayController.searchResultsTableView addSubview:_searchLoading];
    
    //date stuff
    _chosenDate = [NSDate date]; 
    
    //date selector
    _dateSelector.minimumDate = _chosenDate;
    _dateSelector.frame = CGRectMake(0, self.view.frame.size.height, _dateSelector.frame.size.width, _dateSelector.frame.size.height);
    [_dateSelector addTarget:self action:@selector(dateHasChanged:) forControlEvents:UIControlEventValueChanged];
    
    //searchTableView[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_bg2.png"]]];
    //[self.searchDisplayController.searchResultsTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]]];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"global_lightbackground_tile.jpg"]]];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
#endif
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
#if 1    
    if(_mapView.annotations.count <= 0)
    {
        [self updateCloseStops:nil];
    }
#endif
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
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - QUEUE SAFE

- (void)cancelQueues
{
    
}

#pragma mark - SEARCH DISPLAY DELEGATE

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _searchBar.selectedScopeButtonIndex = 0;
    _searchBar.text = @"";
    _searchResults = nil;
    
    _findMe.hidden = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if(_searchRefresh != nil && [_searchRefresh isValid])
    {
        [_searchRefresh invalidate];
        _searchRefresh = nil;
    }
    
    [_searchBar stopAnimating];
    
    if(_searchBar.text.length == 0)
    {
        [_mapView removeAnnotations:_mapView.annotations];
        [self mapView:_mapView regionDidChangeAnimated:YES]; //update to near by stops as we arent search anything anymore?
    }
    
    _findMe.hidden = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if(searchBar.text.length == 0) //should always return true on cancel?
    {
        [_mapView removeAnnotations:_mapView.annotations];
        [self mapView:_mapView regionDidChangeAnimated:YES]; //update to near by stops as we arent search anything anymore?
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(_searchRefresh != nil)
    {
        [_searchRefresh invalidate];
        _searchRefresh = nil;
    }
    
    if(searchString.length <= 0)
    {
        if(_searchRefresh != nil)
        {
            [_searchRefresh invalidate];
            _searchRefresh = nil;
        }
        
        [_searchBar stopAnimating];
        return NO;
    }
    
    _searchRefresh = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshStopSearch:) userInfo:nil repeats:NO];
    
#if 0
    if(!_isSearchInProgress) //set timer to call on it 1 second after
    {
        [_transpo getStopsForQuery:searchString AtPage:0];
        _isSearchInProgress = YES;
        
        if(_searchRefresh != nil)
        {
            [_searchRefresh invalidate];
            _searchRefresh = nil;
        }
    }
    else
    {
        if(_searchRefresh != nil)
        {
            [_searchRefresh invalidate];
            _searchRefresh = nil;
        }
        
        _searchRefresh = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshStopSearch:) userInfo:nil repeats:NO];
    }
#endif
    
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
        cell.title = bus.BusNumberDisplay;
        cell.subtitle = bus.DisplayHeading;
        cell.type = CELLBUS;
    }
    else if(indexPath.section == 1) //stops & streets
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        
        cell.title = @"";
        cell.subtitle = [NSString stringWithFormat:@"%d %@ %@", stop.StopNumber, NSLocalizedString(@"AT", nil), stop.StopNameDisplay];
        
        cell.type = CELLSTOP;
    }
    else if(indexPath.section == 2)
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        
        cell.title = @"";
        cell.subtitle = stop.StopNameDisplay;
        
        cell.type = CELLSTREET;
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
    return kMTSEARCHCELLHEIGHT;
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
    [header addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_category_bar.jpg"]]];
    UILabel *tableViewHeadlerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, 312, 17)];
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
    else if(indexPath.section == 1)
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        [_transpo getRoutesForStop:stop];
        searchBarText = [NSString stringWithFormat:@"%d", stop.StopNumber];
    }
    else if(indexPath.section == 2)
    {
        MTStop* stop = [sectionResults objectAtIndex:indexPath.row];
        
#if 0
        [_mapView removeAnnotations:_mapView.annotations];
#endif
#if 1
        MKCoordinateRegion mapRegion;
        mapRegion.center = CLLocationCoordinate2DMake(stop.Latitude, stop.Longitude);
        mapRegion.span.latitudeDelta = MTDEF_SPANLATITUDEDELTA;
        mapRegion.span.longitudeDelta = MTDEF_SPANLONGITUDEDELTA;
        [_mapView setRegion:mapRegion animated:NO];
#endif
         //update to near by stops as we arent search anything anymore?
        searchBarText = @"";
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
    [bus updatePrevNextObjects];
    [_cardManager updateDetailsForStop:stop WithRoute:bus];
}

- (void)myTranspo:(MTResultState)state addedFavorite:(MTStop *)favorite AndBus:(MTBus*)bus
{
    if(favorite == nil && bus == nil)
        return;
    else if(favorite != nil && bus == nil) //add stop only
    {
        if(_cardManager != nil)
            [_cardManager reloadQuickSelect];
        return;
    }
    
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
    if(favorite == nil && bus == nil)
        return;
    else if(favorite != nil && bus == nil) //removed stop only
    {
        if(_cardManager != nil)
            [_cardManager reloadQuickSelect];
        return;
    }
    
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
    for(id<MKAnnotation> annotation in _mapView.annotations)
    {
        if([annotation isKindOfClass:[MTStopAnnotation class]])
        {
            if(animated)
                [_mapView removeAnnotation:annotation];
        }
    }
    
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
        stopAnnotation.stopStreetName = stop.StopNameDisplay;
        stopAnnotation.stop = stop;
        
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

- (void)customCalloutClicked:(id)sender
{
    CustomCallout* view = (CustomCallout*)sender;
    
    if([view.annotation isKindOfClass:[MTStopAnnotation class]])
    {
        MTStop* stop = [(MTStopAnnotation*)view.annotation stop];
        if(stop.BusIds.count == 0)
            [_transpo getSynchRoutesForStop:stop];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
    if ([annotation isKindOfClass:[MTStopAnnotation class]]) 
	{
		static NSString *identifier = @"MTStopAnnotation";
        CustomCallout *annotationView = (CustomCallout *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

		if (annotationView == nil) {
            annotationView = [[CustomCallout alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.delegate = self;
        } else {
            annotationView.annotation = annotation;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(0, 0, 25, 26);
        [button setImage:[UIImage imageNamed:@"map_arrow_btn.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"map_arrow_btn.png"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"map_arrow_btn.png"] forState:UIControlStateSelected];
        
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
    else if([annotation isKindOfClass:[MKUserLocation class]]) //replace blue dot
    {
        static NSString *identifier = @"MTPersonAnnotation";
        MKAnnotationView* annotiationView = (MKAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(annotiationView == nil)
        {
            annotiationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        annotiationView.annotation = annotation;
        
        annotiationView.enabled = YES;
        annotiationView.canShowCallout = NO;
        annotiationView.image = [UIImage imageNamed:@"person_location_pin.png"]; 
        
        return annotiationView;
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
            
            BOOL stopFavorite = [_transpo isFavorite:stopAnnotation.stop WithBus:nil];
            stopAnnotation.stop.isFavorite = stopFavorite;
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
    if(_searchBar.text.length <= 0)
    {
        if(_scrollingRefresh != nil)
        {
            [_scrollingRefresh invalidate];
            _scrollingRefresh = nil;
        }
        
        _searchRefresh = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scrollingRefreshTick:) userInfo:nil repeats:NO];
    }
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

- (void)scrollingRefreshTick:(id)sender
{
    [_transpo getMoreStopsNearBy:_mapView.centerCoordinate.latitude Lon:_mapView.centerCoordinate.longitude Distance:0];
}

- (IBAction)findMe:(id)sender
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
    
    [self hideSearchBar:nil];
    [self.navigationController.navigationBar removeGestureRecognizer:_navPanGesture];
    
    _cardManager.chosenDate = _chosenDate;
    
    _leftBarButton = self.navigationItem.leftBarButtonItem;
    if(_cardManagerClose == nil)
    {
        MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
        [backButton setTitle:NSLocalizedString(@"CLOSE", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(hideCardManager:) forControlEvents:UIControlEventTouchUpInside];
        _cardManagerClose = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    self.navigationItem.leftBarButtonItem = _cardManagerClose;
    
    self.navigationItem.rightBarButtonItem = _cardManagerFavorite;
    
    //[self.view removeGestureRecognizer:_panGesture];
    [self.view addSubview:_cardManager];
}

- (void)hideCardManager:(id)sender
{
    _cardManagerFavoriteAlready.enabled = YES;
    _cardManagerFavorite.enabled = YES;
    
    //cancel all queues
    _cardManager.stop.cancelQueue = YES;
    [_cardManager.stop cancelQueuesForBuses];
    _cardManager.stop = nil;
    
    [_cardManager removeFromSuperview];
    [self.navigationController.navigationBar addGestureRecognizer:_navPanGesture];
    //[self.view addGestureRecognizer:_panGesture];
    
    if(_leftBarButton != nil)
        self.navigationItem.leftBarButtonItem = _leftBarButton;
    
    self.navigationItem.rightBarButtonItem = _resetMapLocationButton;
    
    _leftBarButton = nil;
    
    [_cardManager unload];
    
    [self showSearchBar:nil];
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
    [_transpo getNewScheduleForStop:stop WithRoute:bus ForDate:_chosenDate StoreTimes:NO];
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

- (void)cardManager:(id)card FavoriteStop:(MTStop *)stop
{
    if(stop != nil)
    {
        if(!stop.isFavorite)
            [_transpo addFavorite:stop WithBus:nil];
        else [_transpo removeFavorite:stop WithBus:nil];
    }
}

- (void)cardManager:(id)card HideFavoritesButton:(BOOL)hide
{
    _cardManagerFavoriteAlready.enabled = !hide;
    _cardManagerFavorite.enabled = !hide;
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

- (void)changeTripScheduleTime:(id)sender
{
    CGRect datePickerFrame = _dateSelector.frame;
    
    if(datePickerFrame.origin.y == self.view.frame.size.height)
    {
        UIView *fadedView = [[UIView alloc] initWithFrame:self.view.frame];
        fadedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        fadedView.tag = 20123;
        [self.view insertSubview:fadedView belowSubview:_dateSelector];
        
        datePickerFrame.origin.y -= _dateSelector.frame.size.height;
        [self hideSearchBar:nil];
    }
    else
    {
        UIView* fadedView = [self.view viewWithTag:20123];
        if(fadedView != nil)
            [fadedView removeFromSuperview];
        datePickerFrame.origin.y = self.view.frame.size.height;
        [self showSearchBar:nil];
    }
    
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _dateSelector.frame = datePickerFrame;
                     }];
    
#if 0
    [_menuControl revealOptions:nil];
#endif
}

#pragma mark - Date Pickerview Delegate

- (void)dateHasChanged:(id)sender
{
    [self optionsDate:nil dateHasChanged:_dateSelector.date];
}

- (void)hideSearchBar:(id)sender
{
    CGRect searchFrame = _searchBar.frame;
    searchFrame.origin.y -= _searchBar.frame.size.height;
    CGRect mapFrame = _mapView.frame;
    mapFrame.size.height += _searchBar.frame.size.height;
    mapFrame.origin.y = 0;
    
    _findMe.hidden = YES;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _searchBar.frame = searchFrame;
                         _mapView.frame = mapFrame;
                     }];
}

- (void)showSearchBar:(id)sender
{
    CGRect searchFrame = _searchBar.frame;
    searchFrame.origin.y = 0;
    CGRect mapFrame = _mapView.frame;
    mapFrame.size.height -= _searchBar.frame.size.height;
    mapFrame.origin.y = 44;
    
    _findMe.hidden = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _searchBar.frame = searchFrame;
                         _mapView.frame = mapFrame;
                     }];
}

@end
