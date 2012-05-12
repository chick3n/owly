//
//  MTCard.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-19.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCard.h"

@interface MTCard ()
- (void)initializeUI;
@end

@implementation MTCard
@synthesize delegate                = _delegate;
@synthesize stop                    = _stop;
@synthesize bus                     = _bus;
@synthesize numOfPages              = _numOfPages;
@synthesize currentPage             = _currentPage;

- (id)initWithLanguage:(MTLanguage)language
{
    self = [super initWithFrame:kMTCardSize];
    if(self)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MTCard" owner:self options:nil];
        [self addSubview:[topLevelObjects objectAtIndex:0]];
        _language = language;
        [self initializeUI];
    }
    
    return self;
}

- (id)initWithoutDetailsViewWithLanguage:(MTLanguage)language
{
    _hideDetailsView = YES;
    return [self initWithLanguage:language];
}

- (id)initWithoutDetailsViewAndPagingWithLanguage:(MTLanguage)language
{
    _hidePaging = YES;
    _hideDetailsView = YES;
    return [self initWithLanguage:language];
}

- (id)initWithoutPagingWithLanguage:(MTLanguage)language
{
    _hidePaging = YES;
    return [self initWithLanguage:language];
}

- (void)initializeUI
{
    _backgroundImage.image = [[UIImage imageNamed:@"card_background_test.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    _loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = _loader.frame;
    frame.origin.x = (self.frame.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2);
    _loader.frame = frame;
    [_loader startAnimating];
    [self addSubview:_loader];    
    
    _prevHeading.text = NSLocalizedString(@"MTDEF_CARDPREVIOUS", nil);
    _nextHeading.text = NSLocalizedString(@"MTDEF_CARDNEXT", nil);
    _distanceHeading.text = NSLocalizedString(@"MTDEF_CARDDISTANCE", nil);
    _directionHeading.text = NSLocalizedString(@"MTDEF_CARDDIRECTION", nil);
}

- (BOOL)updateCardForStop:(MTStop*)stop AndBus:(MTBus*)bus
{
    _stop = stop;
    _bus = bus;
    
    return [self updateCard];
}

- (BOOL)updateCard
{
#if 0
    NSArray *syms = [NSThread  callStackSymbols]; 
    if ([syms count] > 1) { 
        NSLog(@"Update Card: %@ - caller: %@ ", _bus.BusNumberDisplay,[syms objectAtIndex:1]);
    } else {
        NSLog(@"Update Card: %@ - %@", _bus.BusNumberDisplay, NSStringFromSelector(_cmd)); 
    }
#endif
    [_loader stopAnimating];
    
    if(_stop == nil || _bus == nil)
        return NO;
    
    [self updateBusNumber:_bus.BusNumberDisplay];
    [self updateBusHeading:_bus.DisplayHeading];
    [self updateStreetName:_stop.StopNameDisplay];
    
    if(!_hideDetailsView)
    {
#if 0
        [self updatePrevTime:_bus.PrevTime];
        [self updateNextTime:_bus.NextTime IsLive:_bus.GPSTime];
#endif
        [self updatePrevTime:_bus.PrevTimeDisplay];
        [self updateNextTime:[_bus.NextTimeDisplay getTimeForDisplay] IsLive:NO];
        [self updateDirection:[_bus getBusHeadingShortForm]];
        [self updateDistance:[_stop getDistanceOfStop]];
    }
    
    //[self clearData];
    [self updateWeekdayTimes:[_bus getWeekdayTimesForDisplay]];
    [self updateSaturdayTimes:[_bus getSaturdayTimesForDisplay]];
    [self updateSundayTimes:[_bus getSundayTimesForDisplay]];
    [_tableView reloadData];
    
    return NO;
}

#pragma mark - DATA BAR DELEGATE

#pragma mark - Navigation Bar Delegate

- (void)MTCardNavigationBarNextClicked
{
    
}

- (void)MTCardNavigationBarPrevClicked
{
    
}

#pragma mark - Title bar / Header

- (void)updateBusHeading:(NSString *)heading
{
    [_busHeading setText:heading];
}

- (void)updateBusNumber:(NSString *)busNumber
{
    [_busNumber setText:busNumber];
}

- (void)updateStreetName:(NSString *)name
{
    [_stopStreet setText:name];
}

#pragma mark - Details Bar

- (void)updatePrevTime:(NSString *)time
{
    [_prevTime setText:time];
}

- (void)updateNextTime:(NSString *)time IsLive:(BOOL)live
{
    [_nextTime setText:time];
}

- (void)updateDirection:(NSString *)direction
{
    [_direction setText:direction];
}

- (void)updateDistance:(NSString *)distance
{
    [_distance setText:distance];
}



- (void)updateWeekdayTimes:(NSArray*)times
{
    //[self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDWEEKDAY", nil)];
    _timesWeekday = [_bus getWeekdayTimesForDisplay];
}

- (void)updateSundayTimes:(NSArray*)times
{
    //[self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDSUNDAY", nil)];
    _timesSunday = [_bus getSundayTimesForDisplay];
}

- (void)updateSaturdayTimes:(NSArray*)times
{
    //[self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDSATURDAY", nil)];
    _timesSaturday = [_bus getSaturdayTimesForDisplay];
}

- (void)clearDataForQuickScrolling
{
#if 0
    _prevTime.text = @"";
    _nextTime.text = @"";
    _distance.text = @"";
    _direction.text = @"";
#endif
    _timesSunday = nil;
    _timesSaturday = nil;
    _timesWeekday = nil;
    [_tableView reloadData];
}

- (void)cleanUp
{
    [self clearDataForQuickScrolling];
}

- (void)toggleLoading:(BOOL)toggle
{
    if(toggle)
        [_loader startAnimating];
    else [_loader stopAnimating];
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
    
    MTCardRowCell* cell = (MTCardRowCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(cell == nil)
    {
        cell = (MTCardRowCell*)[[MTCardRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
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
    
    [cell updateRowLabelsRow1:(sequencedRow < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow] : nil
                         Row2:(sequencedRow+1 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+1] : nil 
                         Row3:(sequencedRow+2 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+2] : nil  
                         Row4:(sequencedRow+3 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+3] : nil  
                         Row5:(sequencedRow+4 < totalRows) ? (NSString*)[times objectAtIndex:sequencedRow+4] : nil 
     ];
    [cell updateRowBackgroundColor:(BOOL)(indexPath.row & 0x1)];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCardRowCellHeight;
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
    
    UIImageView* categoryBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_category_bar.jpg"]];
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
    return 23;
}

#pragma mark - Navigation Bar

- (IBAction)prevClicked:(id)sender
{
    [_delegate MTCardPrevClicked];
}

- (IBAction)nextClicked:(id)sender
{
    [_delegate MTCardNextClicked];
}

- (void)hideNavigationButtonsPrev:(BOOL)prev AndNext:(BOOL)next
{
    _prevButton.hidden = prev;
    _nextButton.hidden = next;
}

@end
