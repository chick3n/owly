//
//  NoticesViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "NoticesViewController.h"

@interface NoticesViewController ()
- (void)startLoading:(id)sender;
- (void)stopLoading:(id)sender;
- (void)refreshNotices:(id)sender;
@end

@implementation NoticesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self.view addGestureRecognizer:_panGesture];
    
    _transpo.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer:_panGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //view
    self.title = NSLocalizedString(@"NOTICESTITLE", nil);
    
    //tableview
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //navigationItem
    MTRightButton* refreshButton = [[MTRightButton alloc] initWithType:kRightButtonTypeSingle];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshNotices:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    
    [self startLoading:nil];
    [_transpo getNotices];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MY Transpo delegate

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedNotices:(NSDictionary *)notices
{
    [self stopLoading:nil];
    _data = nil;
    _data = notices;
    _keys = [_data allKeys];
    
    [_tableView reloadData];
}

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedRouteNotices:(NSArray *)notices
{
    //we arent using this.
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
    return [_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoticesCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [MTHelper convertNoticeIdToString:(NSString*)[_keys objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* sectionData = (NSArray*)[_data objectForKey:[_keys objectAtIndex:indexPath.row]];
    
    if(sectionData != nil)
    {
        NoticesSectionViewController* nsvc = [[NoticesSectionViewController alloc] initWithNibName:@"NoticesSectionViewController" bundle:nil];
        nsvc.title = [MTHelper convertNoticeIdToString:(NSString*)[_keys objectAtIndex:indexPath.row]];
        nsvc.data = sectionData;
        nsvc.panGesture = _panGesture;
        nsvc.language = _language;
        [self.navigationController pushViewController:nsvc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Loader

- (void)startLoading:(id)sender
{
    [_tableView setUserInteractionEnabled:NO];
    [_loader startAnimating];
}

- (void)stopLoading:(id)sender
{
    [_loader stopAnimating];
    [_tableView setUserInteractionEnabled:YES];
}

- (void)refreshNotices:(id)sender
{
    [self startLoading:nil];
    [_transpo getNotices];
}

@end
