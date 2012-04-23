//
//  MTCardManager.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-19.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardManager.h"

@interface MTCardManager ()
- (void)initializeCardManager;
- (void)changePage:(int)newPage;
- (void)updateCardPage:(int)lastPage;
- (void)updateCurrentCard:(int)positionChange;
- (void)updatedCardPositions;
- (void)updateCard:(MTCard*)card ForRoute:(MTBus*)route AtPage:(int)page;
- (void)resetPositions;
- (void)hideQuickTable:(id)sender;
- (void)revealQuickTable:(id)sender;
@end

@implementation MTCardManager
@synthesize stop                = _stop;
@synthesize delegate            = _delegate;
@synthesize chosenDate          = _chosenDate;

- (id)initWithLanguage:(MTLanguage)language AndRect:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if(self)
    {
        _cards = [[NSMutableArray alloc] initWithCapacity:3];
        _language = language;   
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, rect.size.width, rect.size.height)];
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, rect.size.height - 30, rect.size.width, 36)];
        _quickTable = [[MTCardManagerQuickSelect alloc] initWithFrame:CGRectMake(0, -kQuickCellWidth, kQuickCellWidth, rect.size.width)];
        _quickTable.delegateQuick = self;
        
        [self initializeCardManager];
    }
    return self;
}

- (void)initializeCardManager
{
    CGRect frame = kMTCardSize;
    frame.origin.x = (self.frame.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2);
    
    //add scroller, dim out background
    _scrollView.pagingEnabled  = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    //_scrollView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    for(int x=_cards.count; x<3; x++)
    {
        MTCard *card = [[MTCard alloc] initWithLanguage:_language];
        card.frame = frame;
        card.delegate = self;
        
        [_cards addObject:card];
        
        [_scrollView addSubview:card];
        
        frame.origin.x += self.frame.size.width;
    }
    
    [_pageControl setHidesForSinglePage:YES];
    [_pageControl setCurrentPage:0];
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    
    [self addSubview:_quickTable];
    //[self addGestureRecognizer:_swipGesture];
    
    _currentCard = [_cards objectAtIndex:0];
    _prevCard = [_cards objectAtIndex:2];
    _nextCard = [_cards objectAtIndex:1];
    
    [self updatedCardPositions];
}

- (void)updateStop:(MTStop*)stop UsingLanguage:(MTLanguage)language
{
    _stop = stop;
    _language = language;
    
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * stop.BusIds.count, self.frame.size.height);
    //_scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    
    _quickTable.data = stop.BusIds;
    [_quickTable.tableView reloadData];
    
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = stop.BusIds.count;
    
    if(_pageControl.numberOfPages > 1)
    {
        //_pageControl.hidden = YES;
        [self revealQuickTable:nil];
    }
    
    if(_pageControl.numberOfPages > 10)
        _pageControl.hidden = YES;
    else if(_pageControl.hidden)
        _pageControl.hidden = NO;
        
    
    if(_chosenDate == nil)
        _chosenDate = [NSDate date];
    
    [self resetPositions];
    
    [self updateCurrentCard:1];
    [self updatedCardPositions];
}

- (void)updateDetailsForStop:(MTStop*)stop WithRoute:(MTBus*)route
{
    //or just refresh all of them
    if(_currentCard.stop == stop && _currentCard.bus == route)
    {
        [_currentCard updateCard];
    }
}

#pragma mark - MTCard Delegate

- (void)MTCardNextClicked
{
    if(_pageControl.currentPage+1 >= _pageControl.numberOfPages)
        return;
    
   // MTCard *temp;
   // temp = _currentCard;
   // _currentCard = _nextCard;
  //  _nextCard = _prevCard;
  //  _prevCard = temp;
    
    
    
    //_pageControl.currentPage += 1;
    //[self updateCurrentCard:1];
    [self changePage:_pageControl.currentPage + 1];
}

