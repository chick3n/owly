//
//  SettingsManageNotificationPreViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsManageNotificationPreViewController.h"

@interface SettingsManageNotificationPreViewController ()
- (void)goBack:(id)sender;
- (void)parseTrips:(NSArray*)trips;
- (NSString*)parseRepeatDays:(NSArray*)notifications;
- (NSString*)parseHeaderInfo:(NSArray*)notifications;
@end

@implementation SettingsManageNotificationPreViewController
@synthesize data = _data;
@synthesize tripData = _tripData;
@synthesize sortNotificationsDayOfWeek = _sortNotificationsDayOfWeek;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //table view
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_darkbackground_tile.jpg"]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    //navigationcontroller
    MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];        
    [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //view
    self.title = NSLocalizedString(@"MTDEF_NOTIFICATIONS", nil);
    
    //sorters
    _sortNotificationsDayOfWeek = ^NSComparisonResult(id obj1, id obj2) {
        UILocalNotification* alert1 = obj1, *alert2 = obj2;
        int dayOfWeek1 = [MTHelper DayOfWeekForDate:alert1.fireDate];
        int dayOfWeek2 = [MTHelper DayOfWeekForDate:alert2.fireDate];
        
        if(dayOfWeek1 > dayOfWeek2)
            return NSOrderedDescending;
        if(dayOfWeek1 < dayOfWeek2)
            return NSOrderedAscending;
        
        return NSOrderedSame;
    };
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
    _data = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self parseTrips:[_transpo tripNotifications]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark - Parse Trips

- (void)parseTrips:(NSArray *)trips
{
    if(_data != nil)
        _data = nil;
    
    if(_tripData != nil)
        _tripData = nil;
    
    if(trips == nil)
    {
        _data = [NSArray array];
        [_tableView reloadData];
        return;
    }
    
    //join notifications now
    NSMutableDictionary *tripData = [[NSMutableDictionary alloc] init];
    
    for(UILocalNotification* notification in trips)
    {
        NSString *routeNumber, *stopNumber, *timeNumber;
        NSDictionary* userInfo = notification.userInfo;
        
        routeNumber = [userInfo valueForKey:kMTNotificationBusNumberKey];
        stopNumber = [userInfo valueForKey:kMTNotificationStopNumberKey];
        timeNumber = [userInfo valueForKey:kMTNotificationTripTimeKey];
        
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", routeNumber, stopNumber, timeNumber];
        
        NSMutableArray *entries = [tripData objectForKey:key];
        
        if(entries == nil)
        {
            entries = [[NSMutableArray alloc] init];
        }
        
        [entries addObject:notification];
        [tripData setObject:entries forKey:key];
    }
        
    _tripData = tripData;
    _data = [tripData allKeys];
    [_tableView reloadData];
}

- (NSString*)parseRepeatDays:(NSArray*)notifications
{
    if(notifications == nil)
        return @"";
    
    if(notifications.count <= 0)
        return @"";
    
    NSArray* sortedNotifications = [notifications sortedArrayUsingComparator:_sortNotificationsDayOfWeek];
    NSMutableString *repeatedDays = [[NSMutableString alloc] init];
    
    for(UILocalNotification* notification in sortedNotifications)
    {
        int dayOfWeek = [MTHelper DayOfWeekForDate:notification.fireDate];
        switch (dayOfWeek) {
            case 1://sunday
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_SUNDAY", nil)];
                break;
            case 2:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_MONDAY", nil)];
                break;
            case 3:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_TUESDAY", nil)];
                break;
            case 4:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_WEDNESDAY", nil)];
                break;
            case 5:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_THURSDAY", nil)];
                break;
            case 6:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_FRIDAY", nil)];
                break;
            case 7:
                [repeatedDays appendFormat:@"%@ ", NSLocalizedString(@"MTDEF_SATURDAY", nil)];
                break;
        }
    }
    
    if(repeatedDays.length > 0)
        [repeatedDays insertString:NSLocalizedString(@"OCCURSON", nil) atIndex:0];
    
    return repeatedDays;
}

- (NSString*)parseHeaderInfo:(NSArray*)notifications
{
    if(notifications == nil)
        return @"";
    
    if(notifications.count == 0)
        return @"";
    
    UILocalNotification *notification = [notifications objectAtIndex:0];
    NSDictionary *userInfo = notification.userInfo;
    
    return [NSString stringWithFormat:NSLocalizedString(@"ALERTMANAGERHEADEROUTPUT", nil)
            , [userInfo valueForKey:kMTNotificationBusNumberKey]
            , [userInfo valueForKey:kMTNotificationBusDisplayHeading]
            //, [userDic valueForKey:kMTNotificationTripAlertTimeKey]
            , [userInfo valueForKey:kMTNotificationTripTimeKey]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_data == nil) ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_data == nil) ? 0 : _data.count;
}

#define kNoticesCellBackgroundTag 104
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:140./255. green:139./255. blue:139./255. alpha:1.0];
        cell.detailTextLabel.shadowColor = [UIColor whiteColor];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
        cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
        
        cell.textLabel.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        UIImageView* cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(-4, 0, 308, 44)];
        cellBackground.tag = kNoticesCellBackgroundTag;
        
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.contentView insertSubview:cellBackground atIndex:0];
        
        UIImageView* emptyCellAccessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardcell_arrow.png"]];
        cell.accessoryView = emptyCellAccessory;
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        [cell.selectedBackgroundView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.04]];
    }
    
    UIImageView* cellBackground = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellBackgroundTag];
    if(indexPath.row == 0 && _data.count == 1)
    {
        //draw single cell
        cellBackground.image = [UIImage imageNamed:@"settings_singlecell.png"];
    }
    else if(indexPath.row == 0)
    {
        cellBackground.image = [UIImage imageNamed:@"settings_topcell.png"];
    }
    else if(indexPath.row == _data.count-1)
    {
        //draw end cell
        cellBackground.image = [UIImage imageNamed:@"settings_bottomcell.png"];
    }
    else
    {
        //draw medium cell
        cellBackground.image = [UIImage imageNamed:@"settings_middlecell.png"];
    }
    
    NSString *key = [_data objectAtIndex:indexPath.row];
    NSArray *entries = [_tripData objectForKey:key];
    
    cell.textLabel.text = [self parseHeaderInfo:entries];
    cell.detailTextLabel.text = [self parseRepeatDays:entries];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_data objectAtIndex:indexPath.row];
    NSArray *entries = [_tripData objectForKey:key];
    
    SettingsManageNotificationsViewController* nvc = [[SettingsManageNotificationsViewController alloc] initWithNibName:@"SettingsManageNotificationsViewController" bundle:nil];
    nvc.transpo = _transpo;
    nvc.language = _language;
    nvc.panGesture = _panGesture;
    nvc.navPanGesture = _navPanGesture;
    nvc.data = [entries mutableCopy];
    
    [self.navigationController pushViewController:nvc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

@end
