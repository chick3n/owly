//
//  TripPlannerViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "TripPlannerViewController.h"

@interface TripPlannerViewController ()
- (void)startLoading:(id)sender;
- (void)stopLoading:(id)sender;
- (void)parseTripDetails;
- (void)startPlanningTrip:(id)sender;
- (void)addressFieldsValueChanged:(id)sender;
- (void)removeKeyboard:(id)sender;
- (void)hideDateChangerView:(id)sender;
- (void)addOptions;
- (void)getCurrentAddress;
- (void)updateToCurrentLoaction;
@end

@implementation TripPlannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _data = [[NSMutableArray alloc] init];
        _options = [[SettingsMultiType alloc] init];
        [self addOptions];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //tableview
    [_headerView removeFromSuperview];
    [_optionsButton removeFromSuperview];
    _tableView.tableHeaderView = _headerView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]]];
    
    CGRect optionsFrame = _optionsButton.frame;
    optionsFrame.origin.y = -(optionsFrame.size.height + kOptionsIndent);
    _optionsButton.frame = optionsFrame;
    [_tableView addSubview:_optionsButton];

    
    //mytranspo
    _transpo.delegate = self;
    
    //navigationBar
    MTRightButton* startButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [startButton addTarget:self action:@selector(startPlanningTrip:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:NSLocalizedString(@"START", nil) forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:startButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //view
    self.title = NSLocalizedString(@"TRIPPLANNER", nil);
    
    //datepicker
    _changeDateViewer.minimumDate = [NSDate date];
    [self toggleChangeDateViewer:nil];
    [self changeTripDate:nil];
    
    
    
    //textfields
    _startLocation.placeholder = NSLocalizedString(@"STARTLOCATIONPLACEHOLDER", nil);
    _endLocation.placeholder = NSLocalizedString(@"ENDLOCATIONPLACEHOLDER", nil);
    _startLocation.hasTyped = NO;
    _endLocation.hasTyped = NO;
    //_startLocation.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_train_icon.png"]];
    _endLocation.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tripplanner_destinationsearch_icon.png"]];
    
    UILabel* leftView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 24)];
    leftView1.text = NSLocalizedString(@"STARTLOCATIONLEFT", nil);
    leftView1.font = _startLocation.font;
    leftView1.textColor = [UIColor colorWithRed:157./255. green:157./255. blue:157./255. alpha:1.0];
    leftView1.backgroundColor = [UIColor clearColor];
    leftView1.textAlignment = UITextAlignmentRight;
    
    UILabel* leftView2 = [[UILabel alloc] initWithFrame:leftView1.frame];
    leftView2.text = NSLocalizedString(@"ENDLOCATIONLEFT", nil);
    leftView2.font = leftView1.font;
    leftView2.textColor = leftView1.textColor;
    leftView2.backgroundColor = leftView1.backgroundColor;
    leftView2.textAlignment = leftView1.textAlignment;
    
    _startLocation.leftView = leftView1;
    _endLocation.leftView = leftView2;
    _startLocation.delegate = self;
    _endLocation.delegate = self;
    _startLocation.leftViewMode = UITextFieldViewModeAlways;
    _endLocation.leftViewMode = UITextFieldViewModeAlways;
    _startLocation.rightViewMode = UITextFieldViewModeUnlessEditing;
    _endLocation.rightViewMode = UITextFieldViewModeUnlessEditing;
    _startLocation.clearButtonMode = UITextFieldViewModeWhileEditing;
    _endLocation.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_startLocation addTarget:self action:@selector(addressFieldsValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_endLocation addTarget:self action:@selector(addressFieldsValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self getCurrentAddress];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tableView.contentInset = UIEdgeInsetsMake(_optionsButton.frame.size.height, 0, 0, 0);
    [UIView animateWithDuration:0.5
                     animations:^{
                         _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Transpo Delegate

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedTripPlan:(NSDictionary*)trip
{
    _tripDetails = nil;
    if(state == MTRESULTSTATE_SUCCESS)
    {
        if(trip != nil)
            _tripDetails = trip;
    }
    else {
        _tripDetails = [NSDictionary dictionaryWithObject:
                                                   [NSDictionary dictionaryWithObject:NSLocalizedString(@"TPERROR", nil)
                                                                               forKey:@"error"]
                                                   forKey:@"error"];
    }
    
    [self parseTripDetails];
    [_tableView reloadData];
    [self stopLoading:nil];
}

#pragma mark - Queue Safe

- (void)cancelQueues
{
    if(_tripPlanner == nil)
        return;
    
    _tripPlanner.cancelQueue = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_data.count == 0) ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoticesCell";
    
    TripDetailsCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TripDetailsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    TripDetailsDisplay* display = (TripDetailsDisplay*)[_data objectAtIndex:indexPath.row];
    
    cell.text.text = display.details;
    CGRect textFrame = cell.text.frame;
    textFrame.size.height = display.detailsSize.height;
    cell.text.frame = textFrame;
    
    cell.rightAccessoryText = display.duration;
    cell.leftAccessoryImage = display.icon;
    cell.indent = display.indent;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 1
    TripDetailsDisplay* display = (TripDetailsDisplay*)[_data objectAtIndex:indexPath.row];

    if(display.detailsSize.height + 12 > kMinTripCellHeight) //12 is the origin y it is starting at in the cell have to count that or double lines dont work.
        return display.detailsSize.height + ((kMinTripCellHeight/2) + 8); //8 is from font height / 2
    return kMinTripCellHeight;
#endif
    
#if 0
    TripDetailsDisplay* display = (TripDetailsDisplay*)[_data objectAtIndex:indexPath.row];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(38, 12, 216, 16)];
    text.backgroundColor = [UIColor clearColor];
    text.numberOfLines = 0;
    text.lineBreakMode = UILineBreakModeWordWrap;
    text.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    text.text = display.details;
    [text sizeToFit];
    
    
    if(text.frame.size.height > kMinTripCellHeight)
        return text.frame.size.height + ((kMinTripCellHeight / 2) + 8);
    return kMinTripCellHeight;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideDateChangerView:nil];
    [self removeKeyboard:nil];
}

