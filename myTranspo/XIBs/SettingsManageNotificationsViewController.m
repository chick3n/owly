//
//  SettingsManageNotificationsViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-08.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsManageNotificationsViewController.h"

@interface SettingsManageNotificationsViewController ()
- (void)revealToolbar:(id)sender;
- (void)concealToolbar:(id)sender;
- (void)editTableView:(id)sender;
- (void)doneEditTableView:(id)sender;
- (void)goBack:(id)sender;
@end

@implementation SettingsManageNotificationsViewController

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
    
    _data = [_transpo tripNotifications];
    
    //table view
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    //toolbar
    _removeAllButton.title = NSLocalizedString(@"MTDEF_REMOVEALL", nil);
    _removeSelectedButton.title = NSLocalizedString(@"MTDEF_REMOVESELECTED", nil);
    
    //navigationcontroller
    MTRightButton* editButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [editButton addTarget:self action:@selector(editTableView:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitle:NSLocalizedString(@"MTDEF_EDIT", nil) forState:UIControlStateNormal];
    _editButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
        
        cell.textLabel.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        //cell.backgroundColor = [UIColor colorWithRed:245./255. green:247./255. blue:248./255. alpha:1.0];
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_cell_pattern.png"]];
    }
    
    UILocalNotification* notification = [_data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = notification.alertBody;
    
    NSMutableString* repeat = [NSMutableString string];
    //display notification data properly
    if(notification.repeatInterval == NSWeekdayCalendarUnit)
    {
        int dayOfWeek = [MTHelper DayOfWeekForDate:notification.fireDate];
        switch (dayOfWeek) {
            case 1://sunday
                [repeat appendString:NSLocalizedString(@"MTDEF_SUNDAY", nil)];
                break;
            case 2:
                [repeat appendString:NSLocalizedString(@"MTDEF_MONDAY", nil)];
                break;
            case 3:
                [repeat appendString:NSLocalizedString(@"MTDEF_TUESDAY", nil)];
                break;
            case 4:
                [repeat appendString:NSLocalizedString(@"MTDEF_WEDNESDAY", nil)];
                break;
            case 5:
                [repeat appendString:NSLocalizedString(@"MTDEF_THURSDAY", nil)];
                break;
            case 6:
                [repeat appendString:NSLocalizedString(@"MTDEF_FRIDAY", nil)];
                break;
            case 7:
                [repeat appendString:NSLocalizedString(@"MTDEF_SATURDAY", nil)];
                break;
        }
        
        if(repeat.length > 0)
        {
            [repeat insertString:NSLocalizedString(@"MTDEF_REPEATS", nil) atIndex:0];
        }
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", notification.fireDate.description, repeat];
    
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
    _data = [_transpo tripNotifications];
    
    if(_data.count <= 0)
    {
        _removeSelectedButton.enabled = NO;
        _removeAllButton.enabled = NO;
        [self doneEditTableView:nil];
    }
    
    [_tableView reloadData];
}

- (IBAction)removeSelectedNotificationsClicked:(id)sender
{
    if(_selectedRows.count <= 0)
        return;
    
    NSMutableArray* notifications = [[NSMutableArray alloc] init];
    
    for(NSIndexPath* path in _selectedRows)
    {
        [notifications addObject:[_data objectAtIndex:path.row]];
    }
    
    if([_transpo removeNotifications:notifications])
    {
        _removeSelectedButton.enabled = NO;
        
        _data = nil;
        _data = [_transpo tripNotifications];
        [_tableView reloadData];
        
        if(_data.count <= 0)
        {
            _removeAllButton.enabled = NO;
            [self doneEditTableView:nil];
        }
    }
    
    notifications = nil;
}

#pragma  mark - Navigation bar

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
