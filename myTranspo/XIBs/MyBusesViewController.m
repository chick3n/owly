//
//  MyBuses2ViewController.m
//  myTranspo
//
//  Created by Lion User on 09/05/2012.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MyBusesViewController.h"

@interface MyBusesViewController()
- (void)generateFavorites:(NSArray*)listOfFavorites WithUpdate:(BOOL)update;
- (void)updateAllFavorites;
- (void)updateFavorite:(CardCellManager*)cellManager;
- (int)findCellManagerForStop:(MTStop*)stop;
- (void)editFavorites:(id)sender;
- (void)doneEditingFavorites:(id)sender;
- (void)didSwipe:(UIGestureRecognizer*)gestureRecognizer;
- (void)singleCellTapOveride:(UIGestureRecognizer*)gestureRecognizer;
- (void)doneUpdatingFavorites;
- (void)updateNavigationController;
@end

@implementation MyBusesViewController
@synthesize cellLoader  =               _cellLoader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _updateInProgress = NO;
        _updateCount = 0;
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
    
    self.title = NSLocalizedString(@"MTDEF_VIEWCONTROLLERMYBUSES", nil);
    
    //UINib
    _cellLoader = [UINib nibWithNibName:@"MTCardCell" bundle:nil];
    
    //navigationBar Setup
    MTRightButton* editButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [editButton setTitle:NSLocalizedString(@"MTDEF_EDIT", nil) forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editFavorites:) forControlEvents:UIControlEventTouchUpInside];
    _editButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = _editButton;
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneEditingFavorites:) forControlEvents:UIControlEventTouchUpInside];
    _doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    //tableView
    [_tableView setDelaysContentTouches:YES];
    //[_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_darkbackground_tile.jpg"]];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setupRefresh:_language];
    [_tableView addPullToRefreshHeader];
    [_tableView setRefreshDelegate:self];
    [_tableView setRefreshExtendedDurationText:NSLocalizedString(@"EXTENDEDLOADING", nil)];
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    gesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [_tableView addGestureRecognizer:gesture];
    
    //single cell edit override
    _editingSingleCellOverideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapOveride:)];
    
    _transpo.delegate = self;
    _updateInProgress = YES;
    [_transpo getFavorites];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
    [self cancelQueues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _transpo.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelQueues];
}

- (void)cancelQueues
{
    if(_favorites == nil)
        return;
    
    for(CardCellManager* cellManager in _favorites)
    {
        if(cellManager.stop != nil)
        {
            [cellManager.stop cancelQueuesForBuses];
            [cellManager.stop setCancelQueue:YES];
        }
    }
}

- (void)dealloc
{
    [self cancelQueues];
}

#pragma mark - Generic View 

- (void)updateNavigationController
{
    UIBarButtonItem* currentButton = self.navigationItem.rightBarButtonItem;
    
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
        self.navigationItem.rightBarButtonItem = currentButton;
    }
}

#pragma mark - My Transpo Delegate

- (void)myTranspo:(MTResultState)state receivedFavorites:(NSMutableArray*)favorites
{
    [_tableView setEmptyTableText:NSLocalizedString(@"EMPTYTABLEFORFAVORITES", nil)];
    
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [_tableView startLoadingWithoutDelegate]; //show loading on first view
        [self generateFavorites:favorites WithUpdate:YES];
        [_tableView reloadData]; //add all cells to page  
        [self performSelector:@selector(updateAllFavorites) withObject:nil afterDelay:0.25];
    }
    else
    {
        MTLog(@"Failed to get Favorites...");
        [self doneUpdatingFavorites];
    }
    
    [self updateNavigationController];
    
}

- (void)myTranspo:(MTResultState)state UpdateType:(MTUpdateType)updateType updatedFavorite:(MTStop*)favorite
{
    if(state == MTRESULTSTATE_DONE)
    {
        int index = [self findCellManagerForStop:favorite];
        if(index>-1)
        {
            CardCellManager* cellManager = [_favorites objectAtIndex:index];
            
            cellManager.state = CCM_FULL;
            cellManager.status = CMS_IDLE;
            cellManager.individualUpdate = NO;
            [cellManager updateDisplayObjects];
            
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        }
        
        _updateCount -= 1;
    }
    
    if(_updateCount <= 0)
    {
        [self doneUpdatingFavorites];
    }
}

