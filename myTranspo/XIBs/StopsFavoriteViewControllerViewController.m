//
//  StopsFavoriteViewControllerViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-12.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "StopsFavoriteViewControllerViewController.h"

@interface StopsFavoriteViewControllerViewController ()
- (void)updateStopTimes;
- (void)goBack:(id)sender;
- (void)filterList:(id)sender;
- (void)doneFilteringList:(id)sender;
- (void)revealToolBar:(id)sender;
- (void)hideToolBar:(id)sender;
@end

@implementation StopsFavoriteViewControllerViewController
@synthesize data = _data;
@synthesize stop = _stop;

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
    
    if(_data == nil)
        _data = [NSArray array];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_lightbackground_tile.jpg"]];
    
    //toolbar
    CGRect toolBarFrame = _tabBar.frame;
    toolBarFrame.origin.y += toolBarFrame.size.height;
    _tabBar.frame = toolBarFrame; //hide
    _selectAll.title = NSLocalizedString(@"SELECTALL", nil);
    _selectNone.title = NSLocalizedString(@"SELECTNONE", nil);
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setupRefresh:_language];
    [_tableView addPullToRefreshHeader];
    [_tableView setRefreshDelegate:self];
    
    MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];
    [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    MTRightButton *filterButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterList:) forControlEvents:UIControlEventTouchUpInside];
    _filterButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    self.navigationItem.rightBarButtonItem = _filterButton;
    
    MTRightButton *doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneFilteringList:) forControlEvents:UIControlEventTouchUpInside];
    _doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    _transpo.delegate = self;
    
    self.title = [NSString stringWithFormat:@"%d", _stop.StopNumber];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - STOP TIMES

- (void)updateStopTimes
{
    _clearing = NO;
    
    if(_stop == nil)
    {
        [_tableView stopLoading];
        return;
    }
    
    [_transpo updateFavorite:_stop FullUpdate:YES];
}

#pragma mark - MyTranspo Delegate

- (void)myTranspo:(MTResultState)state UpdateType:(MTUpdateType)updateType updatedFavorite:(MTStop*)favorite
{
    [_tableView stopLoading];
    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_clearing)
        return 0;
    else if(_filterMode)
        return (_stop.upcomingBusesHelper == nil) ? 0 : _stop.upcomingBusesHelper.count;
    return (_data.count == 0) ? 1 : [_data count];
}

