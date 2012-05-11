//
//  MTCardCell.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardCell.h"

@interface MTCardCell ()
- (void)viewForPage:(int)page;
- (void)pageOneHelperEmptyTimes;
- (void)nextTimesClicked:(id)sender;
- (void)updateNextTimes:(NSArray*)nextTimes;
- (void)updateSpeed:(NSString*)speed;
- (void)beginSingleCellLoading;
- (void)endSingleCellLoading;
@end

@implementation MTCardCell
@synthesize delegate =          _delegate;
@synthesize language =          _language;
@synthesize indexRow =          _indexRow;
@synthesize stop =              _stop;
@synthesize hasExpanded =       _hasExpanded;
@synthesize isExpanding =       _isExpanding;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLanguage:(MTLanguage)language
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTCardCell" owner:self options:nil];
        [self addSubview:[mtCardCellXib objectAtIndex:0]];
        _language = language;
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeUI
{       
    _singleCellAnimating = YES;
    _isExpanding = NO;
    _hasExpanded = NO;
    _detailsView.hidden = NO;
    _arrowImage.hidden = YES;    
    
    CGRect frame = _detailsBackground.frame;
    CGRect scrollFrame = _dataScrollView.frame;
    CGRect deleteFrame = _delete.frame;
    //CGRect detailsFrame = _detailsView.frame;
    
    frame.origin.y = 0 - 42;
    scrollFrame.origin.y = 0 - 42;
    deleteFrame.origin.x = 52;
    //detailsFrame.size.height = 10;
    
    _detailsBackground.frame = frame;
    _dataScrollView.frame = scrollFrame;
    _delete.frame = deleteFrame;
    //_detailsView.frame = detailsFrame;    
    
    _prevHeading.text = NSLocalizedString(@"MTDEF_CARDPREVIOUS", nil);
    _nextHeading.text = NSLocalizedString(@"MTDEF_CARDNEXT", nil);
    _distanceHeading.text = NSLocalizedString(@"MTDEF_CARDDISTANCE", nil);
    _directionHeading.text = NSLocalizedString(@"MTDEF_CARDDIRECTION", nil);
    
    _dataScrollView.contentSize = CGSizeMake(_dataScrollView.frame.size.width, _dataScrollView.frame.size.height);
    
    _nextTime.useSecondaryHeading = NO;
    _nextTime.useHelperHeading = NO;
    
    //page 1
    _nextTimes = [[NSMutableArray alloc] initWithCapacity:kElementNextTimesCount*kElementNextTimesElementCount];
    CGRect nextTimesFooterFrame = _prevHeading.frame;
    CGRect nextTimesImagesFrame = kElementNextTimesImageRect;
    CGRect nextTimesLabelFrame = _prevTime.frame;
    
    nextTimesLabelFrame.origin.x -= 4;
    
    nextTimesLabelFrame.origin.x += _dataScrollView.frame.size.width;
    nextTimesFooterFrame.origin.x += _dataScrollView.frame.size.width;
    nextTimesImagesFrame.origin.x += _dataScrollView.frame.size.width;
    
    for(int page1 = 0; page1 < kElementNextTimesCount; page1++)
    {
        UIImageView* nextTimeImage = [[UIImageView alloc] initWithFrame:nextTimesImagesFrame];
        nextTimeImage.image = [UIImage imageNamed:@"cardcell_next_icon.png"];
        nextTimeImage.contentMode = UIViewContentModeCenter;
        [_nextTimes addObject:nextTimeImage];
        
        MTCellButton* nextTime = [[MTCellButton alloc] initWithFrame:nextTimesLabelFrame];
        nextTime.useHelperHeading = YES;
        nextTime.useSecondaryHeading = NO;
        nextTime.titleLabel.font = _prevTime.font;
        nextTime.backgroundColor = _prevTime.backgroundColor;
        nextTime.titleLabel.textAlignment = _prevTime.textAlignment;
        [nextTime setTitleColor:_prevTime.textColor forState:UIControlStateNormal];
        [nextTime setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [nextTime addTarget:self action:@selector(nextTimesClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_nextTimes addObject:nextTime];
        
        UILabel* nextTimeFooter = [[UILabel alloc] initWithFrame:nextTimesFooterFrame];
        nextTimeFooter.font = _prevHeading.font;
        nextTimeFooter.backgroundColor = _prevHeading.backgroundColor;
        nextTimeFooter.textAlignment = _prevHeading.textAlignment;
        nextTimeFooter.textColor = _prevHeading.textColor;
        nextTimeFooter.shadowColor = _nextHeading.shadowColor;
        nextTimeFooter.shadowOffset = _nextHeading.shadowOffset;
        CGRect footerAdjusterFrame = nextTimeFooter.frame;
        switch (page1) {
            case 1:
                nextTimeFooter.text = NSLocalizedString(@"BUS3AWAY", nil);
                footerAdjusterFrame.origin.x += 12;
                break;
            default:
                nextTimeFooter.text = NSLocalizedString(@"BUSFOLLOWING", nil);
                footerAdjusterFrame.origin.x += 4;
                break;
        }
        nextTimeFooter.frame = footerAdjusterFrame;
        [_nextTimes addObject:nextTimeFooter];
        
        NSString* setTime = MTDEF_TIMEUNKNOWN;
        [_nextTimes addObject:setTime];
        
        nextTimesLabelFrame.origin.x += kElementNextTimesSpacer;
        nextTimesFooterFrame.origin.x += kElementNextTimesSpacer;
        nextTimesImagesFrame.origin.x += kElementNextTimesSpacer;
        
        [_dataScrollView addSubview:nextTimeImage];
        [_dataScrollView addSubview:nextTime];
        [_dataScrollView addSubview:nextTimeFooter];
    }
    
    //page 2 speed, bus type, etc
    _moreDetails = [[NSMutableArray alloc] initWithCapacity:kElementMoreDetailsElementCount];
    nextTimesLabelFrame.origin.x += 4;
    for(int page2 = 0; page2 < kElementMoreDetailsCount; page2++)
    {
        UIImageView* moreDetailsImage = [[UIImageView alloc] initWithFrame:nextTimesImagesFrame];
        moreDetailsImage.image = [UIImage imageNamed:@"cardcell_speed_icon.png"];
        moreDetailsImage.contentMode = UIViewContentModeCenter;
        [_moreDetails addObject:moreDetailsImage];
        
        UILabel* moreDetailsLabel = [[UILabel alloc] initWithFrame:nextTimesLabelFrame];
        moreDetailsLabel.font = _prevTime.font;
        moreDetailsLabel.backgroundColor = _prevTime.backgroundColor;
        moreDetailsLabel.textAlignment = _prevTime.textAlignment;
        moreDetailsLabel.textColor = _prevTime.textColor;
        [_moreDetails addObject:moreDetailsLabel];
        
        UILabel* moreDetailsFooter = [[UILabel alloc] initWithFrame:nextTimesFooterFrame];
        moreDetailsFooter.font = _prevHeading.font;
        moreDetailsFooter.backgroundColor = _prevHeading.backgroundColor;
        moreDetailsFooter.textAlignment = _prevHeading.textAlignment;
        moreDetailsFooter.textColor = _prevHeading.textColor;
        moreDetailsFooter.shadowColor = _nextHeading.shadowColor;
        moreDetailsFooter.shadowOffset = _nextHeading.shadowOffset;
        CGRect footerAdjusterFrame = moreDetailsFooter.frame;
        switch (page2) {
            case 0:
                moreDetailsFooter.text = NSLocalizedString(@"SPEED", nil);
                footerAdjusterFrame.origin.x += 12;
                break;
        }
        moreDetailsFooter.frame = footerAdjusterFrame;
        [_moreDetails addObject:moreDetailsFooter];
        
        nextTimesLabelFrame.origin.x += kElementNextTimesSpacer;
        nextTimesFooterFrame.origin.x += kElementNextTimesSpacer;
        nextTimesImagesFrame.origin.x += kElementNextTimesSpacer;
        
        [_dataScrollView addSubview:moreDetailsImage];
        [_dataScrollView addSubview:moreDetailsLabel];
        [_dataScrollView addSubview:moreDetailsFooter];
    }
    
    _dataScrollView.contentSize = CGSizeMake((nextTimesLabelFrame.origin.x + nextTimesLabelFrame.size.width) - kElementNextTimesSpacer
                                             , _dataScrollView.frame.size.height);
    
#if 1
    _timesAlert = [[MTCellAlert alloc] init];
    _timesAlert.hasButtons = NO;
    [self addSubview:_timesAlert];
#endif
    
    //add scroll to refresh
    _refreshLabel = [[UILabel alloc] initWithFrame:_prevHeading.frame];
    _refreshLabel.backgroundColor = _prevHeading.backgroundColor;
    _refreshLabel.font = _prevHeading.font;
    _refreshLabel.textColor = _prevHeading.textColor;
    _refreshLabel.shadowColor = _prevHeading.shadowColor;
    _refreshLabel.shadowOffset = _prevHeading.shadowOffset;
    _refreshLabel.text = NSLocalizedString(@"SHORTFORMPULLTOREFRESH", nil);
    
    CGRect refreshLabelFrame = _refreshLabel.frame;
    refreshLabelFrame.origin.x = kScrollToRefreshPoint;
    _refreshLabel.frame = refreshLabelFrame;
    [_dataScrollView addSubview:_refreshLabel];
    
    UIImageView *refreshBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_refresh_bg.png"]];
    CGRect refreshBGFrame = refreshBackground.frame;
    refreshBGFrame.origin.x = _refreshLabel.frame.origin.x + 20;
    refreshBGFrame.origin.y = 10;
    refreshBackground.frame = refreshBGFrame;
    [_dataScrollView addSubview:refreshBackground];
    
    _refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_refresh_arrow.png"]];
    CGRect refreshArrowFrame = _refreshArrow.frame;
    refreshArrowFrame.origin.x = refreshBackground.frame.origin.x + 4;// + ((_refreshLabel.frame.size.width / 2) - (_refreshArrow.frame.size.width / 2));
    refreshArrowFrame.origin.y = 14;
    _refreshArrow.frame = refreshArrowFrame;
    [_dataScrollView addSubview:_refreshArrow];
    
}

- (NSInteger)getCellHeight
{
    if(_modeLarge)
        return kFullHeight;
    return kHiddenHeight;
}

- (void)updateCellMode:(BOOL)large
{
    _modeLarge = large;
    
    if(large)
    {
        [_loadingAnimation stopAnimating];
        _arrowImage.hidden = NO;
    }
}

- (void)updateCellBusNumber:(NSString*)busNumber AndBusDisplayHeading:(NSString*)busDisplayHeading AndStopStreentName:(NSString*)stopStreetName
{
    _busNumber.text = busNumber;
    _busHeading.text = busDisplayHeading;
    _streetName.text = stopStreetName;
}

- (void)updateCellHeader:(MTStop*)stop
{
    _stop = stop;
    
    _busNumber.text = stop.Bus.BusNumberDisplay;
    _busHeading.text = (stop.Bus.TrueDisplayHeading != nil) ? stop.Bus.TrueDisplayHeading : stop.Bus.DisplayHeading;
    _streetName.text = stop.StopNameDisplay;
    
    if(stop.IsUpdating)
    {
        [self toggleLoadingAnimation:YES];
    }
    else [self toggleLoadingAnimation:NO];
}

- (void)updateCellDetails:(MTStop*)stop New:(BOOL)newData
{
#if 0
    if(_stop == stop && newData == NO)
        return; //no need for an update!
#endif
    //details have changed scroll back
    [_timesAlert hideAlertWithSelfInvoke:YES];
    [_dataScrollView setContentOffset:CGPointMake(0, 0) animated:YES];    
    
    stop.MTCardCellHelper = NO;
    _stop = stop;
    
    _prevTime.text = stop.Bus.PrevTimeDisplay;//stop.Bus.PrevTime;
    _direction.text = [stop.Bus getBusHeadingShortForm];
    _distance.text = [stop getDistanceOfStop];
    
    _nextTimeValue = [stop.Bus.NextTimeDisplay getTimeForDisplay];//stop.Bus.NextTime;
    _nextTime.originalHeading = _nextTimeValue;
    _nextTime.helperHeading = stop.Bus.NextTimeDisplay.EndStopHeader;
    [_nextTime setTitle:_nextTimeValue forState:UIControlStateNormal];
    [self viewForPage:1];
    [self viewForPage:2];
    
    [self toggleLoadingAnimation:NO];
    
    if(newData)
    {
        _prevTime.alpha = 0.0;
        _nextTime.alpha = 0.0;
        _distance.alpha = 0.0;
    
        [UIView animateWithDuration:0.25 animations:^{
            _prevTime.alpha = 1.0;
            _nextTime.alpha = 1.0;
            _distance.alpha = 1.0;
        }];
    }
}

- (void)updateCellPrevTime:(NSString*)prevTime AndDistance:(NSString*)distance AndDirection:(NSString*)direction AndNextTime:(MTTime*)nextTime AndNextTimes:(NSArray*)nextTimes AndSpeed:(NSString*)speed
{
    [_timesAlert hideAlertWithSelfInvoke:YES];
    
    _prevTime.text = prevTime;
    _direction.text = direction;
    _distance.text = distance;
    
    _nextTimeValue = [nextTime getTimeForDisplay];//stop.Bus.NextTime;
    _nextTime.originalHeading = _nextTimeValue;
    _nextTime.helperHeading = nextTime.EndStopHeader;
    [_nextTime setTitle:_nextTimeValue forState:UIControlStateNormal];
    
    [self updateNextTimes:nextTimes];
    [self updateSpeed:speed];
}

- (void)updateCellDetailsWithFlash
{
    _prevTime.alpha = 0.0;
    _nextTime.alpha = 0.0;
    _distance.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        _prevTime.alpha = 1.0;
        _nextTime.alpha = 1.0;
        _distance.alpha = 1.0;
    }];
}