- (void)myTranspo:(MTResultState)state removedFavorite:(MTStop *)favorite WithBus:(MTBus *)bus
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        int x = [self findCellManagerForStop:favorite];
        if(x >= 0)
        {            
            [_favorites removeObjectAtIndex:x];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:x inSection:0]]
                              withRowAnimation:UITableViewRowAnimationLeft];
            
            [self singleCellTapOveride:nil];
        }
    }
    else
    {
        MTLog(@"Failed to remove Favorite...");
        [_tableView reloadData];
    }
    
    [self updateNavigationController];
}

#pragma mark - Managing Favorites

- (void)generateFavorites:(NSArray *)listOfFavorites WithUpdate:(BOOL)update
{
    if(listOfFavorites == nil)
        return;
    
    if(_favorites == nil)
        _favorites = [[NSMutableArray alloc] initWithCapacity:listOfFavorites.count];
    
    for(int x=0; x<listOfFavorites.count; x++)
    {
        MTStop *favorite = (MTStop*)[listOfFavorites objectAtIndex:x];
        
        CardCellManager* cardCellManager = [[CardCellManager alloc] init];
        cardCellManager.stop = favorite;
        [cardCellManager updateDisplayObjects]; //sets state = full, reset it back to empty as we havent called a real update
        cardCellManager.state = CCM_EMPTY;
        //cardCellManager.status = (update == NO) ? CMS_IDLE : CMS_UPDATING; //will next call be an update
        cardCellManager.status = CMS_IDLE;
        
        [_favorites addObject:cardCellManager];
    }
}

- (void)updateAllFavorites
{
    for(int x=0; x<_favorites.count; x++)
    {
        CardCellManager *cellManager = [_favorites objectAtIndex:x];
        [self updateFavorite:cellManager];
    }
    
    if(_updateCount <= 0)
    {
        [self doneUpdatingFavorites];
    }
}

- (void)updateFavorite:(CardCellManager *)cellManager
{
    if(cellManager == nil)
        return;
    
    if(cellManager.stop == nil)
        return;
    
    if(cellManager.stop.isUpdating)
        return;
    
    if(cellManager.status == CMS_UPDATING)
        return; //already updating this one
    
    cellManager.status = CMS_UPDATING;
    if([_transpo updateFavorite:cellManager.stop FullUpdate:NO])
        _updateCount += 1;
    else cellManager.status = CMS_IDLE;
}

- (void)doneUpdatingFavorites
{
    _updateCount = 0;
    _updateInProgress = NO;
    [_tableView stopLoading];
}

