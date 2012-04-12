//
//  MyBusesViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MyBusesViewController.h"

@interface MyBusesViewController ()
- (void)editFavorites:(id)sender;
- (void)updateFavorites;
- (void)refreshTableStopLoading;
- (void)updateNavigationBar;
@end

@implementation MyBusesViewController
@synthesize tableView                   = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _editing = NO;
        _chosenDate = [NSDate date];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [self cancelQueues];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigationBar Setup
    _editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MTDEF_EDIT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editFavorites:)];
        
    self.navigationItem.rightBarButtonItem = _editButton;
    self.title = NSLocalizedString(@"MTDEF_VIEWCONTROLLERMYBUSES", nil);
    //[self.navigationController.navigationBar addGestureRecognizer:_navPanGesture];
    
    //setup tableview
    [self.tableView setDelaysContentTouches:NO];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [self.tableView setupRefresh:_language];
    [self.tableView addPullToRefreshHeader];
    [self.tableView setRefreshDelegate:self];
    
    //view
    //[self.view addGestureRecognizer:_panGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self cancelQueues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _transpo.delegate = self;
    [self.view addGestureRecognizer:_panGesture];
    
    if(_favorites == nil)
    {
        [_transpo getFavorites];
    }
    else
    {
        [self updateFavorites];
        [self updateNavigationBar];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.view removeGestureRecognizer:_panGesture];
    
    if(_editing)
    {
        [self editFavorites:nil];
    }
    
    [self cancelQueues];
    //_favorites = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateNavigationBar
{
    if(_favorites == nil)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if(_favorites.count <= 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = _editButton;
    }
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
    return (_favorites == nil) ? 0 : _favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    MTCardCell *cell = (MTCardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[MTCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier WithLanguage:_language];
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTCardCell" owner:self options:nil];
        cell = [mtCardCellXib objectAtIndex:0];
        cell.delegate = self;
        cell.language = _language;
        [cell initializeUI];
    }
    
    MTStop* stop = (MTStop*)[_favorites objectAtIndex:indexPath.row];
    
    if(stop.MTCardCellHelper == NO && stop.UpdateCount > 0)
    {
        [cell expandCellWithAnimation:YES];
        stop.MTCardCellHelper = YES;
    }
    else if(stop.UpdateCount > 0)
    {
        [cell expandCellWithAnimation:NO];
    }
    
    if(stop.IsUpdating == NO)
        [cell updateCellDetails:stop New:YES];
    
    [cell updateCellHeader:stop];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        MTStop* favorite = [_favorites objectAtIndex:indexPath.row];
        if(favorite == nil)
            return;
        
        [_transpo removeFavorite:favorite WithBus:favorite.Bus];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = kFullHeight;
    
    MTStop* stop = (MTStop*)[_favorites objectAtIndex:indexPath.row];
    if(stop.UpdateCount == 0)
        height = kHiddenHeight;
    
    return height;
}
                                              
- (void)editFavorites:(id)sender
{
    _editing = !_editing;
    
    if(_editing)
    {
        [_tableView setEditing:YES];
        _editButton.title = NSLocalizedString(@"MTDEF_DONE", nil);
        _editButton.style = UIBarButtonItemStyleDone;
    }
    else
    {
        [_tableView setEditing:NO];
        _editButton.title = NSLocalizedString(@"MTDEF_EDIT", nil);
        _editButton.style = UIBarButtonItemStylePlain;
    }
}

