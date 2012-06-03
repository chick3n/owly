//
//  SettingsManageNotificationsViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-08.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

//ToDo: join all into one cell for each one and later we will add more functionallity to only delete a per day basis.

#import "SettingsManageNotificationsViewController.h"

@interface SettingsManageNotificationsViewController ()
- (void)revealToolbar:(id)sender;
- (void)concealToolbar:(id)sender;
- (void)editTableView:(id)sender;
- (void)doneEditTableView:(id)sender;
- (void)goBack:(id)sender;
@end

@implementation SettingsManageNotificationsViewController
@synthesize sortNotifications           = _sortNotifications;
@synthesize data                        = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedRows = [[NSMutableArray alloc] init];
        
        MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];        
        [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
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
    
    _sortNotifications = ^NSComparisonResult(id obj1, id obj2) {
        UILocalNotification* alert1 = obj1, *alert2 = obj2;
        NSString *stop1 = [alert1.userInfo valueForKey:kMTNotificationTripTimeKey];
        NSString *stop2 = [alert2.userInfo valueForKey:kMTNotificationTripTimeKey];
        
        return [stop1 compare:stop2];
    };
    
    //table view
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    _tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_darkbackground_tile.jpg"]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    //toolbar
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"global_options_bar.jpg"]
             forToolbarPosition:UIToolbarPositionBottom
                     barMetrics:UIBarMetricsDefault];
    
    MTRightButton* removeAll = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [removeAll setTitle:NSLocalizedString(@"MTDEF_REMOVEALL", nil) forState:UIControlStateNormal];
    [removeAll addTarget:self action:@selector(removeAllNotificationsClicked:) forControlEvents:UIControlEventTouchUpInside];
    CGRect removeFrame = removeAll.frame;
    removeFrame.size.width = 100;
    removeAll.frame = removeFrame;
    _removeAllButton = [[UIBarButtonItem alloc] initWithCustomView:removeAll];
    
    MTRightButton* removeSelected = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [removeSelected setTitle:NSLocalizedString(@"MTDEF_REMOVESELECTED", nil) forState:UIControlStateNormal];
    [removeSelected addTarget:self action:@selector(removeSelectedNotificationsClicked:) forControlEvents:UIControlEventTouchUpInside];
    removeFrame.size.width = 120;
    removeSelected.frame = removeFrame;
    _removeSelectedButton = [[UIBarButtonItem alloc] initWithCustomView:removeSelected];
    
    [_toolBar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                        , _removeSelectedButton
                        , nil]];
    
    //navigationcontroller
    MTRightButton* editButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [editButton addTarget:self action:@selector(editTableView:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitle:NSLocalizedString(@"MTDEF_EDIT", nil) forState:UIControlStateNormal];
    _editButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [doneButton addTarget:self action:@selector(doneEditTableView:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    _doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    if(_data.count > 0)
        self.navigationItem.rightBarButtonItem = _editButton;
    
    //view
   // [self.view addGestureRecognizer:_panGesture];
    self.title = NSLocalizedString(@"MTDEF_NOTIFICATIONS", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _tableView = nil;
    _toolBar = nil;
    _removeAllButton = nil;
    _data = nil;
    _selectedRows = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self concealToolbar:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.view removeGestureRecognizer:_panGesture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        UIImageView* cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(-4, 0, 308, 44)];
        cellBackground.tag = kNoticesCellBackgroundTag;
        
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.contentView insertSubview:cellBackground atIndex:0];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
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
    
    UILocalNotification* notification = [_data objectAtIndex:indexPath.row];
    MTLog(@"%@", notification.fireDate);
    
    NSString *title = @"";
    //display notification data properly
    if(notification.repeatInterval == NSWeekCalendarUnit)
    {
        int dayOfWeek = [MTHelper DayOfWeekForDate:notification.fireDate];
        switch (dayOfWeek) {
            case 1://sunday
                title = NSLocalizedString(@"MTDEF_SUNDAY", nil);
                break;
            case 2:
                title = NSLocalizedString(@"MTDEF_MONDAY", nil);
                break;
            case 3:
                title = NSLocalizedString(@"MTDEF_TUESDAY", nil);
                break;
            case 4:
                title = NSLocalizedString(@"MTDEF_WEDNESDAY", nil);
                break;
            case 5:
                title = NSLocalizedString(@"MTDEF_THURSDAY", nil);
                break;
            case 6:
                title = NSLocalizedString(@"MTDEF_FRIDAY", nil);
                break;
            case 7:
                title = NSLocalizedString(@"MTDEF_SATURDAY", nil);
                break;
        }
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView.editing)
    {
        [_selectedRows addObject:indexPath];
        if(_removeSelectedButton.enabled == NO)
            _removeSelectedButton.enabled = YES;
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];   
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView.editing)
    {
        [_selectedRows removeObject:indexPath];
        if([_selectedRows count] <= 0)
            _removeSelectedButton.enabled = NO;
    }
}

