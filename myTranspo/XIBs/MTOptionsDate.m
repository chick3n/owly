//
//  MTOptionsDate.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTOptionsDate.h"

@interface MTOptionsDate()
- (void)setupDateArray;
@end

@implementation MTOptionsDate
@synthesize lastDate            = _lastDate;
@synthesize selectedDate        = _selectedDate;
@synthesize delegateOptions     = _delegateOptions;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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

    //tableView
    //[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_background.png"]]];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_bg_tile.png"]]];
    [self.tableView setSeparatorColor:kMTNAVCELLSEPERATORCOLOR];
    [self.tableView setTableFooterView:[[MTNavFooter alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)]];
    
    //dateformatter
    _dateFormatter = [MTHelper MTDateFormatterDashesYYYYMMDD];
    _dateFormatter.dateFormat = @"EEEE, d";
    
    //date suffix
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    _suffixes = [suffix_string componentsSeparatedByString: @"|"];
    
    if(_lastDate != nil)
    {
        [self setupDateArray];
    }
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
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_data == nil) ? 0 : _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [(NSArray*)[_data objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.];
        cell.textLabel.textColor = [UIColor colorWithRed:230./250. green:230./250. blue:230./250. alpha:0.8];
        cell.textLabel.shadowColor = [UIColor blackColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        cell.textLabel.textAlignment = UITextAlignmentRight;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *sep = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 2)];
        [sep setImage:[UIImage imageNamed:@"menu_cell_bottom.png"]];
        [cell.contentView addSubview:sep];
        
        UIImageView *sel = [[UIImageView alloc] initWithFrame:CGRectMake((cell.frame.size.width - 100) + 40, 20, 20, 20)];
        [sel setImage:[UIImage imageNamed:@"route_cell_bus.png"]];
        [sel setTag:101];
        [cell.contentView addSubview:sel];
    }
    
    NSArray *month = [_data objectAtIndex:indexPath.section];
    NSDate *date = [month objectAtIndex:indexPath.row];

    NSDateComponents* dateComponent = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date];
    int day = [dateComponent day];
    
    if(_selectedDate != nil)
    {
        NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:_selectedDate options:0];
        UIImageView *sel = (UIImageView*)[cell.contentView viewWithTag:101];
        if([components day] == 0)
            sel.hidden = NO;
        else sel.hidden = YES;
    }
    
    NSString *suffix = [_suffixes objectAtIndex:day];   
    
    cell.textLabel.text = [[_dateFormatter stringFromDate:date] stringByAppendingString:suffix];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* headerLabel = @"";
    NSDateFormatter* monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.dateFormat = @"MMMM Y";
    
    NSArray* months = [_data objectAtIndex:section];
    if(months != nil && months.count > 0)
    {
        NSDate* date = [months objectAtIndex:0];
        headerLabel = [monthFormatter stringFromDate:date];
    }
    
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [header addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_header_bar.png"]]];
    //(header.frame.size.width - REVEAL_OPTIONS_EDGE) + 8
    UILabel *tableViewHeadlerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 17)];
    tableViewHeadlerLabel.tag = 100;
    tableViewHeadlerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.];
    tableViewHeadlerLabel.textColor = [UIColor colorWithRed:230./250. green:230./250. blue:230./250. alpha:0.8];
    tableViewHeadlerLabel.shadowColor = [UIColor blackColor];
    tableViewHeadlerLabel.shadowOffset = CGSizeMake(0, 1);
    tableViewHeadlerLabel.backgroundColor = [UIColor clearColor];
    tableViewHeadlerLabel.textAlignment = UITextAlignmentRight;
    tableViewHeadlerLabel.text = headerLabel;
    
    CGRect headerFrame = tableViewHeadlerLabel.frame;
    headerFrame.origin.y = (header.frame.size.height / 2) - (headerFrame.size.height / 2);
    tableViewHeadlerLabel.frame = headerFrame;
    
    [header addSubview:tableViewHeadlerLabel];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray* months = [_data objectAtIndex:section];
    if(months != nil && months.count > 0)
    {
        return 44;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMTNAVCELLHEIGHT;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* months = [_data objectAtIndex:indexPath.section];
    NSDate* date = [months objectAtIndex:indexPath.row];
    _selectedDate = date;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
    
    if([_delegateOptions conformsToProtocol:@protocol(MTOptionsDateProtocol)])
        [_delegateOptions optionsDate:self dateHasChanged:date];
    
    //hide it
    if([self.parentViewController class] == [ZUUIRevealController class])
    {
        ZUUIRevealController* revealController = (ZUUIRevealController*)self.parentViewController;
        if(revealController != nil)
        {
            [revealController revealToggle:nil];
        }
    }
}

#pragma mark - DATE Helpers

- (void)setupDateArray
{
    NSMutableArray* months = [[NSMutableArray alloc] init];
    NSMutableArray* dates = [[NSMutableArray alloc] init];
    NSDate* nextDate = [NSDate date];
    BOOL newMonth = NO;
    NSDateFormatter* monthValue = [[NSDateFormatter alloc] init];
    int lastMonth = -1;
    
    [monthValue setDateFormat:@"MM"];
    lastMonth = [[monthValue stringFromDate:nextDate] intValue];
    [dates addObject:nextDate];
    
    while([nextDate compare:_lastDate] == NSOrderedAscending)
    {
        NSDate* newDate = [nextDate dateByAddingTimeInterval:60*60*24*1];
        int newDateMonth = [[monthValue stringFromDate:newDate] intValue];
        
        if(lastMonth != newDateMonth)
            newMonth = YES;
        
        if(newMonth)
        {
            newMonth = NO;
            [months addObject:dates];
            dates = [[NSMutableArray alloc] init];
        }
        
        [dates addObject:newDate];
        nextDate = newDate;
    }
    
    if(dates != nil && dates.count > 0)
        [months addObject:dates];
    
    _data = months;
}

@end
