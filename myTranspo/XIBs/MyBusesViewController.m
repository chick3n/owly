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
- (void)startPoolUpdate:(id)sender;
- (void)stopPoolUpdate:(id)sender;
- (void)poolUpdateTick:(id)sender;
- (void)firstGetFavorites:(id)sender;
- (void)firstUpdateFavorites:(id)sender;
- (void)changeTripScheduleTime:(id)sender;
- (void)didSwipe:(UIGestureRecognizer*)gestureRecognizer;
- (void)expandCells:(id)sender;
@end

@implementation MyBusesViewController
@synthesize tableView                   = _tableView;
@synthesize cellLoader                  = _cellLoader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _editing = NO;
        _fadeInCell = YES;
        _chosenDate = [NSDate date];
        _expandCells = NO;
        _firstLoadComplete = NO;
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
    
    self.title = NSLocalizedString(@"MTDEF_VIEWCONTROLLERMYBUSES", nil);

    //navigationBar Setup
    MTRightButton* editButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [editButton setTitle:NSLocalizedString(@"MTDEF_EDIT", nil) forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editFavorites:) forControlEvents:UIControlEventTouchUpInside];
    _editButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = _editButton;
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(editFavorites:) forControlEvents:UIControlEventTouchUpInside];
    _doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    //setup tableview
    [self.tableView setDelaysContentTouches:YES];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [self.tableView setupRefresh:_language];
    [self.tableView addPullToRefreshHeader];
    [self.tableView setRefreshDelegate:self];
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    gesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:gesture];
    
    //UINib
    _cellLoader = [UINib nibWithNibName:@"MTCardCell" bundle:nil];
    //static NSString *CellIdentifier = @"MTCardCell";    
    //[_tableView registerNib:_cellLoader forCellReuseIdentifier:CellIdentifier];
    
    //date selector
    _dateSelector.minimumDate = _chosenDate;
    _dateSelector.frame = CGRectMake(0, self.view.frame.size.height, _dateSelector.frame.size.width, _dateSelector.frame.size.height);
    //[_dateSelector addTarget:self action:@selector(dateHasChanged:) forControlEvents:UIControlEventValueChanged];
    
    //view
    //[self.view addGestureRecognizer:_panGesture];
    
    _transpo.delegate = self;
    [_tableView startLoadingWithoutDelegate];
    [self performSelector:@selector(firstGetFavorites:) withObject:nil afterDelay:0.5];
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
    //[self.view addGestureRecognizer:_panGesture];
    
#if 0
    if(_favorites == nil)
    {
        [_transpo getFavorites];
    }
    else
    {
        [self updateFavorites];
        [self updateNavigationBar];
    }
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //[self.view removeGestureRecognizer:_panGesture];
    
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
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
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
        //NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTCardCell" owner:self options:nil];
        //cell = [mtCardCellXib objectAtIndex:0];
        cell = [[_cellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
        cell.delegate = self;
        cell.language = _language;
        [cell initializeUI];
    }
    
    MTStop* stop = (MTStop*)[_favorites objectAtIndex:indexPath.row];
    
#if 0
    if(stop.MTCardCellHelper == NO && stop.UpdateCount > 0)
    {
        [cell expandCellWithAnimation:YES];
        stop.MTCardCellHelper = YES;
    }
    else 

    if(stop.UpdateCount > 0)
    {
        [cell expandCellWithAnimation:YES];
        stop.MTCardCellHelper = YES;
    }
#endif    
    //if(stop.IsUpdating == NO) //removed this because IsUpdating = YES until API returns so updates werent happening in between.

    [cell updateCellHeader:stop];
    [cell updateCellDetails:stop New:_fadeInCell];
    [cell setIndexRow:indexPath.row];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#if 0
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
#endif

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = kHiddenHeight;
#if 0
    int height = kFullHeight;

    MTStop* stop = (MTStop*)[_favorites objectAtIndex:indexPath.row];
    if(stop.UpdateCount == 0)
        height = kHiddenHeight;
#endif
    if(_expandCells)
        height = kFullHeight;
    
    return height;
}
                                              
