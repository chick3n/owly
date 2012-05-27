//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardManagerQuickSelect.h"

@implementation MTCardManagerQuickSelect
@synthesize data = _data;
@synthesize delegateQuick = _delegateQuick;
@synthesize tableView = _tableView;
@synthesize headerBar = _headerBar;
@synthesize stopFavorite = _stopFavorite;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _stopFavorite = NO;
        
        //self.headerBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_pullbar.png"]];
        self.headerBar = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headerBar setImage:[UIImage imageNamed:@"global_pullbar.jpg"] forState:UIControlStateNormal];        
        self.headerBar.frame = CGRectMake(0, frame.size.height-kBarHeight, 320, kBarHeight);
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-self.headerBar.frame.size.height) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        //[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_light_background.png"]]];
        [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"global_lightbackground_tile.jpg"]]];
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
    return (_data == nil) ? 0 : _data.count + 1; //+1 is the button for saving a stop 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCardCell";
    
    MTSearchCell *cell = (MTSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.type = CELLBUS;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundImage.image = [UIImage imageNamed:@"global_searchfilter_bg.jpg"];
    }
        
    cell.accessoryType = UITableViewCellAccessoryNone;
    if(indexPath.row != 0)
    {
        MTBus * bus = [_data objectAtIndex:indexPath.row-1];
        
        cell.title = bus.BusNumberDisplay;
        cell.subtitle = bus.DisplayHeading;
        cell.type = CELLBUS;
        cell.backgroundImage.hidden = YES;
        
        [cell toggleSubtitle2:YES];
        
        [cell update];
    }
    else {
        cell.title = @"";
        cell.subtitle = (_stopFavorite) ? NSLocalizedString(@"FAVORITESTOPREMOVE", nil) : NSLocalizedString(@"FAVORITESTOP", nil);
        
        cell.backgroundImage.hidden = NO;
        cell.type = CELLFAVORITE;
        //[cell hideBusImage:YES];
        
        [cell toggleSubtitle2:NO];
        
        [cell update];
        
        if(_stopFavorite)
            [cell updateBusImage:@"stop_heart_selected.png"];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMTSEARCHCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        if([_delegateQuick conformsToProtocol:@protocol(MTCardManagerQuickSelectDelegate)])
            [_delegateQuick quickSelectFavoriteStop:self];
        return;
    }
    
    if([_delegateQuick conformsToProtocol:@protocol(MTCardManagerQuickSelectDelegate)])
        [_delegateQuick quickSelect:self receivedClick:indexPath.row - 1];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end