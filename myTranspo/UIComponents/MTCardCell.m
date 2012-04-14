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
    CGRect frame = _detailsView.frame;
    frame.origin.y -= _titleView.frame.size.height - frame.size.height + 24;
    _detailsView.frame = frame;
    
    _detailsView.hidden = NO;
    _arrowImage.hidden = YES;
    
    _prevHeading.text = NSLocalizedString(@"MTDEF_CARDPREVIOUS", nil);
    _nextHeading.text = NSLocalizedString(@"MTDEF_CARDNEXT", nil);
    _distanceHeading.text = NSLocalizedString(@"MTDEF_CARDDISTANCE", nil);
    _directionHeading.text = NSLocalizedString(@"MTDEF_CARDDIRECTION", nil);
    
    _dataScrollView.contentSize = CGSizeMake(_dataScrollView.frame.size.width * 2, _dataScrollView.frame.size.height);
   // _dataScrollView.delegate = self;
    
    //page 1
    _nextTimes = [[NSMutableArray alloc] initWithCapacity:kElementNextTimesCount*kElementNextTimesElementCount];
    CGRect nextTimesFooterFrame = _prevHeading.frame;
    CGRect nextTimesImagesFrame = kElementNextTimesImageRect;
    CGRect nextTimesLabelFrame = _prevTime.frame;
    
    nextTimesLabelFrame.origin.x += _dataScrollView.frame.size.width;
    nextTimesFooterFrame.origin.x += _dataScrollView.frame.size.width;
    nextTimesImagesFrame.origin.x += _dataScrollView.frame.size.width;
    
    for(int page1 = 0; page1 < kElementNextTimesCount; page1++)
    {
        UIImageView* nextTimeImage = [[UIImageView alloc] initWithFrame:nextTimesImagesFrame];
        nextTimeImage.image = [UIImage imageNamed:@"cardcell_next_icon.png"];
        nextTimeImage.contentMode = UIViewContentModeCenter;
        [_nextTimes addObject:nextTimeImage];
        
        UIButton* nextTime = [[UIButton alloc] initWithFrame:nextTimesLabelFrame];
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
        nextTimeFooter.text = _nextHeading.text;
        nextTimeFooter.shadowColor = _nextHeading.shadowColor;
        nextTimeFooter.shadowOffset = _nextHeading.shadowOffset;
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
    
    _busNumber.text = stop.Bus.BusNumber;
    _busHeading.text = stop.Bus.DisplayHeading;
    _streetName.text = stop.StopName;
    
    if(stop.IsUpdating)
    {
        [self toggleLoadingAnimation:YES];
    }
    else [self toggleLoadingAnimation:NO];
}

- (void)updateCellDetails:(MTStop*)stop New:(BOOL)newData
{
    //details have changed scroll back
    [_dataScrollView setContentOffset:CGPointMake(0, 0) animated:YES];    
    
    _stop = stop;
    
    _prevTime.text = stop.Bus.PrevTime;
    _direction.text = [stop.Bus getBusHeadingShortForm];
    _distance.text = [stop getDistanceOfStop];
    
    _nextTimeValue = stop.Bus.NextTime;
    [_nextTime setTitle:_nextTimeValue forState:UIControlStateNormal];
    [self viewForPage:1];
    
    [self toggleLoadingAnimation:NO];
    
    if(newData)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _prevTime.alpha = 0.0;
            _nextTime.alpha = 0.0;
            _distance.alpha = 0.0;
        } completion:^(BOOL finished){
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
    
    _modeLarge = YES;
    [self toggleLoadingAnimation:NO];
    
    //_titleBackground.image = [UIImage imageNamed:@"cardcell_top_background.png"];
    
#if 0
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, _titleBackground.frame.size.height, _detailsView.frame.size.width, _detailsView.frame.size.height));
    
    CAShapeLayer* mask = [CAShapeLayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"cardcell_top_background.png"] CGImage];
    //mask.fillColor = [[UIColor whiteColor] CGColor];
    //mask.backgroundColor = [[UIColor clearColor] CGColor];
    //mask.frame = _detailsView.bounds;
    mask.path = path;
    _detailsView.layer.mask = mask;
    
    CGRect titleBackgroundFrame = _titleBackground.frame;
    titleBackgroundFrame.origin.y -= 15;
    _titleBackground.frame = titleBackgroundFrame;
    
#endif

        
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
    
    CGRect frame = _detailsView.frame;
    frame.origin.y = _titleBackground.frame.origin.y + (_titleBackground.frame.size.height - 3);
    
    if(animate)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _detailsView.frame = frame;
        }];
    }
    else
    {
        _detailsView.frame = frame;
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
    
    if(_remaingTimeShown == NO)
    {
        [_nextTime setTitle:[MTHelper timeRemaingUntilTime:_nextTimeValue] forState:UIControlStateNormal];
        _remaingTimeShown = YES;
    }
    else
    {
        [_nextTime setTitle:_nextTimeValue forState:UIControlStateNormal];
        _remaingTimeShown = NO;
    }
}

#pragma mark - ScrollView Delegate

#if 0
// When animation stops using setContentOffset
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    int page = floor((_dataScrollView.contentOffset.x - _dataScrollView.frame.size.width / 2) / _dataScrollView.frame.size.width) + 1;
    
    if(page > 0)
    {
        [self viewForPage:page];
    }
}

// When animation stops using dragging
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int page = floor((_dataScrollView.contentOffset.x - _dataScrollView.frame.size.width / 2) / _dataScrollView.frame.size.width) + 1;
    
    if(page > 0)
    {
        [self viewForPage:page];
    }
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
            
        NSArray* times = [bus getNextTimesOfAmount:3];
        
        if(times == nil || times.count <= 0)
        {
            [self pageOneHelperEmptyTimes];
            return;
        }
        
        for(int x=0, ele=0; ele<_nextTimes.count; x++, ele+=kElementNextTimesElementCount)
        {
            MTTime* time = nil;
            if(x < times.count)
                time = [times objectAtIndex:x];
            
            UIButton* nextTime = [_nextTimes objectAtIndex:ele+1];
            if(time == nil)
            {
                [nextTime setTitle:MTDEF_TIMEUNKNOWN forState:UIControlStateNormal];
                [_nextTimes replaceObjectAtIndex:ele+3 withObject:MTDEF_TIMEUNKNOWN];
                continue;
            }
            
            [nextTime setTitle:[time getTimeForDisplay] forState:UIControlStateNormal];
            [_nextTimes replaceObjectAtIndex:ele+3 withObject:[time getTimeForDisplay]];
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
    UIButton* nextTime = (UIButton*)sender;
    
    if([nextTime.titleLabel.text characterAtIndex:nextTime.titleLabel.text.length-1] == 'm')
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
}

@end
