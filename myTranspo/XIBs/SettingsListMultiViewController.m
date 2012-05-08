//
//  SettingsListMultiViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-01.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsListMultiViewController.h"

@interface SettingsListMultiViewController ()
- (void)goBack:(id)sender;
@end

@implementation SettingsListMultiViewController
@synthesize tableView               = _tableView;
@synthesize multiSettings           = _multiSettings;

- (void)setMultiSettings:(SettingsMultiType *)multiSettings
{
    _multiSettings = multiSettings;
    if(_multiSettings != nil && _multiSettings.options != nil)
    {
        NSArray* tmp = [_multiSettings.options allKeys];
        _data = [tmp sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];
        [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
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
    
    self.title = NSLocalizedString(@"FILTER", nil);
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    
    MTRightButton* doneButton = [[MTRightButton alloc] initWithType:kRightButtonTypeAction];
    [doneButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:NSLocalizedString(@"MTDEF_DONE", nil) forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_data == nil)
        return 0;
    return _data.count;
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
    
    NSDictionary* data = _multiSettings.options;
    NSNumber* value = [data objectForKey:[_data objectAtIndex:indexPath.row]];
    NSString* title = [_data objectAtIndex:indexPath.row];
    
    UIImageView* cellBackground = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellBackgroundTag];
    if(indexPath.row == 0 && _data.count == 1)
    {
        //draw single cell
        cellBackground.image = [UIImage imageNamed:@"settings_singlecell.png"];
    }
    else if(indexPath.row == 0)
    {
        cellBackground.image = [UIImage imageNamed:@"settings_topcell.png"];
    }
    else if(indexPath.row == _data.count-1)
    {
        //draw end cell
        cellBackground.image = [UIImage imageNamed:@"settings_bottomcell.png"];
    }
    else
    {
        //draw medium cell
        cellBackground.image = [UIImage imageNamed:@"settings_middlecell.png"];
    }
    
    cell.textLabel.text = title;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(value.intValue > 0)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary* data = _multiSettings.options;
    NSNumber* value = [data objectForKey:[_data objectAtIndex:indexPath.row]];
    
    if(value.intValue > 0)
        [data setValue:[NSNumber numberWithInt:0] forKey:[_data objectAtIndex:indexPath.row]];
    else [data setValue:[NSNumber numberWithInt:1] forKey:[_data objectAtIndex:indexPath.row]];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma  mark - Navigation bar

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
