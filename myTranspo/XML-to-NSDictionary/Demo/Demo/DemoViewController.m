//
//  DemoViewController.m
//  Demo
//
//  Created by David Perry on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DemoViewController.h"
#import "XMLReader.h"

@implementation DemoViewController

@synthesize tableView=_tableView;

- (void)dealloc
{
    [_tableView release];
    [_xmlDictionary release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Grab some XML data from Twitter
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://twitter.com/status/user_timeline/github"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Synchronous isn't ideal, but simplifies the code for the Demo
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Parse the XML Data into an NSDictionary
    _xmlDictionary = [[XMLReader dictionaryForXMLData:xmlData error:&error] retain];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_xmlDictionary retrieveForPath:@"statuses.status"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"@github status feed";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StatusCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }

    // Get the 'status' for the relevant row
    NSDictionary *status = [_xmlDictionary retrieveForPath:[NSString stringWithFormat:@"statuses.status.%d", indexPath.row]];
    
    cell.textLabel.text = [status objectForKey:@"text"];
    cell.detailTextLabel.text = [status objectForKey:@"created_at"];

    return cell;
}

@end
