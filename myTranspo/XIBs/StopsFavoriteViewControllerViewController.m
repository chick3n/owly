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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_lightbackground_tile.jpg"]];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setupRefresh:_language];
    [_tableView addPullToRefreshHeader];
    [_tableView setRefreshDelegate:self];
    
    _transpo.delegate = self;
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
    return (_data != nil) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_data count];
}

#define kAccessoryTimeTag 100
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(262, 11, 48, 21)];
        time.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        time.textColor = [UIColor colorWithRed:157./255. green:157./255. blue:157./255. alpha:1.0];
        time.backgroundColor = [UIColor clearColor];
        time.shadowColor = [UIColor whiteColor];
        time.shadowOffset = CGSizeMake(0, 1);
        time.tag = kAccessoryTimeTag;
        
        [cell setAccessoryView:time];
    }
    
    MTTime* route = [_data objectAtIndex:indexPath.row];
    
    cell.title = route.routeNumber;
    cell.subtitle = route.EndStopHeader;
    cell.type = CELLBUS;
    
    [(UILabel*)[cell.accessoryView viewWithTag:kAccessoryTimeTag] setText:[route getTimeForDisplay]];
    
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
