//
//  MTCardTimes.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardTimes.h"

@interface MTCardTimes ()
- (void)initParameters;
@end

@implementation MTCardTimes
@synthesize timesWeekday =          _timesWeekday;
@synthesize timesSaturday =         _timesSaturday;
@synthesize timesSunday =           _timesSunday;
@synthesize cellAlert =             _cellAlert;
@synthesize alertNotifications =    _alertNotifications;
@synthesize cellAlertDelegate =     _cellAlertDelegate;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initParameters];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initParameters];
    }
    return self;
}

- (void)initParameters
{
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.dataSource = self;
    
    _cellAlert = [[MTCellAlert alloc] init];
    _cellAlert.runForLength = 5.0;
    _cellAlert.delegate = self;
    UIButton* accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessoryView setImage:[UIImage imageNamed:@"card_arrow_left.png"] forState:UIControlStateNormal];
    [accessoryView setImage:[UIImage imageNamed:@"card_arrow_right.png"] forState:UIControlStateSelected];
    _cellAlert.accessoryView = accessoryView;
    
    [self addSubview:_cellAlert];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_cellAlert removeFromSuperview];
    [self insertSubview:_cellAlert atIndex:self.subviews.count];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* times = nil;
    if(section == 0)
    {
        times = _timesWeekday;
    }
    else if(section == 1)
    {
        times = _timesSaturday;
    }
    else if(section == 2)
    {
        times = _timesSunday;
    }
    
    if(times == nil)
        return 1;
    
    if(times.count == 0)
        return 1; //used for empty
    
    float rows = (float)times.count / (float)kRowCount;
    
    return ceil(rows);   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIndentifier = @"MTCardRowCell";
    
    MTCardTimesRowCell* cell = (MTCardTimesRowCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(cell == nil)
    {
        cell = (MTCardTimesRowCell*)[[MTCardTimesRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.delegate = self;
    }
    
    NSArray* times = nil;
    
    if(indexPath.section == 0)
        times = _timesWeekday;
    else if(indexPath.section == 1)
        times = _timesSaturday;
    else if(indexPath.section == 2)
        times = _timesSunday;
    
    if(times == nil)
    {
        [cell addNoticeMesssage:NSLocalizedString(@"GATHERINGSCHEDULE", nil)];
        return cell;
    }
    
    uint sequencedRow = indexPath.row * kRowCount;
    uint totalRows = times.count;
    
    MTTime* time1 = (sequencedRow < totalRows) ? [times objectAtIndex:sequencedRow] : nil;
    MTTime* time2 = (sequencedRow+1 < totalRows) ? [times objectAtIndex:sequencedRow+1] : nil;
    MTTime* time3 = (sequencedRow+2 < totalRows) ? [times objectAtIndex:sequencedRow+2] : nil;
    MTTime* time4 = (sequencedRow+3 < totalRows) ? [times objectAtIndex:sequencedRow+3] : nil;
    MTTime* time5 = (sequencedRow+4 < totalRows) ? [times objectAtIndex:sequencedRow+4] : nil;
    
    [cell updateRowLabelsRow1:time1 Row1Seq:sequencedRow
                         Row2:time2 Row2Seq:sequencedRow+1
                         Row3:time3 Row3Seq:sequencedRow+2
                         Row4:time4 Row4Seq:sequencedRow+3
                         Row5:time5 Row5Seq:sequencedRow+4 
                      Section:indexPath.section 
                          Row:indexPath.row
     ];
    [cell updateRowBackgroundColor:(BOOL)(indexPath.row & 0x1)];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCardRowCellHeightLong;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *header = nil;
    if(section == 0)
        header = NSLocalizedString(@"MTDEF_CARDWEEKDAY", nil);
    else if(section == 1)
        header = NSLocalizedString(@"MTDEF_CARDSATURDAY", nil);
    else if(section == 2)
        header = NSLocalizedString(@"MTDEF_CARDSUNDAY", nil);
    
    if(header == nil)
        return nil;
    
    UIImageView* categoryBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_category_bar.png"]];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, categoryBar.frame.size.width - 24, categoryBar.frame.size.height - 7)];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = header;
    headerLabel.shadowColor = [UIColor colorWithRed:38./255. green:154./255. blue:201./255. alpha:1.0];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    [categoryBar addSubview:headerLabel];
    
    return categoryBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCardTimesHeaderHeight;
}

#pragma mark - HELPERS

- (float)heightForTablesData
{
    float helper = 0;
    int timeTableHeight = kCardTimesHeaderHeight * 3;
    if(_timesWeekday != nil)
    {
        helper = (_timesWeekday.count > 0) ? ceil((float)_timesWeekday.count/(float)kRowCount) : 1.0;
        timeTableHeight += kCardRowCellHeightLong * helper;
    }
    if(_timesSaturday != nil)
    {
        helper = (_timesSaturday.count > 0) ? ceil((float)_timesSaturday.count/(float)kRowCount) : 1.0;
        timeTableHeight += kCardRowCellHeightLong * helper;
    }
    if(_timesSunday != nil)
    {
        helper = (_timesSunday.count > 0) ? ceil((float)_timesSunday.count/(float)kRowCount) : 1.0;
        timeTableHeight += kCardRowCellHeightLong * helper;
    }

    return timeTableHeight;
}

- (void)displayCellAlert:(NSString*)headingForAlert ForCell:(MTCardCellButton*)cell
{
    CGPoint pos = CGPointZero;
    BOOL bottom = NO;
    int row = cell.extraValue2;
    int section = cell.extraValue1;
    
    int sectionHeight = 0;
    for(int x=0; x<section; x++)
    {
        sectionHeight += [self rectForSection:x].size.height;
    }
    
    int rowHeight = row * kCardRowCellHeightLong;
    
    NSLog(@"off:%f row:%d secheight:%d", self.contentOffset.y, rowHeight, sectionHeight);
    
    pos.x = cell.center.x;
    pos.y = sectionHeight + rowHeight + _cellAlert.frame.size.height;    
    
    if(rowHeight + sectionHeight <= self.contentOffset.y + kCardRowCellHeightLong || row == 0)
    {
        bottom = YES;
        pos.y -= (kCardRowCellHeightLong / 2);
    }
    
    [_cellAlert displayAlert:headingForAlert
                       AtPos:pos
               ConstrainedTo:self.bounds.size 
                  UpsideDown:bottom];
    
    
    if(cell.reference != nil && [cell.reference class] == [MTTime class])
    {
        MTTime* time = (MTTime*)cell.reference;
        
        _cellAlert.refrenceObject = cell.reference;
        [_cellAlert toggleAccessoryButton:(time.Alert != nil) ? YES : NO];
    }
    else {
        [_cellAlert toggleAccessoryButton:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_cellAlert hideAlertWithSelfInvoke:YES];
}

- (void)hideAlert
{
    [_cellAlert hideAlertWithSelfInvoke:YES];
}

#pragma mark - Cell Alert Delegate

- (void)cardTimesRow:(id)owner ClickedOnCell:(MTCardCellButton *)cell
{
    MTTime* time = nil;
    
    if(cell.tag < 0)
        return;
    
    if(cell.extraValue1 == 0 && _timesWeekday.count > cell.tag) //weekday
        time = [_timesWeekday objectAtIndex:cell.tag];
    else if(cell.extraValue1 == 1 && _timesSaturday.count > cell.tag) //weekday
        time = [_timesSaturday objectAtIndex:cell.tag];
    else if(cell.extraValue1 == 2 && _timesSunday.count > cell.tag) //weekday
        time = [_timesSunday objectAtIndex:cell.tag];
    
    if(time == nil)
        return;
    
    NSLog(@"Show Heading for Time: %@", [time getTimeForDisplay]);
    
    //display notice
    [self displayCellAlert:time.EndStopHeader ForCell:cell];
}

- (void)cellAlertAccessoryViewClicked:(id)cellAlert
{
    if(cellAlert == nil)
        return;
    
    MTCellAlert* alert = (MTCellAlert*)cellAlert;
    
    if(alert.refrenceObject == nil)
        return;
    
    if([alert.refrenceObject class] == [MTTime class])
    {
        if([_cellAlertDelegate respondsToSelector:@selector(cardTimes:AddAlertForTime:)])
            [_cellAlertDelegate cardTimes:self AddAlertForTime:(MTTime*)alert.refrenceObject];
    }
}

@end