#pragma mark - ScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideDateChangerView:nil];
    [self removeKeyboard:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.contentOffset.y < _optionsButton.frame.origin.y)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _tableView.contentInset = UIEdgeInsetsMake(_optionsButton.frame.size.height + (kOptionsIndent*2), 0, 0, 0);
                         }];
    }
}

#pragma mark - loading

- (void)startLoading:(id)sender
{
    [_loadingView startAnimating];
}

- (void)stopLoading:(id)sender
{
    [_loadingView stopAnimating];
}

- (void)parseTripDetails
{
    if(_tripDetails == nil)
        return;
    
    int statusCount = 0;
    
    //error
    NSDictionary* error = [_tripDetails objectForKey:@"error"];
    if(error != nil)
    {
        [_data removeAllObjects];
        
        TripDetailsDisplay* errorDisplay = [[TripDetailsDisplay alloc] init];
        errorDisplay.details = [error valueForKey:@"error"];
        errorDisplay.title = kActionNote;
        
        [_data addObject:errorDisplay];
        
        NSArray* subErrors = [error objectForKey:@"subErrors"];
        if(subErrors != nil)
        {
            for(int x=0; x<subErrors.count; x++)
            {
                NSString* errorContent = [subErrors objectAtIndex:x];
                if(errorContent == nil)
                    continue;
                
                TripDetailsDisplay *errorSubDisplay = [[TripDetailsDisplay alloc] init];
                errorSubDisplay.details = errorContent;
                errorSubDisplay.indent = YES;
                
                [_data addObject:errorSubDisplay];
            }
        }
        
        return;
    }
    
    //depart
    NSDictionary* depart = [_tripDetails objectForKey:@"depart"];
    if(depart != nil)
    {
        if(([depart objectForKey:@"date"] != nil) && 
           ([depart objectForKey:@"time"] != nil) &&
           ([depart objectForKey:@"type"] != nil))
        {
            TripDetailsDisplay* departDisplay = [[TripDetailsDisplay alloc] init];
            NSArray* details = [depart objectForKey:@"details"];
            if(details && details.count > 0)
            {
                NSMutableString *detailsResult = [[NSMutableString alloc] init];
                NSString *newLine = @"\n";
                for(int x=0; x<details.count; x++)
                {
                    NSString * result = [(NSString*)[details objectAtIndex:x] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [detailsResult appendFormat:@"%@%@", ((x>0) ? newLine : @""), result];
                }
                departDisplay.details = (NSString*)detailsResult;
            }
            else {
                departDisplay.details = [depart objectForKey:@"date"];
            }
            departDisplay.duration = [depart objectForKey:@"time"];
            departDisplay.title = [depart objectForKey:@"type"];
            departDisplay.icon = [UIImage imageNamed:@"tripplanner_start_icon.png"];
            
            [_data addObject:departDisplay];
            statusCount += 1;
        }
    }
    
    NSArray* steps = [_tripDetails objectForKey:@"steps"];
    if(steps != nil)
    {
        for(int x=0; x<steps.count; x++)
        {
            NSDictionary* step = [steps objectAtIndex:x];
            if(step != nil)
            {
                if(([step objectForKey:@"type"] != nil) &&
                   ([step objectForKey:@"desc"] != nil) &&
                   ([step objectForKey:@"duration"] != nil))
                {
                    TripDetailsDisplay* stepDisplay = [[TripDetailsDisplay alloc] init];
                    stepDisplay.details = [step objectForKey:@"desc"];
                    stepDisplay.duration = [step objectForKey:@"duration"];
                    stepDisplay.title = [step objectForKey:@"type"];
                    stepDisplay.displaySize = kTripDetialsDisplaySize;
                    //stepDisplay.icon = [UIImage imageNamed:@"global_bell_icon.png"];
                    
                    [_data addObject:stepDisplay];
                    statusCount += 1;
                    
                    NSArray* subSteps = [step objectForKey:@"subStep"];
                    if(subSteps != nil)
                    {
                        for(int y=0; y<subSteps.count; y++)
                        {
                            NSDictionary* subStep = [subSteps objectAtIndex:y];
                            
                            if(([subStep objectForKey:@"type"] != nil) &&
                               ([subStep objectForKey:@"desc"] != nil) &&
                               ([subStep objectForKey:@"duration"] != nil))
                            {
                                TripDetailsDisplay* subStepDisplay = [[TripDetailsDisplay alloc] init];
                                subStepDisplay.indent = YES;
                                subStepDisplay.details = [subStep objectForKey:@"desc"];
                                subStepDisplay.duration = [subStep objectForKey:@"duration"];
                                subStepDisplay.title = [subStep objectForKey:@"type"];
                                subStepDisplay.displaySize = kTripDetialsDisplaySize;
                                
                                [_data addObject:subStepDisplay];
                            }
                        }
                    }
                }
            }
        }
    }
    
    //arrive
    NSDictionary* arrive = [_tripDetails objectForKey:@"arrive"];
    if(arrive != nil)
    {
        if(([arrive objectForKey:@"date"] != nil) && 
           ([arrive objectForKey:@"time"] != nil) &&
           ([arrive objectForKey:@"type"] != nil))
        {
            TripDetailsDisplay* arriveDisplay = [[TripDetailsDisplay alloc] init];
            NSArray* details = [arrive objectForKey:@"details"];
            if(details && details.count > 0)
            {
                NSMutableString *detailsResult = [[NSMutableString alloc] init];
                NSString *newLine = @"\n";
                for(int x=0; x<details.count; x++)
                {
                    NSString * result = [(NSString*)[details objectAtIndex:x] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [detailsResult appendFormat:@"%@%@", ((x>0) ? newLine : @""), result];
                }
                arriveDisplay.details = (NSString*)detailsResult;
            }
            else {
                arriveDisplay.details = [depart objectForKey:@"date"];
            }
            arriveDisplay.duration = [arrive objectForKey:@"time"];
            arriveDisplay.title = [arrive objectForKey:@"type"];
            //arriveDisplay.icon = [UIImage imageNamed:@"global_bell_icon.png"];
            
            [_data addObject:arriveDisplay];
            statusCount += 1;
        }
    }
    
    if(statusCount < 2) //good
        [_data removeAllObjects];
}

#pragma mark - EDITING STUFF

- (IBAction)flipLocations:(id)sender
{
    NSString* value1 = _startLocation.text;
    NSString* value2 = _endLocation.text;
    
    _startLocation.text = value2;
    _endLocation.text = value1;
    
    if(value1.length <= 0)
        _endLocation.hasTyped = NO;
    
    if(value2.length <= 0)
        _startLocation.hasTyped = NO;
    
    if([_startLocation.placeholder isEqualToString:CurrentLocation])
    {
        _startLocation.placeholder = NSLocalizedString(@"STARTLOCATIONPLACEHOLDER", nil);
        _endLocation.placeholder = CurrentLocation;
    }
    else if([_endLocation.placeholder isEqualToString:CurrentLocation])
    {
        _endLocation.placeholder = NSLocalizedString(@"ENDLOCATIONPLACEHOLDER", nil);
        _startLocation.placeholder = CurrentLocation;
    }
    
    [self addressFieldsValueChanged:nil];
    
    [self removeKeyboard:nil];
}

- (void)addressFieldsValueChanged:(id)sender
{
    BOOL canStartPlan = NO;
    
    if((_startLocation.text.length > 0 || [_startLocation.placeholder isEqualToString:CurrentLocation])
       && (_endLocation.text.length > 0 || [_endLocation.placeholder isEqualToString:CurrentLocation]))
        canStartPlan = YES;
    
     self.navigationItem.rightBarButtonItem.enabled = canStartPlan;
}

- (void)removeKeyboard:(id)sender
{
    [_startLocation resignFirstResponder];
    [_endLocation resignFirstResponder];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    TripTextField* field = (TripTextField*)textField;
    field.hasTyped = YES;
    
    if(field == _startLocation)
        _startLocation.placeholder = NSLocalizedString(@"STARTLOCATIONPLACEHOLDER", nil);
    else if(field == _endLocation)
        _endLocation.placeholder = NSLocalizedString(@"ENDLOCATIONPLACEHOLDER", nil);
    
    [self hideDateChangerView:nil];
}

#pragma mark - ACTIONS

- (void)getCurrentAddress
{
    if(_geoCoder == nil)
    {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    
    if(_transpo.hasRealCoordinates)
    {
        [_geoCoder reverseGeocodeLocation:_transpo.clLocation
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                            
                            _currentLocation = [placeMark.addressDictionary valueForKey:@"Street"];
                            
                            [self updateToCurrentLoaction];
                        }];
    }
}

- (void)updateToCurrentLoaction
{
    if(_currentLocation != nil && _startLocation.hasTyped == NO)
    {
        _startLocation.placeholder = CurrentLocation;
    }
}

- (void)startPlanningTrip:(id)sender
{
    [_data removeAllObjects];
    _tripDetails = nil;
    [_tableView reloadData];
    [self startLoading:nil];
    
    [self removeKeyboard:nil];
    [self hideDateChangerView:nil];
    
    //verify everything is set
    if(_startLocation.text.length <= 0 && ![_startLocation.placeholder isEqualToString:CurrentLocation])
        return;
    if(_endLocation.text.length <= 0 && ![_endLocation.placeholder isEqualToString:CurrentLocation])
        return;
    
    MTTripPlanner* tripPlanner = [[MTTripPlanner alloc] init];
    
    tripPlanner.startingLocation = ([_startLocation.placeholder isEqualToString:CurrentLocation]) ? _currentLocation : _startLocation.text;
    tripPlanner.endingLocation = ([_endLocation.placeholder isEqualToString:CurrentLocation]) ? _currentLocation : _endLocation.text;
    
    _startLocation.text = tripPlanner.startingLocation;
    _endLocation.text = tripPlanner.endingLocation;
   
    tripPlanner.departBy = YES;
    tripPlanner.arriveBy = _changeDateViewer.date;
    
    //parse options
    NSDictionary* options = _options.options;
    for(NSString* key in [options allKeys])
    {
        NSNumber* option = [options objectForKey:key];
        
        if([key isEqualToString:kAccessible])
            tripPlanner.accessible = [option boolValue];
        else if([key isEqualToString:kRegularFare])
            tripPlanner.regulareFare = [option boolValue];
        else if([key isEqualToString:kExcludeSTO])
            tripPlanner.excludeSTO = [option boolValue];
        else if([key isEqualToString:kBikeRacks])
            tripPlanner.bikeRack = [option boolValue];
    }
    
    [_transpo getTripPlanner:tripPlanner];
}

- (void)toggleChangeDateViewer:(id)sender
{
    CGRect newPositionFrame = _changeDateViewer.frame;
    
    if(_changeDateViewer.frame.origin.y >= self.view.frame.size.height) //hidden -> show
    {
        newPositionFrame.origin.y = self.view.frame.size.height - newPositionFrame.size.height;
        [self removeKeyboard:nil];
    }
    else newPositionFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _changeDateViewer.frame = newPositionFrame;
                     }];
}

- (void)hideDateChangerView:(id)sender
{
    CGRect newPositionFrame = _changeDateViewer.frame;
    newPositionFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _changeDateViewer.frame = newPositionFrame;
                     }];
}

- (IBAction)changeTripDate:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = NSLocalizedString(@"PLANTRIPPREFIX", nil);
        
    _tripDateLabel.text = [dateFormatter stringFromDate:[_changeDateViewer date]];
}

#pragma mark - Options

- (void)addOptions
{
    [_options addOption:kAccessible WithValue:0];
    [_options addOption:kRegularFare WithValue:0];
    [_options addOption:kExcludeSTO WithValue:0];
    [_options addOption:kBikeRacks WithValue:0];
}

- (void)changeOptions:(id)sender
{
    SettingsListMultiViewController *mvc = [[SettingsListMultiViewController alloc] initWithNibName:@"SettingsListMultiViewController" bundle:nil];
    mvc.multiSettings = _options;
    mvc.language = _language;
    mvc.navPanGesture = _navPanGesture;
    mvc.panGesture = _panGesture;
    
    [self.navigationController pushViewController:mvc animated:YES];
}

@end
