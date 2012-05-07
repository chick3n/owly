//
//  SettingsListViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsListViewController.h"

@interface SettingsListViewController ()
- (void)goBack:(id)sender;
@end

@implementation SettingsListViewController
@synthesize tableView               = _tableView;
@synthesize setting                 = _setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];
        [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
        [doneButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
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
    // Do any additional setup after loading the view from its nib.
    
    self.title = _setting.title;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_bg2.png"]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    //[self.view addGestureRecognizer:_panGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_setting.data == nil) ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_setting.data == nil) ? 0 : _setting.data.count;
}

#define kNoticesCellBackgroundTag 104
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        UIImageView* cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(-4, 0, 308, 44)];
        cellBackground.tag = kNoticesCellBackgroundTag;
        
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.contentView insertSubview:cellBackground atIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView* cellBackground = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellBackgroundTag];
    if(indexPath.row == 0 && _setting.data.count == 1)
    {
        //draw single cell
        cellBackground.image = [UIImage imageNamed:@"settings_singlecell.png"];
    }
    else if(indexPath.row == 0)
    {
        cellBackground.image = [UIImage imageNamed:@"settings_topcell.png"];
    }
    else if(indexPath.row == _setting.data.count-1)
    {
        //draw end cell
        cellBackground.image = [UIImage imageNamed:@"settings_bottomcell.png"];
    }
    else
    {
        //draw medium cell
        cellBackground.image = [UIImage imageNamed:@"settings_middlecell.png"];
    }
    
    NSString* settings = (NSString*)[_setting.data objectAtIndex:indexPath.row];
        
    cell.textLabel.text = settings;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.row == _setting.selected)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //update setting which will also call delegate to perform save!
    [_setting setSelected:indexPath.row];
    [_setting selectedSettingHasChanged];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark - Navigation bar

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