- (void)updateCellDetailsAnimation:(BOOL)animate
{
    CGRect detailsBackgroundFrame = _detailsBackground.frame;
    CGRect detailsScrollView = _dataScrollView.frame;
    
    if(detailsScrollView.origin.y == 0 || detailsBackgroundFrame.origin.y == 0)
        return;
    
    detailsBackgroundFrame.origin.y = 0;
    detailsScrollView.origin.y = 0;
    
    _isExpanding = YES;
    
    if(animate)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _detailsBackground.frame = detailsBackgroundFrame;
                             _dataScrollView.frame = detailsScrollView;
                         } completion:^(BOOL finished) {
                             if(finished)
                             {
                                 _hasExpanded = YES;
                                 _isExpanding = NO;
                             }
                             
                         }];
    }
    else {
        _detailsBackground.frame = detailsBackgroundFrame;
        _dataScrollView.frame = detailsScrollView;
        _hasExpanded = YES;
        _isExpanding = NO;
    }
}

- (void)updateCellForIndividualUpdate:(BOOL)update
{
    UIEdgeInsets edgeInset = UIEdgeInsetsZero;
    
    if(update)
    {
        edgeInset = UIEdgeInsetsMake(0, (kScrollToRefreshPoint*-1), 0, 0);
    }
    else {
        edgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if(_singleCellAnimating)
            [self endSingleCellLoading];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _dataScrollView.contentInset = edgeInset;
                     }];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
