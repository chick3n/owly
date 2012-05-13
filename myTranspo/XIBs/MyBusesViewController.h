//
//  MyBusesViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
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
#import "StopsFavoriteViewControllerViewController.h"


@interface MyBusesViewController : MTBaseViewController <MyTranspoDelegate, UITableViewDataSource, UITableViewDelegate, MTCardCellDelegate, MTRefreshDelegate, MTQueueSafe>
{
    NSMutableArray*         _favorites; //cardcellmanager
    BOOL                    _updateInProgress;
    int                     _updateCount;
    
    //UI Components
    IBOutlet 
    MTRefreshTableView      *_tableView;
    UIBarButtonItem         *_editButton;
    UIBarButtonItem         *_doneButton;
    MTCardCell              *_editedIndividualCell;
    UITapGestureRecognizer  *_editingSingleCellOverideTap;
}

@property (nonatomic, strong)   UINib*                          cellLoader;

@end
