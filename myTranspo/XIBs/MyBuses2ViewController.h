//
//  MyBuses2ViewController.h
//  myTranspo
//
//  Created by Lion User on 09/05/2012.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZUUIRevealController.h"
#import "MTCardCell.h"
#import "MTIncludes.h"
#import "MTBaseViewController.h"
#import "MTRefreshTableView.h"
#import "TripViewController.h"
#import "MenuTableViewController.h"
//#import "MTOptionsDate.h"
#import "MTRightButton.h"
#import "CardCellManager.h"

@interface MyBuses2ViewController : MTBaseViewController <MyTranspoDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray*         _favorites; //cardcellmanager
    
    //UI Components
    IBOutlet UITableView    *_tableView;
}

@property (nonatomic, strong)   UINib*                          cellLoader;

@end
