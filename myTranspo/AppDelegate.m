//
//  AppDelegate.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
- (void)launchNewView:(MTViewControllers)view;
- (void)setupMyTranspo;
- (void)preLoad;
- (void)postLoad;
- (void)fullAppRefreshCalled:(NSNotification*)notification;
@end

@implementation AppDelegate

@synthesize window = _window;

- (id)init
{
    self = [super init];
    if(self)
    {
        _newDatabase = NO;
        
        _menuController = [[ZUUIRevealController alloc] init];
        _menuController.delegate = self;
        _menuTableViewController = [[MenuTableViewController alloc] initWithNibName:@"MenuTableViewController" bundle:nil];
        _menuTableViewController.delegate = self;
        _navigationController = nil;
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:_menuController action:@selector(revealGesture:)];
        _navPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:_menuController action:@selector(revealGesture:)];
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:_menuController action:@selector(revealToggle:)];
        
        _rainbowBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_topcolour_bar.png"]];
        CGRect rainbowFrame = _rainbowBar.frame;
        rainbowFrame.origin.y = 0;
        _rainbowBar.frame = rainbowFrame;
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    application.applicationIconBadgeNumber = 0;
    
    [self preLoad];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    
    //auto goto favorites if we need an update or notified of upcoming bus
    if(!_newDatabase)
        [self launchNewView:(localNotification == nil) ? [MTSettings startupScreen] : MTVCMYBUSES]; 
    else [self launchNewView:MTVCLOADING];
    
    [_menuController.view addSubview:_rainbowBar];
    self.window.rootViewController = _menuController;
    [self.window makeKeyAndVisible];
    
    [self postLoad];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if(_transpo)
    {
        [_transpo endGpsRefresh:nil];
        [_transpo turnOffLocationTracking];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [MTSettings networkNotificationStatus:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if(_transpo)
    {
        UIViewController* viewController = [_navigationController.viewControllers objectAtIndex:0];
        if([[viewController class] superclass] == [MTBaseViewController class])
        {
            MTViewControllers view = ((MTBaseViewController*)viewController).viewControllerType;
            switch (view) {
                case MTVCSTOPS:
                    _transpo.gpsRefreshRate = 60;
                    break;
                default:
                    _transpo.gpsRefreshRate = 300;
                    break;
            }
        }
    }
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    application.applicationIconBadgeNumber = 0;
}

- (void)finishedLoading
{
    _menuController.currentFrontViewPosition = FrontViewPositionRight;
    [self launchNewView:[MTSettings startupScreen]];
}

- (void)launchNewView:(MTViewControllers)view
{
    if(_navigationController.visibleViewController != nil)
    {
        //check if already open and just show it instead of reload
        UIViewController* viewController = [_navigationController.viewControllers objectAtIndex:0];
        if([[viewController class] superclass] == [MTBaseViewController class])
        {
            if(((MTBaseViewController*)viewController).viewControllerType == view)
            {
                [_menuController revealToggle:nil];
                return;
            }
        }
        
        [_navigationController.visibleViewController.view removeGestureRecognizer:_panGesture];
        [_navigationController.visibleViewController.view removeGestureRecognizer:_tap];
        [_navigationController.navigationBar removeGestureRecognizer:_panGesture];
    }
    
    _navigationController = nil;
    
    MTBaseViewController* newView = nil;
    //MTOptionsDate* optionsView = nil;
    _transpo.gpsRefreshRate = 300;
    switch (view) {
        case MTVCMENU:
            newView = [[MenuTableViewController alloc] initWithNibName:@"MenuTableViewController" bundle:nil];
            break; //should never happen
        case MTVCMYBUSES:
            newView = [[MyBusesViewController alloc] initWithNibName:@"MyBusesViewController" bundle:nil];
            /*optionsView = [[MTOptionsDate alloc] initWithNibName:@"MTOptionsDate" bundle:nil];
            optionsView.lastDate = _lastDate;
            optionsView.selectedDate = [NSDate date];
            optionsView.delegateOptions = (MyBusesViewController*)newView;*/
            break;
        case MTVCSTOPS:
            newView = [[StopsViewController alloc] initWithNibName:@"StopsViewController" bundle:nil];
            _transpo.gpsRefreshRate = 60;
            break;
        case MTVCSETTINGS:
            newView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            break;
        case MTVCTRAIN:
            newView = [[OTrainViewController alloc] initWithNibName:@"OTrainViewController" bundle:nil];
            break;
        case MTVCNOTICIES:
            newView = [[NoticesViewController alloc] initWithNibName:@"NoticesViewController" bundle:nil];
            break;
        case MTVCTRIPPLANNER:
            newView = [[TripPlannerViewController alloc] initWithNibName:@"TripPlannerViewController" bundle:nil];
            break;
        case MTVCLOADING:
            newView = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
            break;
        case MTVCUNKNOWN:
            return;
    }
    
    newView.language = _language;
    newView.transpo = _transpo;
    newView.panGesture = _panGesture;
    newView.navPanGesture = _navPanGesture;
    newView.menuControl = _menuController;
    newView.viewControllerType = view;
    /*newView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:_menuController action:@selector(revealToggle:)];*/
    UIButton* navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setImage:[UIImage imageNamed:@"global_menu_btn.png"] forState:UIControlStateNormal];
    [navButton addTarget:_menuController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [navButton sizeToFit];
    
    newView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navButton];
    //[newView.view addGestureRecognizer:_panGesture];

    _navigationController = [[UINavigationController alloc] initWithRootViewController:newView];
    [_navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [_navigationController.navigationBar addGestureRecognizer:_navPanGesture];
    
    if ([_navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [_navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"global_header_background.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    if(_menuController.frontViewController == nil)
        _menuController.frontViewController = _navigationController;
    else
    {
        [_menuController setFrontViewController:_navigationController animated:YES];
    }

    if(_menuController.rearViewController != _menuTableViewController)
        _menuController.rearViewController = _menuTableViewController;
    
    //if(optionsView != nil)
    //    [_menuController setRightViewController:optionsView];
}

- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    _rearViewControllerHidden = NO;
    UINavigationController * navController = (UINavigationController*)_menuController.frontViewController;
    if(navController != nil)
    {
        [navController.visibleViewController.view setUserInteractionEnabled:NO];
        [navController.view addGestureRecognizer:_tap];
    }
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    _rearViewControllerHidden = YES;
    UINavigationController* navController = (UINavigationController*)_menuController.frontViewController;
    if(navController != nil)
    {
        [navController.visibleViewController.view setUserInteractionEnabled:YES];
        [navController.view removeGestureRecognizer:_tap];
    }
    
    _disableClick = NO;
}

- (void)revealController:(ZUUIRevealController *)revealController didRevealRightViewController:(UIViewController *)rightViewController
{
    //_rearViewControllerHidden = NO;
    UINavigationController * navController = (UINavigationController*)_menuController.frontViewController;
    if(navController != nil)
    {
        [navController.visibleViewController.view setUserInteractionEnabled:NO];
        [navController.view addGestureRecognizer:_tap];
    }
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRightViewController:(UIViewController *)rightViewController
{
    //_rearViewControllerHidden = YES;
    UINavigationController* navController = (UINavigationController*)_menuController.frontViewController;
    if(navController != nil)
    {
        [navController.visibleViewController.view setUserInteractionEnabled:YES];
        [navController.view removeGestureRecognizer:_tap];
    }
}

- (void)setupMyTranspo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"OCTranspo.sqlite"];
    
    _transpo = [[myTranspoOC alloc] initWithLanguage:_language
                                           AndDBPath:dbPath
                                             ForCity:[MTSettings cityPreference]];
    
    _lastDate = [_transpo getLastSupportedDate];
    
    [_transpo addWebDBPath:@"http://www.vicestudios.com/apps/owly/oc/"];
    [_transpo addAPI];
    //[_transpo addOfflineTimes];
}

- (void)preLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(fullAppRefreshCalled:) 
                                                 name:(NSString*)kFullAppRefresh 
                                               object:nil];
    
    MTSettings* settings = [[MTSettings alloc] init];
    
    _language = [settings languagePreference];
    [settings updateNetworkNotification:NO];
    
    //MOVE SQLDB
    NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"OCTranspo.sqlite"];

    if(![manager fileExistsAtPath:dbPath] || [settings currentDatabaseNeedsUpdate])
    {
        MTLog(@"File Exists: %d OR settings need update: %d", [manager fileExistsAtPath:dbPath], [settings currentDatabaseNeedsUpdate]);
        MTLog(@"ABOUT TO REPLACE DATABASE");
        
        _newDatabase = YES;        
    }
    _newDatabase = YES;
    
    [self setupMyTranspo];
    if([settings offlineMode])
        [_transpo turnOffNetworkMethods];
    
    
    if(_menuTableViewController)
    {
        _menuTableViewController.language = _language;
        _menuTableViewController.transpo = _transpo;
    }
}