- (int)findCellManagerForStop:(MTStop*)stop
{
    for(int x=0; x<_favorites.count; x++)
    {
        CardCellManager* cellManager = [_favorites objectAtIndex:x];
        if(cellManager.stop == stop)
            return x;
    }
    
    return -1;
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_favorites == nil)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _favorites.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardCellManager* cellManager = [_favorites objectAtIndex:indexPath.row];
    
    if(cellManager.state == CCM_EMPTY)
        return kHiddenHeight;
    
    return kFullHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    MTCardCell *cell = (MTCardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[_cellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
        cell.language = _language;
        cell.delegate = self;
        [cell initializeUI];
    }
    
    CardCellManager* cellManager = [_favorites objectAtIndex:indexPath.row];
    
    [cell updateCellBusNumber:cellManager.busNumber 
         AndBusDisplayHeading:cellManager.busHeadingDisplay 
           AndStopStreentName:cellManager.stopStreetName];
    
    if(cellManager.state == CCM_FULL)
    {
        [cell updateCellPrevTime:cellManager.prevTime
                     AndDistance:cellManager.distance
                    AndDirection:cellManager.heading
                     AndNextTime:cellManager.nextTime
                    AndNextTimes:cellManager.additionalNextTimes
                        AndSpeed:cellManager.busSpeed];
        
        if(cellManager.status == CMS_NEWUPDATE && cellManager.state != CCM_EMPTY)
        {
            [cell updateCellDetailsWithFlash];
            cellManager.status = CMS_IDLE;
        }
        
        if(cell.hasExpanded == NO && cell.isExpanding == NO)
            [cell updateCellDetailsAnimation:!cellManager.hasAnimated];
        
        cellManager.hasAnimated = YES;
        
        [cell updateCellForIndividualUpdate:cellManager.individualUpdate];
    }
    
    if(cellManager.status != CMS_UPDATING)
        [cell toggleLoadingAnimation:NO];
    else [cell toggleLoadingAnimation:YES];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.editing)
    {
        return;
    }
    else if(_editedIndividualCell != nil)
    {
        [self singleCellTapOveride:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TableView Editing & Refreshing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)editFavorites:(id)sender
{
    if(_updateInProgress)
        return;
    
    [_tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)doneEditingFavorites:(id)sender
{
    if(_editedIndividualCell != nil)
    {
        [_tableView setUserInteractionEnabled:YES];
        [self.view removeGestureRecognizer:_editingSingleCellOverideTap];
        [_editedIndividualCell setEditing:NO animated:YES];
        _editedIndividualCell = nil;
    }
    [_tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = _editButton;
}

- (void)singleCellTapOveride:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer != nil)
    {
        //determine if button was clicked and send its action
        UIView* view = gestureRecognizer.view;
        UIView* clickedView = [view hitTest:[gestureRecognizer locationInView:view] withEvent:nil];
        if(clickedView)
        {
            if([clickedView class] == [UIButton class])
            {
                [(UIButton*)clickedView sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    if(_editedIndividualCell != nil)
        [self doneEditingFavorites:nil];
    else {
        [_tableView setUserInteractionEnabled:YES];
        [self.view removeGestureRecognizer:_editingSingleCellOverideTap];
    }
}

- (void)didSwipe:(UIGestureRecognizer*)gestureRecognizer
{
    if(_updateInProgress)
        return;
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint swipeLocation = [gestureRecognizer locationInView:_tableView];
        NSIndexPath* swipedIndexPath = [_tableView indexPathForRowAtPoint:swipeLocation];
        if(swipedIndexPath != nil)
        {
            //refresh individual cell
            if(swipedIndexPath.row < _favorites.count)
            {
                MTCardCell* cell = (MTCardCell*)[_tableView cellForRowAtIndexPath:swipedIndexPath];
                
                if(cell)
                {
                    if(_editedIndividualCell == cell) //same cell so just remove it
                    {
                        [self singleCellTapOveride:nil];
                        return;
                    }
                    else if(_editedIndividualCell != nil) //another cell so remove it
                    {
                        [self singleCellTapOveride:nil];
                    }
                    
                    //[_tableView setUserInteractionEnabled:NO];
                    [self.view addGestureRecognizer:_editingSingleCellOverideTap];
                    self.navigationItem.rightBarButtonItem = _doneButton;
                    [cell setEditing:YES animated:YES];
                    _editedIndividualCell = cell;
                    
                }
                else if(_editedIndividualCell != nil)
                {
                    [self singleCellTapOveride:nil];
                }
            }
            else if(_editedIndividualCell != nil)
            {
                [self singleCellTapOveride:nil];
            }
        }
        else if(_editedIndividualCell != nil)
        {
            [self singleCellTapOveride:nil];
        }
    }
}

#pragma mark - MTCardCell Delegate

- (void)mtCardcellDeleteClicked:(id)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    if(indexPath == nil)
    {
        MTLog(@"Delete row failed");
        return;
    }
    
    CardCellManager* cellManager = [_favorites objectAtIndex:indexPath.row];
    [_transpo removeFavorite:cellManager.stop WithBus:cellManager.stop.Bus];
}

- (void)cardCellRefreshRequestedForDisplayedData:(id)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    if(indexPath == nil)
    {
        MTLog(@"Update row failed");
        [(MTCardCell*)cell updateCellForIndividualUpdate:NO];
        return;
    }
    
    CardCellManager* cellManager = [_favorites objectAtIndex:indexPath.row];
    
    if(cellManager.status == CMS_UPDATING) //already updating
    {
        MTLog(@"Update row individual but already doing an update");
        [(MTCardCell*)cell updateCellForIndividualUpdate:NO];
        return;
    }
    
    if(cellManager.individualUpdate == YES) //already updating, havent received response
        return;
    
    cellManager.individualUpdate = YES;
    [self updateFavorite:cellManager];
}

#pragma mark - MTRefreshTableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(_editedIndividualCell != nil)
    {
        [self singleCellTapOveride:nil];
    }
    
    [_tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)refreshTableViewNeedsRefresh
{
    [self updateAllFavorites];
}

@end
