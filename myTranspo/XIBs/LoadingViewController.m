//
//  LoadingViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()
- (void)finishedInstalling;
- (void)migrateDatabase;
@end

@implementation LoadingViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self performSelector:@selector(finishedInstalling) withObject:nil afterDelay:4.0];
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

- (void)migrateDatabase
{
    MTSettings* settings = [[MTSettings alloc] init];
    
    NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"OCTranspo.sqlite"];
    BOOL canMigrateFavorites = NO;
    NSMutableArray* favorites = [[NSMutableArray alloc] init];
    NSString* sourcePath = [[NSBundle mainBundle] pathForResource:@"OCTranspo.zip" ofType:nil];
    
    //migrate favorites
    if([_transpo getSynchFavorites:favorites])
        canMigrateFavorites = YES;
    [_transpo closeDB];
    
    
    //remove the current database
    [manager removeItemAtPath:dbPath error:nil];
    
    //move the new database 
    [manager copyItemAtPath:sourcePath toPath:documentsDir error:nil];
    
    //extract new database
    
    
    //delete zipped new database
    [manager removeItemAtPath:[documentsDir stringByAppendingPathComponent:@"OCTranspo.zip"] error:nil];
    
    //update that we have a new database in settings
    [settings updateDatabaseVersionToBundle];
    
    //reconnect to the  new database
    [_transpo addDBPath:sourcePath]; 
    
    //add old favorites to new database
    if(canMigrateFavorites && favorites != nil)
    {
        for(MTStop* favStop in favorites)
        {
            [_transpo addFavorite:favStop WithBus:favStop.Bus];
        }
    }
    favorites = nil;
    
    //run final commands on database
    [_transpo execQuery:@"CREATE INDEX \"stop_timesTripId\" ON \"stop_times\" (\"trip_id\" ASC);"
     "CREATE INDEX \"stop_timesStopId\" ON \"stop_times\" (\"stop_id\" ASC);"
     "ANALYZE;" WithVacuum:YES];
    
    //wait for myTranspoFinishedExecutingQuery to leave
}

- (void)finishedInstalling
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate finishedLoading];
}

- (void)myTranspoFinishedExecutingQuery:(id)transpo
{
    [self finishedInstalling];
}

@end
