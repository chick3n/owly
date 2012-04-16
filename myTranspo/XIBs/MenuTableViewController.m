//
//  MenuTableViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MenuTableViewController.h"

@implementation MenuTableViewController
@synthesize tableView                   = _tableView;
@synthesize delegate                    = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        _menu = [[NSMutableArray alloc] init];
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
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_background.png"]]];
    [self.tableView setSeparatorColor:kMTNAVCELLSEPERATORCOLOR];
    [self.tableView setTableFooterView:[[MTNavFooter alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)]];

    
    NSDictionary* navigationBuild = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MTNavigation" ofType:@"plist"]];
    for(NSDictionary *items in [navigationBuild objectForKey:@"Navigation"])
    {
        [_menu addObject:[[MTNavItem alloc] initWithDictionary:items WithLanguage:_language]];
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _accountButton.enabled = NO;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MTNavCell *cell = (MTNavCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[MTNavCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSArray *topLevelItems = [[NSBundle mainBundle] loadNibNamed:@"MTNavCell" owner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
        [cell initializeUI];
    }
      
    MTNavItem* item = [_menu objectAtIndex:indexPath.row];
    
    [cell updateNavCell:item.icon WithTitle:item.title];
    
    if(item.hasAlert)
    {
        switch (item.type) {
            case MTNAVNOTIFICATIONTYPEALERT:
                [cell updateNotificationAlert];
                break;
            case MTNAVNOTIFICATIONTYPECOUNT:
                [cell updateNotificationMessage:item.notificationMessage];
                break;
            case MTNAVNOTIFICATIONTYPENONE:
                [cell updateNotificationMessage:nil]; //hides notification
                break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTNavItem* item = [_menu objectAtIndex:indexPath.row];
    
    if([_delegate conformsToProtocol:@protocol(MenuTableViewDelegate)])
    {
        [_delegate menuTable:self selectedNewOption:item.viewController];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)accountClicked:(id)sender
{
    
}

@end