#if 0
    if(frame.size.height != kFullHeight)
    {
        return;
    }
    
    CGRect detailsBackgroundFrame = _detailsBackground.frame;
    CGRect detailsScrollView = _dataScrollView.frame;
    
    if(detailsScrollView.origin.y == 0 || detailsBackgroundFrame.origin.y == 0)
        return;
    
    detailsBackgroundFrame.origin.y = 0;
    detailsScrollView.origin.y = 0;
    
    [UIView animateWithDuration:10.25
                     animations:^{
                         NSLog(@"Animating Cell Frame");
                         _detailsBackground.frame = detailsBackgroundFrame;
                         _dataScrollView.frame = detailsScrollView;
                     } completion:^(BOOL finished) {
                         if(finished)
                         {
                             NSLog(@"Animating Cell Frame Finished");
                             _hasExpanded = YES;
                         }
                         
                     }];
#endif
}

- (void)expandCellWithAnimation:(BOOL)animate
{
    if(_modeLarge)
        return;
    
    if(_hasExpanded)
        return;
    
    _modeLarge = YES;
    _hasExpanded = YES;
    _stop.MTCardCellIsAnimating = YES;
    
    [self toggleLoadingAnimation:NO];
    
    CGRect titleFrame = _busNumber.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busNumber.frame = titleFrame;
    
    titleFrame = _busHeading.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busHeading.frame = titleFrame;
    
    titleFrame = _busNumberBackground.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busNumberBackground.frame = titleFrame;
    
    titleFrame = _arrowImage.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _arrowImage.frame = titleFrame;
    
    titleFrame = _streetName.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _streetName.frame = titleFrame;
    
    CGRect frame = _detailsBackground.frame;
    CGRect scrollFrame = _dataScrollView.frame;
    //CGRect detailsFrame = _detailsView.frame;
    
    frame.origin.y = 1;
    //scrollFrame.origin.y = -40;
    //_dataScrollView.frame = scrollFrame;
    scrollFrame.origin.y = 0;
    //scrollFrame.size.height = kDataScrollViewFrameHeight;
    //detailsFrame.size.height = kDetailsViewFrameHeight;
    
    //_detailsView.frame = detailsFrame;
    
    if(animate && _stop.MTCardCellHelper == NO)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _detailsBackground.frame = frame;
            _dataScrollView.frame = scrollFrame;
        } completion:^(BOOL finished) {
            _stop.MTCardCellIsAnimating = NO;
            _stop.MTCardCellHelper = YES;
            //self.clipsToBounds = NO;
        }];
    }
    else
    {
        _detailsBackground.frame = frame;
        _dataScrollView.frame = scrollFrame;
        _stop.MTCardCellIsAnimating = NO;
        _stop.MTCardCellHelper = YES;
        //self.clipsToBounds = NO;
    }
}