- (void)updateFavorites
{
    if(_favorites == nil)
    {
        [self refreshTableStopLoading];
        return;
    }
    
    if(_favorites.count <= 0)
    {
        [self refreshTableStopLoading];
        return;
    }
    
    for(MTStop* stop in _favorites)
    {
        stop.IsUpdating = YES;
        stop.cancelQueue = NO;
        [stop restoreQueuesForBuses];
        [_transpo updateFavoriteData:stop ForDate:_chosenDate];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTStop* stop = [_favorites objectAtIndex:indexPath.row];
    
    TripViewController* tvc = [[TripViewController alloc] initWithNibName:@"TripViewController" bundle:nil];
    tvc.transpo = _transpo;
    tvc.language = _language;
    tvc.stop = stop;
    tvc.bus = stop.Bus;
    tvc.chosenDate = _chosenDate;
    tvc.panGesture = _panGesture;
    tvc.futureTrip = ![MTHelper IsDateToday:_chosenDate];
    
    //[tvc.view addGestureRecognizer:_panGesture];
    //[tvc.navigationController.navigationBar addGestureRecognizer:_panGesture];
    
    [self.navigationController pushViewController:tvc animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Favorites Delegate

- (void)myTranspo:(MTResultState)state removedFavorite:(MTStop *)favorite WithBus:(MTBus *)bus
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        for(int x=0; x<_favorites.count; x++)
        {
            MTStop* stop = [_favorites objectAtIndex:x];
            
            if(stop == favorite)
            {
                [_favorites removeObjectAtIndex:x];
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:x inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
    else
    {
        MTLog(@"Failed to remove Favorite...");
    }
    
    [self updateNavigationBar];
}

- (void)myTranspo:(MTResultState)state receivedFavorites:(NSMutableArray*)favorites
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        if(favorites != nil)
        {
            _favorites = favorites;
            [_tableView reloadData];
            
            [self performSelector:@selector(updateFavorites) withObject:nil afterDelay:0.2];
        }
    }
    else
    {
        MTLog(@"Failed to get Favorites...");
    }
    
    [self updateNavigationBar];
}

- (void)myTranspo:(MTResultState)state addedFavorite:(MTStop*)favorite
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [_favorites addObject:favorite];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_favorites.count inSection:0]]
                          withRowAnimation:UITableViewRowAnimationBottom];
    }
    else
    {
        MTLog(@"Failed to add Favorite...");
    }
    
    [self updateNavigationBar];
}

- (void)myTranspo:(MTResultState)state UpdateType:(MTUpdateType)updateType updatedFavorite:(MTStop*)favorite
{
    if(state == MTRESULTSTATE_FAILED)
    {
        MTLog(@"Failed to update Favorite...");//if failed still ahve to stop the loading!
    }

    for(int x=0; x<_favorites.count; x++)
    {
        MTStop* stop = [_favorites objectAtIndex:x];
        
        if(stop == favorite)
        {
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:x inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
    
    _loadingCounter -= 1;
    
    if(_loadingCounter <= 0)
    {
        [self refreshTableStopLoading];
    }
}

#pragma mark - QUEUE SAFE

- (void)cancelQueues
{
    if(_favorites == nil)
        return;
    
    for(MTStop* stop in _favorites)
    {
        stop.cancelQueue = YES;
        [stop cancelQueuesForBuses];
    }
}

#pragma mark - MTCardCell Delegate

- (void)mtCardCellnextTimeClickedForStop:(MTStop*)stop
{
    //do nothing now
}

#pragma mark - MTRefreshTableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

//ToDo: not very reliable, might be better to play it safe and do _favorites.count/2
- (void)refreshTableViewNeedsRefresh
{
    _loadingCounter = _favorites.count;
    [self updateFavorites];
}

- (void)refreshTableStopLoading
{
    [_tableView stopLoading];
}
     
#pragma mark - OPTIONS DELEGATE

- (void)optionsDate:(id)options dateHasChanged:(NSDate *)newDate
{
    //do something
    _chosenDate = newDate;

    for(MTStop* stop in _favorites)
    {
        MTBus* bus = stop.Bus;
        
        [bus clearLiveTimes];
        [bus.Times clearTimes];
        bus.Times.TimesAdded = NO;
        bus.chosenDate = _chosenDate;
    }
    
    [_tableView automaticallyStartLoading:YES];
}

@end