- (void)editTableView:(id)sender
{
    [_selectedRows removeAllObjects];
    _removeSelectedButton.enabled = NO;
    _removeAllButton.enabled = NO;
    if(_data.count > 0)
        _removeAllButton.enabled = YES;
    
    [self revealToolbar:nil];
    
    [_tableView setEditing:YES];
    
    self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)doneEditTableView:(id)sender
{
    [_selectedRows removeAllObjects];
    _removeSelectedButton.enabled = NO;
    _removeAllButton.enabled = NO;
    
    [self concealToolbar:nil];
    
    [_tableView setEditing:NO];
    
    if(_data.count > 0)
        self.navigationItem.rightBarButtonItem = _editButton;
    else self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Toolbar

- (void)revealToolbar:(id)sender
{
    CGRect newToolbarFrame = _toolBar.frame;
    newToolbarFrame.origin.y -= _toolBar.frame.size.height;
    
    CGRect newTableViewFrame = _tableView.frame;
    newTableViewFrame.size.height -= _toolBar.frame.size.height;
    
    _toolBar.hidden = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         _toolBar.frame = newToolbarFrame;
                         _tableView.frame = newTableViewFrame;
                     }];
}

- (void)concealToolbar:(id)sender
{
    CGRect newToolbarFrame = _toolBar.frame;
    newToolbarFrame.origin.y += _toolBar.frame.size.height;
    CGRect newTableViewFrame = _tableView.frame;
    newTableViewFrame.size.height += _toolBar.frame.size.height;

    [UIView animateWithDuration:0.25
                     animations:^(void){
                         _toolBar.frame = newToolbarFrame;
                         _tableView.frame = newTableViewFrame;
                     }
                     completion:^(BOOL finished){
                         _toolBar.hidden = YES;
                     }];
}

- (IBAction)removeAllNotificationsClicked:(id)sender
{
    [_transpo removeAllTripNotifications];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)removeSelectedNotificationsClicked:(id)sender
{
    if(_selectedRows.count <= 0)
        return;
    
    NSMutableArray* notifications = [[NSMutableArray alloc] init];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    for(NSIndexPath* path in _selectedRows)
    {
        [notifications addObject:[_data objectAtIndex:path.row]];
        [indexes addIndex:path.row];
    }
    
    if([_transpo removeNotifications:notifications])
    {
        _removeSelectedButton.enabled = NO;
        
        [_data removeObjectsAtIndexes:indexes];
        [_tableView reloadData];
        
        if(_data.count <= 0)
        {
            _removeAllButton.enabled = NO;
            [self doneEditTableView:nil];
        }
    }
    
    notifications = nil;
    indexes = nil;
}

#pragma  mark - Navigation bar

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SORT

- (void)sortNotifications:(NSComparisonResult (^)(id, id))block
{
    
}

@end