- (void)MTCardPrevClicked
{
    if(_pageControl.currentPage <= 0)
        return;
    
  //  MTCard* temp = _currentCard;
  //  _currentCard = _prevCard;
  //  _prevCard = _nextCard;
  //  _nextCard = temp;
    
    
    //_pageControl.currentPage -= 1;
    
    //[self updateCurrentCard:-1];
    [self changePage:_pageControl.currentPage - 1];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_isAnimating) _isAnimating = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    scrollView.scrollEnabled = NO;
}

// When animation stops using setContentOffset
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    int page = floor((_scrollView.contentOffset.x - _scrollView.frame.size.width / 2) / _scrollView.frame.size.width) + 1;
    int updateValue = 0;
    
    if(page != _pageControl.currentPage)
    {
        if(page > _pageControl.currentPage) //next
        {
            MTCard *temp = _currentCard;
            _currentCard = _nextCard;
            _nextCard = _prevCard;
            _prevCard = temp;
            updateValue = 1;
        }
        else
        {
            MTCard* temp = _currentCard;
            _currentCard = _prevCard;
            _prevCard = _nextCard;
            _nextCard = temp;
            updateValue = -1;
        }
        
        _pageControl.currentPage = page;   

        [self updatedCardPositions];
        [self updateCurrentCard:updateValue];
    }
    
    _isAnimating = NO;
    scrollView.scrollEnabled = YES;
}

// When animation stops using dragging
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int page = floor((_scrollView.contentOffset.x - _scrollView.frame.size.width / 2) / _scrollView.frame.size.width) + 1;
    int updateValue = 0;
    
    if(page != _pageControl.currentPage)
    {
        if(page > _pageControl.currentPage) //next
        {
            MTCard *temp = _currentCard;
            _currentCard = _nextCard;
            _nextCard = _prevCard;
            _prevCard = temp;
            updateValue = 1;
        }
        else
        {
            MTCard* temp = _currentCard;
            _currentCard = _prevCard;
            _prevCard = _nextCard;
            _nextCard = temp;
            updateValue = -1;
        }
        
        
        _pageControl.currentPage = page;

        [self updatedCardPositions];
        [self updateCurrentCard:updateValue];
    }
    
    _isAnimating = NO;
    
    scrollView.scrollEnabled = YES;
}

- (void)changePage:(int)newPage
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * newPage;
    frame.origin.y = 0;
	
    [_scrollView scrollRectToVisible:frame animated:YES];
   // [self updatedCardPositions];
}

- (void)updateCardPage:(int)lastPage
{
    
}

- (void)updateCurrentCard:(int)positionChange
{
    MTBus *bus = [_stop.BusIds objectAtIndex:_pageControl.currentPage];
    [self updateCard:_currentCard ForRoute:bus AtPage:_pageControl.currentPage + 1];

    if(_pageControl.currentPage - 1 >= 0)
    {
        MTBus *bus = [_stop.BusIds objectAtIndex:_pageControl.currentPage - 1];
        [self updateCard:_prevCard ForRoute:bus AtPage:_pageControl.currentPage];
    }
    else if(_pageControl.currentPage + 1 < _stop.BusIds.count)
    {
        MTBus *bus = [_stop.BusIds objectAtIndex:_pageControl.currentPage + 1];
        [self updateCard:_nextCard ForRoute:bus AtPage:_pageControl.currentPage + 2];
    }
}

- (void)updatedCardPositions
{
    CGRect currentCardFrame = _currentCard.frame;
    
    CGRect prevFrame = _prevCard.frame;
    CGRect nextFrame = _nextCard.frame;
    
    prevFrame.origin.x = currentCardFrame.origin.x - _scrollView.frame.size.width;
    nextFrame.origin.x = currentCardFrame.origin.x + _scrollView.frame.size.width;
    
    _prevCard.frame = prevFrame;
    _nextCard.frame = nextFrame;
}

- (void)resetPositions
{
    CGRect frame = kMTCardSize;
    frame.origin.x = (self.frame.size.width / 2) - (frame.size.width / 2);
    frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2);
    
    _currentCard.frame = frame;
    _nextCard.frame = frame;
    _prevCard.frame = frame;
}

