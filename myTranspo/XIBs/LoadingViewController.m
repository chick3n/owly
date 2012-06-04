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
- (void)updateProgress:(NSNumber*)status;
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
    
    _transpo.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self performSelectorInBackground:@selector(migrateDatabase) withObject:nil];
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
#if USE7ZIP
    NSString* sourcePath = [[NSBundle mainBundle] pathForResource:@"OCTranspo.7z" ofType:nil];
#else
    NSString* sourcePath = [[NSBundle mainBundle] pathForResource:@"OCTranspo.zip" ofType:nil];
#endif
    //migrate favorites
    if([_transpo getSynchFavorites:favorites])
        canMigrateFavorites = YES;
    [_transpo closeDB];
    
    
    //remove the current database
    [manager removeItemAtPath:dbPath error:nil];
    
    //move the new database 
    //[manager copyItemAtPath:sourcePath toPath:documentsDir error:nil];
    
    [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithInt:BEGINNING_INSTALL] waitUntilDone:NO];
    //extract new database
#if USE7ZIP
    BOOL status = [LZMAExtractor extractArchiveEntry:sourcePath archiveEntry:@"OCTranspo.sqlite" outPath:dbPath];
    if(status == NO)
        MTLog(@"Failed to extract database.");
#else
    BOOL status = [SSZipArchive unzipFileAtPath:sourcePath toDestination:documentsDir];
    if(status == NO)
        MTLog(@"Failed to extract database.");
#endif
    //delete zipped new database
    //[manager removeItemAtPath:[documentsDir stringByAppendingPathComponent:@"OCTranspo.zip"] error:nil];
    
    //update that we have a new database in settings
    [settings updateDatabaseVersionToBundle];
    
    //reconnect to the  new database
    if(![_transpo addDBPath:dbPath])
        MTLog(@"Failed attaching new database.");

#if WITH_INDEXING //not doing indexeing as it is way tooooo slow on phone approx 6 mins
    //reconnect using install parameters
    [_transpo.ocDb killDatabase];
    [_transpo.ocDb connectToDatabaseForInstall];
#endif 
    //add old favorites
    if(canMigrateFavorites && favorites != nil)
    {
        for(MTStop* favStop in favorites)
        {
            [_transpo addFavorite:favStop WithBus:favStop.Bus];
        }
    }
    favorites = nil;

#if WITH_INDEXING //not doing indexeing as it is way tooooo slow on phone approx 6 mins
    //run final commands on database
    if(![_transpo execQuery:@"CREATE INDEX `main`.`stop_timesTripId` ON `stop_times` (`trip_id` ASC);"
     "CREATE INDEX `main`.`stop_timesStopId` ON `stop_times` (`stop_id` ASC);"
     "ANALYZE;" WithVacuum:NO])
    {
        [self performSelectorOnMainThread:@selector(finishedInstalling) withObject:nil waitUntilDone:NO];
    }
#else
#if 0
    if(![_transpo execQuery:@"ANALYZE;" WithVacuum:NO])
    {
        [self performSelectorOnMainThread:@selector(finishedInstalling) withObject:nil waitUntilDone:NO];
    }
#endif 
    [self performSelectorOnMainThread:@selector(finishedInstalling) withObject:nil waitUntilDone:NO];
#endif
    //wait for myTranspoFinishedExecutingQuery to leave
    //[self performSelectorOnMainThread:@selector(finishedInstalling) withObject:nil waitUntilDone:NO];
}

- (void)finishedInstalling
{
    [self updateProgress:[NSNumber numberWithInt:FINISHINGUP]];
    
#if 1 
    [_transpo.ocDb killDatabase];
    [_transpo.ocDb connectToDatabase];
#endif    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate finishedLoading];
}

- (void)myTranspoFinishedExecutingQuery:(id)transpo
{
    [self finishedInstalling];
}

- (void)updateProgress:(NSNumber*)status
{
    switch ([status intValue]) {
        case BEGINNING_INSTALL:
            _notifier.text = NSLocalizedString(@"BEGINNINGINSTALL", nil);
            break;
        case EXTRACTING:
            _notifier.text = NSLocalizedString(@"EXTRACTINGDATABASE", nil);
            break;
        case RUNNINGQUERIES:
            _notifier.text = NSLocalizedString(@"INSTALLINGNEWDATABASE", nil);
            break;
        case FINISHINGUP:
            _notifier.text = NSLocalizedString(@"FINISHINGINSTALL", nil);
            break;
    }
}

@end
