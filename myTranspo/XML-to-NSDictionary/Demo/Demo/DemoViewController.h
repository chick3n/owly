//
//  DemoViewController.h
//  Demo
//
//  Created by David Perry on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *_xmlDictionary;
    UITableView *_tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