- (void) updateCard:(MTCard *)card ForRoute:(MTBus *)route AtPage:(int)page
{
    card.numOfPages.text = [NSString stringWithFormat:@"%d", _stop.BusIds.count];
    card.currentPage.text = [NSString stringWithFormat:@"%d", page];
    
    BOOL prevHidden = NO;
    BOOL nextHidden = NO;
    
    if(page <= 1)
        prevHidden = YES;
    
    if(page >= _pageControl.numberOfPages)
        nextHidden = YES;
    
    [card hideNavigationButtonsPrev:prevHidden AndNext:nextHidden];
    
    if(route.Times.TimesAdded == NO)
    {
        [card toggleLoading:YES];
        if(!route.isUpdating && [_delegate conformsToProtocol:@protocol(MTCardManagerDelegate)])
            [_delegate cardManager:self UpdateTimesFor:_stop AndBus:route];
        
        card.stop = _stop;
        card.bus = route;
        
        [card updateDistance:[_stop getDistanceOfStop]];
        [card updateBusHeading:route.DisplayHeading];
        [card updateStreetName:_stop.StopNameDisplay];
        [card updateBusNumber:route.BusNumberDisplay];
    }
    else
    {
        [card updateCardForStop:_stop AndBus:route];
    }
    
    if(_currentCard == card && [_delegate conformsToProtocol:@protocol(MTCardManagerDelegate)])
        [_delegate cardManager:self ChangedToStop:_stop AndBus:route];
}

- (void)unload
{
    for(int x=0; x<_cards.count; x++)
    {
        MTCard* card = [_cards objectAtIndex:x];
        card.stop = nil;
        card.bus = nil;
        
        [card cleanUp];
    }
    
    _currentCard = [_cards objectAtIndex:0];
    _nextCard = [_cards objectAtIndex:1];
    _prevCard = [_cards objectAtIndex:2];
    
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [_scrollView setContentSize:CGSizeMake(_cards.count * _scrollView.frame.size.width, _scrollView.frame.size.height)];
    
    _quickTable.data = nil;
    [_quickTable.tableView reloadData];
    //[_quickTable setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height/2)];
    [self hideQuickTable:nil];
    
    
    _chosenDate = nil;
    
    [self resetPositions];
}

- (MTBus*)getCurrentBus
{
    if(_currentCard != nil)
    {
        return _currentCard.bus;
    }
    
    return nil;
}

#pragma mark - quick view

- (void)hideQuickTable:(id)sender
{
    CGRect quickTableFrame = _quickTable.frame;
    quickTableFrame.origin.y = 0 - _quickTable.frame.size.height;
    
    [UIView animateWithDuration:0.5 
                     animations:^(void){
                         _quickTable.frame = quickTableFrame;
                     }];
    
    _swipeStartedAtBottom = NO;
}

- (void)revealQuickTable:(id)sender
{
    CGRect quickTableFrame = _quickTable.frame;
    quickTableFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.25 
                     animations:^(void){
                         _quickTable.frame = quickTableFrame;
                     }];
    
    _swipeStartedAtBottom = NO;
}

#pragma mark - CHANGES based on parent

- (void)forceUpdate
{
    for(MTBus* bus in _stop.BusIds)
    {
        [bus clearLiveTimes];
        [bus.Times clearTimes];
        
        bus.Times.TimesAdded = NO;
    }
    
    if(_currentCard != nil)
    {
        MTBus* currentBus = _currentCard.bus;
        [self updateCard:_currentCard ForRoute:currentBus AtPage:_pageControl.currentPage + 1];
    }
}

#pragma mark - QUICK SELECT DELEGATE

- (void)quickSelect:(id)owner receivedClick:(int)row
{
    if(_stop.BusIds.count < row && _currentCard != nil)
        return;
    
    CGRect currentCardFrame = _currentCard.frame;
    currentCardFrame.origin.x = _scrollView.frame.size.width * row + (self.frame.size.width / 2) - (kMTCardSize.size.width / 2);
    _currentCard.frame = currentCardFrame;
    
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * row, 0);

    _pageControl.currentPage = row;
    
    [self updatedCardPositions];
    [self updateCurrentCard:0];
    
    //[self hideQuickTable:nil];
}

@end