- (void)editFavorites:(id)sender
{
    _editing = !_editing;
    
    if(_editing)
    {
        [_tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    else
    {
        [_tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = _editButton;
        //[self.view addGestureRecognizer:_panGesture];
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
        _chosenDate = [NSDate date]; //always update to now
        stop.IsUpdating = YES;
        stop.cancelQueue = NO;
        [stop restoreQueuesForBuses];
        [_transpo updateFavoriteData:stop ForDate:_chosenDate];
    }
}

- (void)firstGetFavorites:(id)sender
{
    [_transpo getFavorites];
}

- (void)firstUpdateFavorites:(id)sender
{
    [_transpo updateAllFavorites:_favorites];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!tableView.editing && !_editing)
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
    else {
        if(_editedCell != nil && _editedCell.row < _favorites.count)
        {
            MTCardCell* cell = (MTCardCell*)[tableView cellForRowAtIndexPath:_editedCell];
            [cell setEditing:NO animated:YES];
        }
        _editing = NO;
    }
}

- (void)expandCells:(id)sender
{
    _expandCells = YES;
    [_tableView beginUpdates];
    [_tableView endUpdates];
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
                                  withRowAnimation:UITableViewRowAnimationLeft];
                
                break;
            }
        }
    }
    else
    {
        MTLog(@"Failed to remove Favorite...");
        [_tableView reloadData];
    }
    
    //
    
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
            [self firstUpdateFavorites:nil];
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
    if(state == MTRESULTSTATE_DONE)
    {
        [self refreshTableStopLoading];
        [self performSelector:@selector(expandCells:) withObject:nil afterDelay:0.25];
        return;
    }

    if(favorite != nil)
    {
        [favorite.Bus updateDisplayObjects];
    }

    int index = [_favorites indexOfObject:favorite];
    
    if(index >= 0)
    {
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
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

- (void)mtCardcellDeleteClicked:(id)cell
{
    MTCardCell* c = (MTCardCell*)cell;
    
    int row = [_favorites indexOfObject:c.stop];
    if(row == NSNotFound)
        return;

    [_transpo removeFavorite:c.stop WithBus:c.stop.Bus];
}

#pragma mark - MTRefreshTableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(_editing)
    {
        if(_editedCell != nil && _editedCell.row < _favorites.count)
        {
            MTCardCell* cell = (MTCardCell*)[_tableView cellForRowAtIndexPath:_editedCell];
            [cell setEditing:NO animated:YES];
        }
        else {
            [_tableView reloadData];
        }
        _editing = NO;
    }
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
    if(_tableView.editing)
    {
        [_tableView stopLoading];
        return;
    }
    
    _fadeInCell = YES;
    _loadingCounter = _favorites.count;
    [self updateFavorites];
}

- (void)refreshTableStopLoading
{
    [_tableView stopLoading];
    _fadeInCell = NO;
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

#pragma mark - Pool Update

- (void)startPoolUpdate:(id)sender
{
    if(_poolUpdates != nil && [_poolUpdates isValid])
    {
        MTLog(@"Pool already Running!");
        return;
    }
    
    
    _poolUpdates = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(poolUpdateTick:) userInfo:nil repeats:YES];
}

- (void)stopPoolUpdate:(id)sender
{
    if(_poolUpdates != nil)
    {
        [_poolUpdates invalidate];
        _poolUpdates = nil;
    }
}

- (void)poolUpdateTick:(id)sender
{
#if 0
    BOOL update = YES;
    for(MTStop* fav in _favorites)
    {
        if(fav.MTCardCellIsAnimating == YES)
        {
            update = NO;
            break;
        }
    }
    
    if(update)
    {
        [_tableView reloadData];
        [self stopPoolUpdate:nil];
        MTLog(@"Reloading Pool Update");
    }
    else
    {
        MTLog(@"Adding Another Pool Update");
        [self stopPoolUpdate:nil];
        [self startPoolUpdate:nil]; //try again
    }    
#endif

    BOOL hasUpdated = YES;
    NSArray* visibleCells = [_tableView visibleCells];
    
    for(MTCardCell* cell in visibleCells)
    {
        if(!cell.hasExpanded)
            hasUpdated = NO;
    }
    
    if(hasUpdated)
    {
        [_tableView reloadData];
        [self stopPoolUpdate:nil];
        _firstLoadComplete = YES;
        MTLog(@"Reloading pool update.");
    }
    else {
        MTLog(@"Restarting Pool");
    }
}

#pragma mark - Date Pickerview Delegate

- (void)dateHasChanged:(id)sender
{
    [self optionsDate:nil dateHasChanged:_dateSelector.date];
}

- (void)changeTripScheduleTime:(id)sender
{
    if(_tableView.isEditing)
        return;
    
    CGRect datePickerFrame = _dateSelector.frame;
    
    if(datePickerFrame.origin.y == self.view.frame.size.height)
    {
        UIView *fadedView = [[UIView alloc] initWithFrame:self.view.frame];
        fadedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        fadedView.tag = 20123;
        [self.view insertSubview:fadedView belowSubview:_dateSelector];
        
        datePickerFrame.origin.y -= _dateSelector.frame.size.height;
        _tableView.userInteractionEnabled = NO;
    }
    else
    {
        UIView* fadedView = [self.view viewWithTag:20123];
        if(fadedView != nil)
            [fadedView removeFromSuperview];
        datePickerFrame.origin.y = self.view.frame.size.height;
        _tableView.userInteractionEnabled = YES;
        
        if(_dateSelector.date != _chosenDate)
            [self dateHasChanged:_dateSelector];
    }
    
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _dateSelector.frame = datePickerFrame;
                     }];
    
#if 0
    [_menuControl revealOptions:nil];
#endif
}

#pragma mark - SWIPES

- (void)didSwipe:(UIGestureRecognizer*)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath* swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        if(swipedIndexPath != nil)
        {
            //refresh individual cell
            if(swipedIndexPath.row < _favorites.count)
            {
                MTStop* stop = (MTStop*)[_favorites objectAtIndex:swipedIndexPath.row];
                MTLog(@"REFRESH CELL: %@", stop.Bus.DisplayHeading);
            }
        }
    }
}

@end