- (void)postLoad
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    _hostReach = [Reachability reachabilityWithHostName: @"www.google.com"];
	_internetReach = [Reachability reachabilityForInternetConnection];
	_wifiReach = [Reachability reachabilityForLocalWiFi];
	[_hostReach startNotifier];
	[_internetReach startNotifier];
	[_wifiReach startNotifier];
}

#pragma mark - MENUVIEWCONTROLLER DELEGATE

- (void)menuTable:(id)menuView selectedNewOption:(MTViewControllers)view
{
    if(_disableClick)
        return;
    
    if(view != MTVCUNKNOWN)
        [self launchNewView:view];
    _disableClick = YES;
}

#pragma mark - GLOBAL NOTIFICATIONS

- (void)fullAppRefreshCalled:(NSNotification*)notification
{
    //show reloading PICTURE?
    _menuController.view.hidden = YES;
    
    //unload
    
    [_panGesture removeTarget:_menuController action:@selector(revealGesture:)];
    [_navPanGesture removeTarget:_menuController action:@selector(revealGesture:)];
    [_tap removeTarget:_menuController action:@selector(revealToggle:)];
    
    _navigationController = nil;
    
    [_menuController unload];
    _menuController = nil;
    
    _menuTableViewController = nil;
    
    [_transpo kill];
    _transpo = nil;
    
    //reload
    
    _language = [MTSettings languagePreference];
    
    _menuController = [[ZUUIRevealController alloc] init];
    _menuController.delegate = self;
    
    _menuTableViewController = [[MenuTableViewController alloc] initWithNibName:@"MenuTableViewController" bundle:nil];
    _menuTableViewController.delegate = self;
    
    [_panGesture addTarget:_menuController action:@selector(revealGesture:)];
    [_navPanGesture addTarget:_menuController action:@selector(revealGesture:)];
    [_tap addTarget:_menuController action:@selector(revealToggle:)];
    
    [self setupMyTranspo];
    
    if(_menuTableViewController)
    {
        _menuTableViewController.language = _language;
        _menuTableViewController.transpo = _transpo;
    }
    
    [self launchNewView:MTVCSETTINGS]; ///can only be called from settings;

    self.window.rootViewController = _menuController;
    //[self.window makeKeyAndVisible];   
}

