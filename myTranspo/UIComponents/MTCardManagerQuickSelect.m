//
//  MTCardManagerQuickSelect.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardManagerQuickSelect.h"

@implementation MTCardManagerQuickSelect
@synthesize data = _data;
@synthesize delegateQuick = _delegateQuick;
@synthesize tableView = _tableView;
@synthesize headerBar = _headerBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.headerBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_category_bar.png"]];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 23, frame.size.width, frame.size.height-23) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self addSubview:self.headerBar];
        [self addSubview:self.tableView];
    }
    return self;
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
    }
    
    MTBus * bus = [_data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", bus.BusNumber, bus.DisplayHeading];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_delegateQuick conformsToProtocol:@protocol(MTCardManagerQuickSelectDelegate)])
        [_delegateQuick quickSelect:self receivedClick:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