- (BOOL)isCellUpdated
{
    return _modeLarge;
}

- (void)toggleLoadingAnimation:(BOOL)toggle
{
    if(toggle)
    {
        _arrowImage.hidden =YES;
        [_loadingAnimation startAnimating];
    }
    else 
    {
        _arrowImage.hidden = NO;
        [_loadingAnimation stopAnimating];   
    }
}

- (IBAction)nextTimeClicked:(id)sender
{
    //if([_delegate conformsToProtocol:@protocol(MTCardCellDelegate)])
    //    [_delegate mtCardCellnextTimeClickedForStop:_stop];
    
    CGPoint pointInCell = [self convertPoint:_nextTime.center fromView:_dataScrollView];
    _timesAlert.refrenceObject = _nextTime;
    
    NSString* heading = @"";
    
    //api time doesnt save that data
    if(_nextTime.helperHeading == nil)
        heading = _busHeading.text;
    else if(_nextTime.helperHeading.length <= 0)
        heading = _busHeading.text;
        
    [_timesAlert displayAlert:_nextTime.helperHeading AtPos:pointInCell ConstrainedTo:self.frame.size UpsideDown:NO];
    
#if 0
    if(_remaingTimeShown == NO)
    {
        //_busHeading.text = _stop.Bus.NextTimeDisplay.EndStopHeader;
        [_nextTime setTitle:[MTHelper timeRemaingUntilTime:_nextTimeValue] forState:UIControlStateNormal];
        _remaingTimeShown = YES;
    }
    else
    {
        //_busHeading.text = (_stop.Bus.TrueDisplayHeading != nil) ? _stop.Bus.TrueDisplayHeading : _stop.Bus.DisplayHeading;
        [_nextTime setTitle:_nextTimeValue forState:UIControlStateNormal];
        _remaingTimeShown = NO;
    }
#endif
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if(kScrollToRefreshPoint > scrollView.contentOffset.x)
        _refreshLabel.text = NSLocalizedString(@"SHORTFORMPULLTOREFRESH", nil);
    else _refreshLabel.text = NSLocalizedString(@"SHORTFORMPULLTOREFRESH", nil);
    
    if(!_isScrollingAutomatically)
        [_timesAlert hideAlertWithSelfInvoke:YES];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView 
                     withVelocity:(CGPoint)velocity 
              targetContentOffset:(inout CGPoint*)targetContentOffset
{
    if(scrollView.contentOffset.x <= kScrollToRefreshPoint)
    {
        if([_delegate conformsToProtocol:@protocol(MTCardCellDelegate)])
        {
            NSLog(@"Refreshing Cell");
            [UIView animateWithDuration:0.25 animations:^(void){
                scrollView.contentInset = UIEdgeInsetsMake(0, (kScrollToRefreshPoint*-1), 0, 0);
            }];
        
            [self beginSingleCellLoading];
            [_delegate cardCellRefreshRequestedForDisplayedData:self];
        }
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
    _isScrollingAutomatically = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
    _isScrollingAutomatically = NO;
}

- (void)viewForPage:(int)page
{
    if(page == 1) //show next times
    {
        if(_stop == nil)
        {
            [self pageOneHelperEmptyTimes];
            return;
        }
        
        MTBus* bus = _stop.Bus;
        if(bus == nil)
        {
            [self pageOneHelperEmptyTimes];
            return;
        }
            
        //NSArray* times = [bus getNextTimesOfAmount:kElementNextTimesCount+1 IncludeLiveTime:YES];
        NSArray* times = bus.NextThreeTimesDisplay;
        
        if(times == nil || times.count <= 0)
        {
            [self pageOneHelperEmptyTimes];
            return;
        }
        
        //skip first one as we have it already
        for(int x=1, ele=0; ele<_nextTimes.count; x++, ele+=kElementNextTimesElementCount)
        {
            MTTime* time = nil;
            if(x < times.count)
                time = [times objectAtIndex:x];
            
            MTCellButton* nextTime = (MTCellButton*)[_nextTimes objectAtIndex:ele+1];
            if(time == nil)
            {
                [nextTime setTitle:MTDEF_TIMEUNKNOWN forState:UIControlStateNormal];
                [_nextTimes replaceObjectAtIndex:ele+3 withObject:MTDEF_TIMEUNKNOWN];
                continue;
            }
            
            nextTime.helperHeading = time.EndStopHeader;
            [nextTime setTitle:[time getTimeForDisplay] forState:UIControlStateNormal];
            [_nextTimes replaceObjectAtIndex:ele+3 withObject:[time getTimeForDisplay]];
        }
    }
    else if(page == 2)
    {
        if(_stop.Bus == nil)
            return;
        
        NSString* speedValue = _stop.Bus.BusSpeed;
        UILabel* speed = [_moreDetails objectAtIndex:0+1];
        CGSize size = [speedValue sizeWithFont:speed.font];
        speed.text = _stop.Bus.BusSpeed;
        
        if(speed.frame.size.width < size.width)
        {
            CGRect speedFrame = speed.frame;
            speedFrame.size.width = size.width;
            speed.frame = speedFrame;
            
            _dataScrollView.contentSize = CGSizeMake(speedFrame.origin.x + speedFrame.size.width + 10, _dataScrollView.frame.size.height);
        }
    }
}

- (void)updateNextTimes:(NSArray*)nextTimes
{
    if(nextTimes == nil)
    {
        [self pageOneHelperEmptyTimes];
        return;
    }
    
    if(nextTimes.count <= 0)
    {
        [self pageOneHelperEmptyTimes];
        return;
    }
    
    //skip first one as we have it already
    for(int x=1, ele=0; ele<_nextTimes.count; x++, ele+=kElementNextTimesElementCount)
    {
        MTTime* time = nil;
        if(x < nextTimes.count)
            time = [nextTimes objectAtIndex:x];
        
        MTCellButton* nextTime = (MTCellButton*)[_nextTimes objectAtIndex:ele+1];
        if(time == nil)
        {
            [nextTime setTitle:MTDEF_TIMEUNKNOWN forState:UIControlStateNormal];
            [_nextTimes replaceObjectAtIndex:ele+3 withObject:MTDEF_TIMEUNKNOWN];
            continue;
        }
        
        nextTime.helperHeading = time.EndStopHeader;
        [nextTime setTitle:[time getTimeForDisplay] forState:UIControlStateNormal];
        [_nextTimes replaceObjectAtIndex:ele+3 withObject:[time getTimeForDisplay]];
    }
}

- (void)updateSpeed:(NSString*)speed
{
    UILabel* speedLabel = [_moreDetails objectAtIndex:0+1];
    
    if(speed == nil)
    {
        speedLabel.text = MTDEF_STOPDISTANCEUNKNOWN;
        return;
    }
    
    CGSize size = [speed sizeWithFont:speedLabel.font];
    speedLabel.text = speed;
    
    if(speedLabel.frame.size.width < size.width)
    {
        CGRect speedFrame = speedLabel.frame;
        speedFrame.size.width = size.width;
        speedLabel.frame = speedFrame;
        
        _dataScrollView.contentSize = CGSizeMake(speedFrame.origin.x + speedFrame.size.width + 10, _dataScrollView.frame.size.height);
    }
}

- (void)pageOneHelperEmptyTimes
{
    for(int ele=0; ele<_nextTimes.count; ele+=kElementNextTimesElementCount)
    {        
        UIButton* nextTime = [_nextTimes objectAtIndex:ele+1];
        [nextTime setTitle:MTDEF_TIMEUNKNOWN forState:UIControlStateNormal];
    }
}

- (void)nextTimesClicked:(id)sender
{
    MTCellButton* nextTime = (MTCellButton*)sender;
    
    //determine if the btton is half hidden and scroll over the remaining amount
    CGFloat scrollBy = 0.0;
    if((nextTime.frame.origin.x + nextTime.frame.size.width) > (_dataScrollView.contentOffset.x + _dataScrollView.frame.size.width))
    {        
        scrollBy = (nextTime.frame.origin.x + nextTime.frame.size.width) - (_dataScrollView.contentOffset.x + _dataScrollView.frame.size.width);
        CGRect scrollOffset = _dataScrollView.frame;
        scrollOffset.origin = _dataScrollView.contentOffset;
        scrollOffset.origin.x += scrollBy;
        
        _isScrollingAutomatically = YES;
        [_dataScrollView scrollRectToVisible:scrollOffset animated:YES];
    }
    
    
    
    CGPoint pointInCell = [self convertPoint:nextTime.center fromView:_dataScrollView];
    pointInCell.x -= scrollBy;
    _timesAlert.refrenceObject = nextTime;
    [_timesAlert displayAlert:nextTime.helperHeading AtPos:pointInCell ConstrainedTo:self.frame.size UpsideDown:NO];

#if 0    
    char lastChar = [nextTime.titleLabel.text characterAtIndex:nextTime.titleLabel.text.length-1];
    
    if(lastChar == 'm' || lastChar == '+' || lastChar == 'w')
    {
        for(int ele=0; ele<_nextTimes.count; ele+=kElementNextTimesElementCount)
        {        
            UIButton* tmpTime = [_nextTimes objectAtIndex:ele+1];
            if(tmpTime == nextTime)
            {
                [nextTime setTitle:[_nextTimes objectAtIndex:ele+3] forState:UIControlStateNormal];
                break;
            }
        }
    }
    else
    {
        NSString *nextTimeString = nextTime.titleLabel.text;
        [nextTime setTitle:[MTHelper timeRemaingUntilTime:nextTimeString] forState:UIControlStateNormal];
    }
#endif
}

#pragma mark - EDIT / DELETE MODE

#if 0
- (void)layoutSubviews
{
//    [super layoutSubviews];
    
    if(self.editing)
        self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width
                                            , self.contentView.frame.size.height);
}

#endif

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated]; //auto indents ???
    
    if(editing)
        [self editMode:nil];
    else [self defaultMode:nil];
    
}

