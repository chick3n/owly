//
//  MTCardTimes.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardTimes.h"

@implementation MTCardTimes
@synthesize timesWeekday =          _timesWeekday;
@synthesize timesSaturday =         _timesSaturday;
@synthesize timesSunday =           _timesSunday;
@synthesize cellDelegate =          _cellDelegate;
@synthesize cellAlert =             _cellAlert;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        
        _cellAlert = [[MTCellAlert alloc] init];
        [self addSubview:_cellAlert];
    }
    return self;
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
        if(_cellDelegate != nil)
            cell.delegate = _cellDelegate;
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
    
    [cell updateRowLabelsRow1:(sequencedRow < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow] : nil Row1Seq:sequencedRow
                         Row2:(sequencedRow+1 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+1] : nil Row2Seq:sequencedRow+1
                         Row3:(sequencedRow+2 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+2] : nil Row3Seq:sequencedRow+2
                         Row4:(sequencedRow+3 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+3] : nil Row4Seq:sequencedRow+3
                         Row5:(sequencedRow+4 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+4] : nil Row5Seq:sequencedRow+4 
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

- (void)displayCellAlert:(NSString*)headingForAlert Row:(int)row Section:(int)section Center:(int)center
{
    CGPoint pos = CGPointZero;
    BOOL bottom = NO;
    
    int sectionHeight = 0;
    for(int x=0; x<section; x++)
    {
        sectionHeight += [self rectForSection:x].size.height;
    }
    
    int rowHeight = row * kCardRowCellHeightLong;
    
    NSLog(@"off:%f row:%d secheight:%d", self.contentOffset.y, rowHeight, sectionHeight);
    
    pos.x = center;
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
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_cellAlert hideAlertWithSelfInvoke:YES];
}

@end
