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

@end

@implementation MTCardCell
@synthesize delegate =          _delegate;
@synthesize language =          _language;
@synthesize indexRow =          _indexRow;
@synthesize stop =              _stop;

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
    _hasExpanded = NO;
    _detailsView.hidden = NO;
    _arrowImage.hidden = YES;    
    
    CGRect frame = _detailsBackground.frame;
    CGRect scrollFrame = _dataScrollView.frame;
    CGRect deleteFrame = _delete.frame;
    //CGRect detailsFrame = _detailsView.frame;
    
    frame.origin.y = 0 - 40;
    scrollFrame.origin.y = 0 - 40;
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
    [_dataScrollView setContentOffset:CGPointMake(0, 0) animated:YES];    
    
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
    if(_timesAlert.hidden == NO)
    {
        CGRect timesAlertFrame = _timesAlert.frame;
        timesAlertFrame.origin.x += _lastContentOffset.x - scrollView.contentOffset.x;
        _timesAlert.frame = timesAlertFrame;
        _lastContentOffset = scrollView.contentOffset;
    }
    
#if 0
    [_timesAlert hideAlertWithSelfInvoke:YES];
#endif
}

#if 1
// When animation stops using setContentOffset
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
}

// When animation stops using dragging
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
}
#endif

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
    
    CGPoint pointInCell = [self convertPoint:nextTime.center fromView:_dataScrollView];
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

@end