- (void)editMode:(id)sender
{
    if(_isAnimatingEdit)
        return;
    
    _isAnimatingEdit = YES;
    _delete.hidden = NO;
    _dataScrollView.scrollEnabled = NO;
    _dataScrollView.contentOffset = CGPointMake(0, 0);
    
    CGRect deleteFrame = _delete.frame;
    deleteFrame.origin.x = 0;
    
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         _delete.frame = deleteFrame;
                     } completion:^(BOOL finished) {
                         _isAnimatingEdit = NO;
                     }];
}

- (void)defaultMode:(id)sender
{
    if(_isAnimatingEdit)
        return;
    
    _isAnimatingEdit = YES;
    _dataScrollView.scrollEnabled = YES;
    
    CGRect deleteFrame = _delete.frame;
    deleteFrame.origin.x = 52;
    
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         _delete.frame = deleteFrame;
                     } completion:^(BOOL finished) {
                         _delete.hidden = YES;
                         _isAnimatingEdit = NO;
                     }];
}


- (IBAction)deleteClicked:(id)sender
{
    if([_delegate conformsToProtocol:@protocol(MTCardCellDelegate)])
        [_delegate mtCardcellDeleteClicked:self];
}

#pragma mark - Single Cell Loading

- (void)beginSingleCellLoading
{
    _singleCellAnimating = YES;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1]; //use -1 for clockwise instead of 1
    rotationAnimation.duration = 0;
    rotationAnimation.speed = 0.5;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.repeatCount = HUGE_VALF;
    [_refreshArrow.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)endSingleCellLoading
{
    _singleCellAnimating = NO;
    [_refreshArrow.layer removeAnimationForKey:@"rotationAnimation"];
}

@end
