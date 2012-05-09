//
//  MyBuses2ViewController.m
//  myTranspo
//
//  Created by Lion User on 09/05/2012.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MyBuses2ViewController.h"

@interface MyBuses2ViewController()
- (void)generateFavorites:(NSArray*)listOfFavorites;
- (void)updateAllFavorites;
- (void)updateFavorite:(CardCellManager*)cellManager;
- (int)findCellManagerForStop:(MTStop*)stop;
@end

@implementation MyBuses2ViewController
@synthesize cellLoader  =               _cellLoader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    _transpo.delegate = self;
    [_transpo getFavorites];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _transpo.delegate = self;
}

#pragma mark - My Transpo Delegate

- (void)myTranspo:(MTResultState)state receivedFavorites:(NSMutableArray*)favorites
{
    if(state == MTRESULTSTATE_SUCCESS)
    {
        [self generateFavorites:favorites];
        [_tableView reloadData]; //add all cells to page      
        [self performSelector:@selector(updateAllFavorites) withObject:nil afterDelay:0.25];
    }
    else
    {
        MTLog(@"Failed to get Favorites...");
    }
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
            [cellManager updateDisplayObjects];
            
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Managing Favorites

- (void)generateFavorites:(NSArray *)listOfFavorites
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
        cardCellManager.state = CCM_EMPTY;
        cardCellManager.status = CMS_IDLE;
        
        [cardCellManager updateDisplayObjects];
        
        [_favorites addObject:cardCellManager];
    }
}

- (void)updateAllFavorites
{
    for(CardCellManager* cellManager in _favorites)
    {
        [self updateFavorite:cellManager];
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
    
    cellManager.status = CMS_UPDATING;
    [_transpo updateFavorite:cellManager.stop FullUpdate:NO];
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
        [cell initializeUI];
    }
    
    CardCellManager* cellManager = [_favorites objectAtIndex:indexPath.row];
    
    [cell updateCellBusNumber:cellManager.busNumber 
         AndBusDisplayHeading:cellManager.busHeadingDisplay 
           AndStopStreentName:cellManager.stopStreetName];
    
    
    
    return cell;
}

@end
