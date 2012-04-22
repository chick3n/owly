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
    
    MTTripPlanner* tripPlanner = [[MTTripPlanner alloc] init];
    tripPlanner.startingLocation = @"21 Gospel Oak";
    tripPlanner.endingLocation = @"99 Bank St";
    tripPlanner.departBy = NO;
    tripPlanner.arriveBy = [NSDate date];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _transpo.delegate = self;
    [_transpo getTripPlanner:tripPlanner];
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    }
    
    TripDetailsDisplay* display = (TripDetailsDisplay*)[_data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@: %@", ((display.indent) ? @"-" : @""), display.title, display.details];

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
            
            [_data addObject:arriveDisplay];
            statusCount += 1;
        }
    }
    
    if(statusCount < 2) //good
        [_data removeAllObjects];
}

@end
