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
- (void)clearData;
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
    _loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = _loader.frame;
    frame.origin.x = (self.frame.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2);
    _loader.frame = frame;
    [_loader startAnimating];
    [self addSubview:_loader];    
    
    if(_hideDetailsView)
    {
        CGRect frame = _scrollView.frame;
        frame.origin.y -= _detailsView.frame.size.height;
        frame.size.height += _detailsView.frame.size.height;
        _scrollView.frame = frame;
        
        _detailsView.hidden = YES;
    }
    
    if(_hidePaging)
    {
        CGRect frame = _scrollView.frame;
        frame.size.height += (_hideDetailsView) ? 80 : 40;
        _scrollView.frame = frame;
        
        _prevButton.hidden = YES;
        _nextButton.hidden = YES;
    }
    
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
    [_loader stopAnimating];
    
    if(_stop == nil || _bus == nil)
        return NO;
    
    [self updateBusNumber:_bus.BusNumberDisplay];
    [self updateBusHeading:_bus.DisplayHeading];
    [self updateStreetName:_stop.StopNameDisplay];
    
    if(!_hideDetailsView)
    {
        [self updatePrevTime:_bus.PrevTime];
        [self updateNextTime:_bus.NextTime IsLive:_bus.GPSTime];
        [self updateDirection:[_bus getBusHeadingShortForm]];
        [self updateDistance:[_stop getDistanceOfStop]];
    }
    
    [self clearData];
    [self updateWeekdayTimes:[_bus getWeekdayTimesForDisplay]];
    [self updateSaturdayTimes:[_bus getSaturdayTimesForDisplay]];
    [self updateSundayTimes:[_bus getSundayTimesForDisplay]];
    
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

#pragma mark - Data Bar

- (void)updateTimes:(NSArray *)times WithHeader:(NSString*)header
{
    uint leftPos = 0, topPos = _scrollViewContentHeight, tileWidth = 61, tileHeight = 28, rowSplit = 5;
    
    UIColor *tileColour = [UIColor whiteColor];
    UIColor *tileColourAlternate = [UIColor colorWithRed:247./255. green:247./255. blue:247./255. alpha:1.0];
    UIColor *timeColor = [UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0];
    UIColor *dividerColor = [UIColor colorWithRed:239./255. green:238./255. blue:236./255. alpha:1.0];
    
    UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue" size:12];

    UIImageView* categoryBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_category_bar.png"]];
    categoryBar.frame = CGRectMake(0, topPos, 302, 23);
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, categoryBar.frame.size.width - 24, categoryBar.frame.size.height - 7)];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = header;
    headerLabel.shadowColor = [UIColor colorWithRed:38./255. green:154./255. blue:201./255. alpha:1.0];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    [categoryBar addSubview:headerLabel];
    [_scrollView addSubview:categoryBar];
    topPos += categoryBar.frame.size.height;
    
    UIColor* currentColor = tileColour;
    
    if(times.count > 0)
    {
        for(int x=1; x<=times.count; x++)
        {
            NSString *time = [times objectAtIndex:x-1];
            
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(59, 0, 1, 28)];
            [divider setBackgroundColor:dividerColor];
            
            UIButton *lblTime = [UIButton buttonWithType:UIButtonTypeCustom];
            [lblTime addSubview:divider];
            lblTime.frame = CGRectMake(leftPos, topPos, tileWidth, tileHeight);
            [lblTime setTitle:time forState:UIControlStateNormal];
            [lblTime setTitleColor:timeColor forState:UIControlStateNormal];
            
            lblTime.backgroundColor = [UIColor clearColor];
            lblTime.titleLabel.textAlignment = UITextAlignmentCenter;
            lblTime.titleLabel.font = timeFont;
            lblTime.titleLabel.textColor = timeColor;
            
            if((x != 0) && (x % rowSplit == 0))
            {
                leftPos = 0;
                topPos += tileHeight;
                
                if(currentColor == tileColour)
                    currentColor = tileColourAlternate;
                else
                    currentColor = tileColour;
                
                UIView *newBgView = [[UIView alloc] initWithFrame:CGRectMake(0, topPos, _scrollView.frame.size.width, tileHeight)];
                newBgView.backgroundColor = currentColor;
                
                [_scrollView addSubview:newBgView];
            }
            else
            {
                leftPos += tileWidth;
            }
            
            [_scrollView addSubview:lblTime];
        }
        
        _scrollViewContentHeight = (times.count % rowSplit == 0) ? topPos : topPos + tileHeight; //add extra row if wasnt a complete row
    }
    else
    {
        UILabel* noTimes = [[UILabel alloc] initWithFrame:CGRectMake(0, topPos, _scrollView.frame.size.width, tileHeight)];
        noTimes.textAlignment = UITextAlignmentCenter;
        noTimes.font = timeFont;
        noTimes.text = NSLocalizedString(@"MTDEF_CARDNOTIME", nil);
        noTimes.textColor = timeColor;
        
        [_scrollView addSubview:noTimes];
        _scrollViewContentHeight = noTimes.frame.origin.y + noTimes.frame.size.height;
    }
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollViewContentHeight)];
}

- (void)updateWeekdayTimes:(NSArray*)times
{
    [self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDWEEKDAY", nil)];
}

- (void)updateSundayTimes:(NSArray*)times
{
    [self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDSUNDAY", nil)];
}

- (void)updateSaturdayTimes:(NSArray*)times
{
    [self updateTimes:times WithHeader:NSLocalizedString(@"MTDEF_CARDSATURDAY", nil)];
}

- (void)clearData
{
    for(UIView* subview in _scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    _scrollViewContentHeight = 0;
}

- (void)cleanUp
{
    [self clearData];
}

- (void)toggleLoading:(BOOL)toggle
{
    if(toggle)
        [_loader startAnimating];
    else [_loader stopAnimating];
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