#pragma mark Reachability


- (void) reachabilityChanged:(NSNotification *)note
{
    if([MTSettings offlineMode])
        return;
    
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = [curReach connectionRequired];
    switch (netStatus)
    {
        case NotReachable:
        {
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired = NO;  
			if(![MTSettings networkNotification])
			{
				UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NETWORKDOWNTITLE", nil)
															 message:NSLocalizedString(@"NETWORKDOWNDETAILS", nil)
															delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[av show];
                
                [MTSettings networkNotificationStatus:YES];
			}
#if 0
            if(_transpo)
                [_transpo turnOffNetworkMethods];
#endif
            
            break;
        }
            
        case ReachableViaWWAN:
		case ReachableViaWiFi:
        {
            connectionRequired = NO; 
#if 0
            if(_transpo)
                [_transpo turnOnNetworkMethods];
#endif
            break;
        }
    }
	
	if(connectionRequired)
	{
		if(![MTSettings networkNotification])
		{
			UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NETWORKDOWNTITLE", nil)
                                                         message:NSLocalizedString(@"NETWORKDOWNDETAILS", nil)
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[av show];
            
            [MTSettings networkNotificationStatus:YES];
        }
#if 0
        if(_transpo)
            [_transpo turnOffNetworkMethods];
#endif
	}
	
}

@end
