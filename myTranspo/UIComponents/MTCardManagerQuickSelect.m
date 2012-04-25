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
        //self.headerBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_pullbar.png"]];
        self.headerBar = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headerBar setImage:[UIImage imageNamed:@"global_pullbar.png"] forState:UIControlStateNormal];        
        self.headerBar.frame = CGRectMake(0, frame.size.height-20, 320, 20);
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-self.headerBar.frame.size.height) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]]];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
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
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.type = CELLBUS;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    MTBus * bus = [_data objectAtIndex:indexPath.row];
    
    cell.title = bus.BusNumberDisplay;
    cell.subtitle = bus.DisplayHeading;
    
    [cell update];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMTSEARCHCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_delegateQuick conformsToProtocol:@protocol(MTCardManagerQuickSelectDelegate)])
        [_delegateQuick quickSelect:self receivedClick:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end