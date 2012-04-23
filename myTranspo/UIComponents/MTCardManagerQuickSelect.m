//
//  MTCardManagerQuickSelect.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardManagerQuickSelect.h"

@interface MTCardManagerQuickSelect ()
- (void)initializeTableView;
@end

@implementation MTCardManagerQuickSelect
@synthesize data = _data;
@synthesize delegateQuick = _delegateQuick;
@synthesize tableView = _tableView;
@synthesize headerBar = _headerBar;

- (void)setData:(NSArray *)data
{
    _data = data;
    
    if(data == nil)
        return;
    
    int count = _data.count;
    int width = self.frame.size.width;
    
    if(count * kQuickCellWidth > width)
    {
        self.tableView.tableHeaderView = nil;
        return;
    }
    
    UIView* headerWidth = [[UIView alloc] initWithFrame:CGRectMake(
                                                                   0
                                                                   , 0
                                                                   , kQuickCellWidth
                                                                   , (width/2) - ((count * kQuickCellWidth) /2))];
    self.tableView.tableHeaderView = headerWidth;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initializeTableView];
    }
    return self;
}

- (void)initializeTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kQuickCellWidth, self.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"search_background.png"]];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_background.png"]];
    
    
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_background.png"]];
    background.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
    CGRect backgroundFrame = background.frame;
    backgroundFrame.origin.x = 0;
    backgroundFrame.origin.y = 0;
    background.frame = backgroundFrame;
    self.tableView.backgroundView = background;
    
    
    [self addSubview:self.tableView];
    
    self.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.frame = frame;
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_data == nil) ? 0 : _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    }
    
    MTBus * bus = [_data objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", bus.BusNumber, bus.DisplayHeading];
    cell.textLabel.text = bus.BusNumber;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_delegateQuick conformsToProtocol:@protocol(MTCardManagerQuickSelectDelegate)])
        [_delegateQuick quickSelect:self receivedClick:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
