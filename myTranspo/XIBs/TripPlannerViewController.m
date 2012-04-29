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
@end

@implementation TripPlannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]]];
    _transpo.delegate = self;
    
    //navigationBar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(startPlanningTrip:)];
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
    _startLocation.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_train_icon.png"]];
    _endLocation.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_train_icon.png"]];
    
    UILabel* leftView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 14)];
    leftView1.text = NSLocalizedString(@"STARTLOCATIONLEFT", nil);
    leftView1.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    leftView1.textColor = [UIColor blackColor];
    leftView1.backgroundColor = [UIColor clearColor];
    leftView1.textAlignment = UITextAlignmentRight;
    
    UILabel* leftView2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 14)];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Transpo Delegate

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedTripPlan:(NSDictionary*)trip
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        if(trip != nil)
            _tripDetails = trip;
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
    TripDetailsDisplay* display = (TripDetailsDisplay*)[_data objectAtIndex:indexPath.row];

    return display.detailsSize.height;
}

#pragma mark - loading

- (void)startLoading:(id)sender
{
    
}

- (void)stopLoading:(id)sender
{
    
}

- (void)parseTripDetails
{
    if(_tripDetails == nil)
        return;
    
    NSArray* keys = [_tripDetails allKeys];
    if(keys.count != 3)
        return;
    
    int statusCount = 0;
    
    //depart
    NSDictionary* depart = [_tripDetails objectForKey:@"depart"];
    if(depart != nil)
    {
        if(([depart objectForKey:@"date"] != nil) && 
           ([depart objectForKey:@"time"] != nil) &&
           ([depart objectForKey:@"type"] != nil))
        {
            TripDetailsDisplay* departDisplay = [[TripDetailsDisplay alloc] init];
            departDisplay.details = [depart objectForKey:@"date"];
            departDisplay.duration = [depart objectForKey:@"time"];
            departDisplay.title = [depart objectForKey:@"type"];
            departDisplay.icon = [UIImage imageNamed:@"global_bell_icon.png"];
            
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
                    stepDisplay.icon = [UIImage imageNamed:@"global_bell_icon.png"];
                    
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
                                subStepDisplay.details = [subStep objectForKey:@"desc"];
                                subStepDisplay.duration = [subStep objectForKey:@"duration"];
                                subStepDisplay.title = [subStep objectForKey:@"type"];
                                subStepDisplay.indent = YES;
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
            arriveDisplay.details = [arrive objectForKey:@"date"];
            arriveDisplay.duration = [arrive objectForKey:@"time"];
            arriveDisplay.title = [arrive objectForKey:@"type"];
            arriveDisplay.icon = [UIImage imageNamed:@"global_bell_icon.png"];
            
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
    
    [self removeKeyboard:nil];
}

- (void)addressFieldsValueChanged:(id)sender
{
    BOOL canStartPlan = NO;
    
    if(_startLocation.text.length > 0 && _endLocation.text.length > 0)
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
    [self hideDateChangerView:nil];
}

#pragma mark - ACTIONS

- (void)startPlanningTrip:(id)sender
{
    [_data removeAllObjects];
    _tripDetails = nil;
    [_tableView reloadData];
    
    [self removeKeyboard:nil];
    [self hideDateChangerView:nil];
    
    //verify everything is set
    if(_startLocation.text.length <= 0)
        return;
    if(_endLocation.text.length <= 0)
        return;
    
    MTTripPlanner* tripPlanner = [[MTTripPlanner alloc] init];
    tripPlanner.startingLocation = _startLocation.text;
    tripPlanner.endingLocation = _endLocation.text;
    
    tripPlanner.departBy = NO;
    tripPlanner.arriveBy = [NSDate date];
    
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
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    NSString* startText = NSLocalizedString(@"PLANTRIPPREFIX", nil);
    NSString* dateText = [dateFormatter stringFromDate:[_changeDateViewer date]];
    
    _tripDateLabel.text = [NSString stringWithFormat:@"%@ %@", startText, dateText];
}

@end
