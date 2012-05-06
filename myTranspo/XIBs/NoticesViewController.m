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
    
    //[self.view addGestureRecognizer:_panGesture];
    
    _transpo.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[self.view removeGestureRecognizer:_panGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //view
    self.title = NSLocalizedString(@"NOTICESTITLE", nil);
    
    //tableview
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setDelaysContentTouches:NO];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)]];
    [_tableView setOpaque:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setupRefresh:_language];
    [_tableView addPullToRefreshHeader];
    [_tableView setRefreshDelegate:self];
    
    [self refreshNotices:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - MY Transpo delegate

- (void)myTranspo:(id)transpo State:(MTResultState)state receivedNotices:(NSDictionary *)notices
{
    [self stopLoading:nil];
    _data = nil;
    _data = notices;
    _keys = [[_data allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray* keys = [[NSMutableArray alloc] initWithArray:[[_data allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    [keys exchangeObjectAtIndex:2 withObjectAtIndex:3];
    _keys = (NSArray*)keys;
    
    UIView *headerSpacing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
#if 0    
    //update tableview header to adjust height
    UIView* headerSpacing = [[UIView alloc] init];
    CGRect headerSpacingFrame = headerSpacing.frame;
    headerSpacingFrame.size.height = (self.view.frame.size.height / 2) - ((_keys.count * kNoticesCellHeight) / 2);
    headerSpacing.frame = headerSpacingFrame;
    
#endif        
    [_tableView setTableHeaderView:headerSpacing];
    
    [_tableView reloadData];
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

#define kNoticesCellImageTag 101
#define kNoticesCellTitleTag 102
#define kNoticesCellSubTitleTag 103
#define kNoticesCellBackgroundTag 104

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoticesCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.hidden = YES;
        
        UILabel* cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 200, 20)];
        cellTitle.tag = kNoticesCellTitleTag;
        cellTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cellTitle.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cellTitle.backgroundColor = [UIColor clearColor];
        cellTitle.shadowColor = [UIColor whiteColor];
        cellTitle.shadowOffset = CGSizeMake(0, 1);
        
        UILabel* cellSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 38, 200, 16)];
        cellSubTitle.tag = kNoticesCellSubTitleTag;
        cellSubTitle.backgroundColor = [UIColor clearColor];
        cellSubTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        cellSubTitle.textColor = [UIColor colorWithRed:140./255. green:139./255. blue:139./255. alpha:1.0];
        cellSubTitle.shadowColor = [UIColor whiteColor];
        cellSubTitle.shadowOffset = CGSizeMake(0, 1);
        
        UIImageView* cellIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 58, 58)];
        cell.contentMode = UIViewContentModeCenter;
        cellIcon.tag = kNoticesCellImageTag;
        
        UIImageView* cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(6, 0, 308, 72)];
        cellBackground.tag = kNoticesCellBackgroundTag;
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cell.contentView addSubview:cellBackground];
        [cell.contentView addSubview:cellTitle];
        [cell.contentView addSubview:cellSubTitle];
        [cell.contentView addSubview:cellIcon];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView* cellBackground = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellBackgroundTag];
    if(indexPath.row == 0 && _keys.count == 1)
    {
        //draw single cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_top.png"];
    }
    else if(indexPath.row == 0)
    {
        cellBackground.image = [UIImage imageNamed:@"notice_cell_top.png"];
    }
    else if(indexPath.row == _keys.count-1)
    {
        //draw end cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_bottom.png"];
    }
    else
    {
        //draw medium cell
        cellBackground.image = [UIImage imageNamed:@"notice_cell_middle.png"];
    }
    
    UILabel *title = (UILabel*)[cell.contentView viewWithTag:kNoticesCellTitleTag];
    UILabel *subtitle = (UILabel*)[cell.contentView viewWithTag:kNoticesCellSubTitleTag];
    UIImageView *icon = (UIImageView*)[cell.contentView viewWithTag:kNoticesCellImageTag];
    
    title.text = [MTHelper convertNoticeIdToString:(NSString*)[_keys objectAtIndex:indexPath.row]];
    subtitle.text = [MTHelper convertNoticeIdToSubtitleString:(NSString*)[_keys objectAtIndex:indexPath.row]];
    icon.image = [UIImage imageNamed:[MTHelper convertNoticeIdToIconString:(NSString*)[_keys objectAtIndex:indexPath.row]]];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == _keys.count - 1)
        return kNoticesCellHeight - (81 - kNoticesCellHeight);
    return kNoticesCellHeight;
}

#pragma mark - Loader

- (void)startLoading:(id)sender
{
    [_tableView setUserInteractionEnabled:NO];
    [_tableView startLoading];
}

- (void)stopLoading:(id)sender
{
    [_tableView setUserInteractionEnabled:YES];
    [_tableView stopLoading];
}

- (void)refreshNotices:(id)sender
{
    [self startLoading:nil];
    [_transpo getNotices];
}

#pragma mark - MTRefresh Delegate

- (void)refreshTableViewNeedsRefresh
{
    [_tableView setUserInteractionEnabled:NO];
    [_transpo getNotices];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

@end
