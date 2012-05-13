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
    // Return the number of rows in the section.
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
        
        [cell setAccessoryView:time];
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
    
    MTTime* route = [_data objectAtIndex:indexPath.row];
    
    cell.title = route.routeNumber;
    cell.subtitle = route.EndStopHeader;
    cell.type = CELLBUS;
    
    [(UILabel*)[cell.accessoryView viewWithTag:kAccessoryTimeTag] setText:[MTHelper timeRemaingUntilTime:[route getTimeForDisplay]]];
    
    [cell hideBusImage:NO];
    [cell setDisplayAccessoryView:YES];
    [cell update];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

@end
