//
//  AppDelegate.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ZUUIRevealController.h"
#import "MenuTableViewController.h"
#import "MyBusesViewController.h"
#import "StopsViewController.h"
#import "myTranspoOC.h"
//#import "MTOptionsDate.h"
#import "SettingsViewController.h"
#import "OTrainViewController.h"
#import "NoticesViewController.h"
#import "TripPlannerViewController.h"
#import "LoadingViewController.h"
#import "AlertsManager.h"

#import "Reachability.h"

#include "Core/ViewControllers.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ZUUIRevealControllerDelegate, MenuTableViewDelegate>
{
    ZUUIRevealController *          _menuController;
    MenuTableViewController *       _menuTableViewController;
    //MTOptionsDate*                  _menuOptionsDate;
    UINavigationController *        _navigationController;
    BOOL                            _rearViewControllerHidden;
    UITapGestureRecognizer*         _tap;
    UIPanGestureRecognizer*         _panGesture;
    UIPanGestureRecognizer*         _navPanGesture;
    myTranspoOC*                    _transpo;
    MTLanguage                      _language;
    NSArray*                        _routeNotices; //stores all the routes that have a notice
    NSDate*                         _lastDate;
    UIImageView*                    _rainbowBar;
    
    BOOL                            _disableClick;
    BOOL                            _newDatabase;
    
    Reachability*                   _hostReach;
    Reachability*                   _internetReach;
    Reachability*                   _wifiReach;
    
    AlertsManager*                  _alertManager;
}

@property (strong, nonatomic) UIWindow *window;

- (void) reachabilityChanged:(NSNotification *)note;
- (void)finishedLoading;

@end