#define kAccessoryTimeTag 100
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 58, 21)];
        time.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        time.textColor = [UIColor colorWithRed:157./255. green:157./255. blue:157./255. alpha:1.0];
        time.backgroundColor = [UIColor clearColor];
        time.shadowColor = [UIColor whiteColor];
        time.shadowOffset = CGSizeMake(0, 1);
        time.tag = kAccessoryTimeTag;
        
        [cell setMyAccessoryView:time];
    }
    
    if(_data.count == 0)
    {
        cell.title = @"";
        cell.subtitle = NSLocalizedString(@"NOUPCOMINGBUSES", nil);
        cell.type = CELLBUS;
        
        [cell hideBusImage:YES];
        [cell setDisplayAccessoryView:NO];
        [cell update];
        
        return cell;
    }
    else if(_filterMode) //filtering data
    {
        MTStopHelper* helper = [_stop.upcomingBusesHelper objectAtIndex:indexPath.row];
        
        cell.title = helper.routeNumber;
        cell.subtitle = helper.routeHeading;
        cell.type = CELLBUS;
        cell.accessoryView = nil;
        
        if(helper.hideRoute)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.alpha = 0.6;
        }
        else 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.alpha = 1.0;
        }
        
        [cell hideBusImage:NO];
        [cell setDisplayAccessoryView:NO];
        [cell update];
        
        return cell;
    }
    
    MTTime* route = [_data objectAtIndex:indexPath.row];
    
    cell.title = route.routeNumber;
    cell.subtitle = route.EndStopHeader;
    cell.type = CELLBUS;
    if(cell.accessoryView != cell.myAccessoryView)
        cell.accessoryView = cell.myAccessoryView;
    
    [(UILabel*)cell.myAccessoryView setText:[MTHelper timeRemaingUntilTime:[route getTimeForDisplay]]];
    
    [cell hideBusImage:NO];
    [cell setDisplayAccessoryView:YES];
    [cell update];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_filterMode == YES)
    {
        MTStopHelper *helper = [_stop.upcomingBusesHelper objectAtIndex:indexPath.row];
        helper.hideRoute = !helper.hideRoute;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MTTableRefresh Delegate
- (void)refreshTableViewNeedsRefresh
{
    [self updateStopTimes];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

#pragma mark - Filtering

- (void)filterList:(id)sender
{
    NSMutableArray *dataIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *routesIndexPaths = [[NSMutableArray alloc] init];
    for(int x=0; x<_data.count; x++)
        [dataIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
    for(int x=0; x<_stop.upcomingBusesHelper.count; x++)
        [routesIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
    
    [_tableView disableRefresh:YES];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:dataIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    _filterMode = YES;
    [_tableView insertRowsAtIndexPaths:routesIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [_tableView endUpdates];
    
    [self revealToolBar:nil];
    
    self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)doneFilteringList:(id)sender
{
    NSMutableArray *dataIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *routesIndexPaths = [[NSMutableArray alloc] init];
    for(int x=0; x<_stop.upcomingBusesHelper.count; x++)
        [routesIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
    for(int x=0; x<_data.count; x++)
        [dataIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
    
    [_tableView disableRefresh:NO];
    
    //save filter list
    NSMutableArray* filterList = [[NSMutableArray alloc] init];
    for(MTStopHelper* helper in _stop.upcomingBusesHelper)
    {
        if(helper.hideRoute == YES)
            continue;
        
        [filterList addObject:helper.routeNumber];
    }
    
    if(filterList.count != _stop.upcomingBusesHelper.count) //we have hidden something
        [MTSettings favoriteStopFilter:_stop.StopId UpdateWith:filterList];
    else [MTSettings clearFavoriteStopFilter:_stop.StopId]; //clear it if we have it
    
    [self hideToolBar:nil];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:routesIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    _filterMode = NO;
    [_tableView insertRowsAtIndexPaths:dataIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [_tableView endUpdates];

    self.navigationItem.rightBarButtonItem = _filterButton;
    
    _tableView.contentOffset = CGPointMake(0, 0);
    [_tableView startLoadingWithoutDelegate];
    [self performSelector:@selector(updateStopTimes) withObject:nil afterDelay:0.25];
}

#pragma mark - TOOL BAR

- (IBAction)selectAll:(id)sender
{
    for(MTStopHelper *helper in _stop.upcomingBusesHelper)
        helper.hideRoute = NO;
    
    [_tableView reloadData];
}

- (IBAction)selectNone:(id)sender
{
    for(MTStopHelper *helper in _stop.upcomingBusesHelper)
        helper.hideRoute = YES;
    
    [_tableView reloadData];
}

- (void)revealToolBar:(id)sender
{
    CGRect tabBarFrame = _tabBar.frame;
    CGRect tableViewFrame = _tableView.frame;
    
    tabBarFrame.origin.y -= tabBarFrame.size.height;
    tableViewFrame.size.height -= tabBarFrame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _tableView.frame = tableViewFrame;
                         _tabBar.frame = tabBarFrame;
                     }];
}

- (void)hideToolBar:(id)sender
{
    CGRect tabBarFrame = _tabBar.frame;
    CGRect tableViewFrame = _tableView.frame;
    
    tabBarFrame.origin.y += tabBarFrame.size.height;
    tableViewFrame.size.height += tabBarFrame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _tableView.frame = tableViewFrame;
                         _tabBar.frame = tabBarFrame;
                     }];
}

@end
