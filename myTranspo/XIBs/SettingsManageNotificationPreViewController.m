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
- (NSString*)parseBusNumber:(NSArray*)notifications;
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
    [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)]];
    
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

- (NSString*)parseBusNumber:(NSArray*)notifications
{
    if(notifications == nil)
        return @"";
    
    if(notifications.count == 0)
        return @"";
    
    UILocalNotification *notification = [notifications objectAtIndex:0];
    NSDictionary *userInfo = notification.userInfo;
    
    return (NSString*)[userInfo valueForKey:kMTNotificationBusNumberKey];
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
            , [userInfo valueForKey:kMTNotificationBusDisplayHeading]
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

#define kNoticesCellImageTag 101
#define kNoticesCellTitleTag 102
#define kNoticesCellSubTitleTag 103
#define kNoticesCellBackgroundTag 104
#define kAlertsCellBusNumberTag 105
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.hidden = YES;
        
        UILabel* cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 200, 20)];
        cellTitle.tag = kNoticesCellTitleTag;
        cellTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cellTitle.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cellTitle.backgroundColor = [UIColor clearColor];
        cellTitle.shadowColor = [UIColor whiteColor];
        cellTitle.shadowOffset = CGSizeMake(0, 1);
        
        UILabel* cellSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 38, 200, 16)];
        cellSubTitle.tag = kNoticesCellSubTitleTag;
        cellSubTitle.backgroundColor = [UIColor clearColor];
        cellSubTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        cellSubTitle.textColor = [UIColor colorWithRed:140./255. green:139./255. blue:139./255. alpha:1.0];
        cellSubTitle.shadowColor = [UIColor whiteColor];
        cellSubTitle.shadowOffset = CGSizeMake(0, 1);
        
        UIImageView* cellIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 52, 52)];
        cellIcon.contentMode = UIViewContentModeCenter;
        cellIcon.image = [UIImage imageNamed:@"cardcell_busnumber_background.png"];
        cellIcon.tag = kNoticesCellImageTag;
        
        UILabel* cellBusNumber = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 42, 47)];
        cellBusNumber.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
        cellBusNumber.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.10];
        cellBusNumber.shadowOffset = CGSizeMake(0, 1);
        cellBusNumber.textColor = [UIColor whiteColor];
        cellBusNumber.textAlignment = UITextAlignmentCenter;
        cellBusNumber.backgroundColor = [UIColor clearColor];
        cellBusNumber.tag = kAlertsCellBusNumberTag;
        
        UIImageView* cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(6, 0, 308, 72)];
        cellBackground.tag = kNoticesCellBackgroundTag;
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cell.contentView addSubview:cellBackground];
        [cell.contentView addSubview:cellTitle];
        [cell.contentView addSubview:cellSubTitle];
        [cell.contentView addSubview:cellIcon];
        [cell.contentView addSubview:cellBusNumber];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView* cellBackground = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellBackgroundTag];
    if(indexPath.row == 0 && _data.count == 1)
    {
        //draw single cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_single.png"];
    }
    else if(indexPath.row == 0)
    {
        cellBackground.image = [UIImage imageNamed:@"notice_cell_top.png"];
    }
    else if(indexPath.row == _data.count-1)
    {
        //draw end cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_bottom.png"];
    }
    else
    {
        //draw medium cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_middle.png"];
    }
    
    NSString *key = [_data objectAtIndex:indexPath.row];
    NSArray *entries = [_tripData objectForKey:key];
        
    UILabel *title = (UILabel*)[cell.contentView viewWithTag:kNoticesCellTitleTag];
    UILabel *subtitle = (UILabel*)[cell.contentView viewWithTag:kNoticesCellSubTitleTag];
    UILabel *busNumber = (UILabel*)[cell.contentView viewWithTag:kAlertsCellBusNumberTag];
    
    busNumber.text = [self parseBusNumber:entries];
    title.text = [self parseHeaderInfo:entries];
    subtitle.text = [self parseRepeatDays:entries];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && _data.count == 1)
        return 81;
    else if(indexPath.row == _data.count - 1)
        return kAlertsCellHeight - (81 - kAlertsCellHeight);
    return kAlertsCellHeight;
}

@end
