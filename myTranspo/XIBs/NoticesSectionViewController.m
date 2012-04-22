//
//  NoticesSectionViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "NoticesSectionViewController.h"

@interface NoticesSectionViewController ()
- (void)goBack:(id)sender;
@end

@implementation NoticesSectionViewController
@synthesize data                = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.view addGestureRecognizer:_panGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[self.view removeGestureRecognizer:_panGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //tableView
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]];
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
    // Return the number of sections.
    return (_data != nil) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* entry = [_data objectAtIndex:indexPath.row];
    
    cell.title = [entry valueForKey:@"title"];
    cell.subtitle = [entry valueForKey:@"date"];
    cell.type = CELLNOTICE;

    [cell update];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* rowData = (NSDictionary*)[_data objectAtIndex:indexPath.row];
    
    if(rowData != nil)
    {
        NoticesDataViewController* ndvc = [[NoticesDataViewController alloc] initWithNibName:@"NoticesDataViewController" bundle:nil];
        ndvc.panGesture = _panGesture;
        ndvc.language = _language;
        ndvc.data = rowData;
        ndvc.title = self.title;
        
        [self.navigationController pushViewController:ndvc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation Controller

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
