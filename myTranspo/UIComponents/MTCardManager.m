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
- (void)swipeGesture:(id)sender;
- (void)swipeGestureHide:(id)sender;
- (void)hideQuickTable:(id)sender;
- (void)revealQuickTable:(id)sender;
- (void)bounceQuickView:(id)sender;
- (void)updateCardsBasedOnScroll:(id)sender;
- (void) updateCard:(MTCard *)card ForRoute:(MTBus *)route AtPage:(int)page UpdateTime:(BOOL)times;
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
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, rect.size.height - 40, rect.size.width, 36)];
        _quickTable = [[MTCardManagerQuickSelect alloc] initWithFrame:CGRectMake(0, -(rect.size.height-kBarHeight), rect.size.width, rect.size.height)];
        _swipGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        
        _quickTable.delegateQuick = self;
        _isQuickSelect = NO;
        
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
    //_scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
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
    
    [_quickTable.headerBar addTarget:self action:@selector(bounceQuickView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_quickTable];
    [self addGestureRecognizer:_swipGesture];
    
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
    
    _pageControl.hidden = YES;
    
    if(_pageControl.numberOfPages >= 3)
    {
        [self performSelector:@selector(bounceQuickView:) withObject:nil afterDelay:0.25];
    }
    
    if(_chosenDate == nil)
        _chosenDate = [NSDate date];
    
    [self resetPositions];
    
    [self updateCurrentCard:99];
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
    if(_isQuickSelect) return;

    [self updatedCardPositions];
    //[_currentCard clearDataForQuickScrolling];
    [_nextCard clearDataForQuickScrolling];
    [_prevCard clearDataForQuickScrolling];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isAnimating = YES;
    _isDecelerating = NO;
    _isQuickSelect = NO;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //scrollView.scrollEnabled = NO;
    _isAnimating = YES;
    _isDecelerating = YES;
    if(_isQuickSelect)
        return;
    
    [self updateCurrentCard:1];
}

// When animation stops using setContentOffset
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
        
    _isAnimating = NO;
    _isQuickSelect = NO;
    _isDecelerating = NO;
    [self performSelector:@selector(updateCardsBasedOnScroll:) withObject:nil afterDelay:0.25];
}

// When animation stops using dragging
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        
    _isAnimating = NO;
    _isQuickSelect = NO;
    _isDecelerating = NO;
    [self performSelector:@selector(updateCardsBasedOnScroll:) withObject:nil afterDelay:0.25];
}

- (void)updateCardsBasedOnScroll:(id)sender
{
    if(_isAnimating)
        return;
    
    [self updateCurrentCard:99];
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
}

- (void)updateCurrentCard:(int)positionChange
{
    
    MTBus *bus = [_stop.BusIds objectAtIndex:_pageControl.currentPage];
    [self updateCard:_currentCard ForRoute:bus AtPage:_pageControl.currentPage + 1 UpdateTime:(positionChange == 99) ? YES : NO];
    
    if(_pageControl.currentPage - 1 >= 0)
    {
        MTBus *busPrev = [_stop.BusIds objectAtIndex:_pageControl.currentPage - 1];
        //MTLog(@"Update Prev Card Details: %@", busPrev.BusNumberDisplay);
        //if(_prevCard.frame.origin.x <= (_currentCard.frame.origin.x - _scrollView.frame.size.width))
        //    [_prevCard clearData];
        [self updateCard:_prevCard ForRoute:busPrev AtPage:_pageControl.currentPage UpdateTime:(positionChange == 99) ? YES : NO];
    }
    
    if(_pageControl.currentPage + 1 < _stop.BusIds.count)
    {
        MTBus *busNext = [_stop.BusIds objectAtIndex:_pageControl.currentPage + 1];
        //MTLog(@"Update Next Card Details: %@", busNext.BusNumberDisplay);
        //if(_nextCard.frame.origin.x >= (_currentCard.frame.origin.x + _scrollView.frame.size.width))
        //    [_nextCard clearData];
        [self updateCard:_nextCard ForRoute:busNext AtPage:_pageControl.currentPage + 2 UpdateTime:(positionChange == 99) ? YES : NO];
    }
}

- (void)updatedCardPositions
{
    int page = floor((_scrollView.contentOffset.x - _scrollView.frame.size.width / 2) / _scrollView.frame.size.width) + 1;
    
    if(page > _pageControl.currentPage) //next
    {
        MTCard *temp = _currentCard;
        _currentCard = _nextCard;
        _nextCard = _prevCard;
        _prevCard = temp;
        //[self updateCurrentCard:1];
    }
    else if(page < _pageControl.currentPage)
    {
        MTCard* temp = _currentCard;
        _currentCard = _prevCard;
        _prevCard = _nextCard;
        _nextCard = temp;
        //[self updateCurrentCard:1];
    }
    
    _pageControl.currentPage = page;
    //[self updateCurrentCard:1];
    
    CGRect currentCardFrame = _currentCard.frame;
    
    CGRect prevFrame = _prevCard.frame;
    CGRect nextFrame = _nextCard.frame;
    
    prevFrame.origin.x = currentCardFrame.origin.x - _scrollView.frame.size.width;
    nextFrame.origin.x = currentCardFrame.origin.x + _scrollView.frame.size.width;
    
    _prevCard.frame = prevFrame;
    _nextCard.frame = nextFrame;
    
    if(_pageControl.currentPage + 1 >= _pageControl.numberOfPages)
        _nextCard.hidden = YES;
    else {
        if(_nextCard.hidden)
            _nextCard.hidden = NO;
    }
    
    if(_pageControl.currentPage - 1 < 0)
        _prevCard.hidden = YES;
    else {
        if(_prevCard.hidden)
            _prevCard.hidden = NO;
    }
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
    [self updateCard:card ForRoute:route AtPage:page UpdateTime:YES];
}

- (void) updateCard:(MTCard *)card ForRoute:(MTBus *)route AtPage:(int)page UpdateTime:(BOOL)times
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
    
    if(!times) //just update deetails and move on!
    {
        card.stop = _stop;
        card.bus = route;
        
        [card updateDistance:[_stop getDistanceOfStop]];
        [card updateBusHeading:route.DisplayHeading];
        [card updateStreetName:_stop.StopNameDisplay];
        [card updateBusNumber:route.BusNumberDisplay];
        [card updateNextTime:[route.NextTimeDisplay getTimeForDisplay] IsLive:NO];
        [card updatePrevTime:route.PrevTimeDisplay];
        [card updateDistance:[_stop getDistanceOfStop]];
        [card updateDirection:[route getBusHeadingShortForm]];
        
        //[card clearData];
        return;
    }
    
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
        
        //[card clearData];
    }
    else
    {
        //card clears data in updateCardForStop no need to call it twice
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

#pragma mark - SWIP GESTURE

- (void)swipeGesture:(id)sender
{
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*)sender;
    
    if (UIGestureRecognizerStateBegan == [gesture state])
    {
        //get start coordinates and save them
        if([gesture locationInView:self].y <= kSwipeDownFromY)
            _swipeStartedAtBottom = YES;
        else
            _swipeStartedAtBottom = NO;
    }
    else if (UIGestureRecognizerStateEnded == [gesture state])
    {
        if(_swipeStartedAtBottom == NO)
            return;
        
        if (fabs([gesture velocityInView:self].y) > kQuickSelectFlick)
		{
			if ([gesture velocityInView:self].y > 0.0f)
			{				
				[self revealQuickTable:nil];
			}
			else
			{
				[self hideQuickTable:nil];
			}
		}
        else if([gesture locationInView:self].y < (self.frame.size.height / 2))
        {
            //slide back down
            [self hideQuickTable:nil];
        }
        else
        {
            //lock table view to position
            [self revealQuickTable:nil];
        }
        
        
        _swipeStartedAtBottom = NO;
    }
    else //in progress
    {
        if(_swipeStartedAtBottom == NO)
            return;
        
        if([gesture locationInView:self].y >= self.frame.size.height)
        {
            CGRect quickTableFrame = _quickTable.frame;
            quickTableFrame.origin.y = self.frame.size.height;
            _quickTable.frame = quickTableFrame;
        }
        else
        {
            //draw up tableview
            CGRect quickTableFrame = _quickTable.frame;
            quickTableFrame.origin.y = [gesture locationInView:self].y - quickTableFrame.size.height ;
            _quickTable.frame = quickTableFrame;
        }
    }
}

- (void)swipeGestureHide:(id)sender
{
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*)sender;
    
    
    if (UIGestureRecognizerStateBegan == [gesture state])
    {
        //get start coordinates and save them
        CGFloat rangeA = _quickTable.frame.origin.y + _quickTable.frame.size.height - (kBarHeight * 2);
        CGFloat rangeB = _quickTable.frame.origin.y + _quickTable.frame.size.height + _quickTable.headerBar.frame.size.height;
                
        if([gesture locationInView:self].y >= rangeA && [gesture locationInView:self].y <= rangeB)
            _swipeStartedAtBottom = YES;
        else
            _swipeStartedAtBottom = NO;
    }
    else if (UIGestureRecognizerStateEnded == [gesture state])
    {
        if(_swipeStartedAtBottom == NO)
            return;
        
        if(_quickTable.frame.origin.y < self.frame.size.height/2 )
        {
            //slide back down
            [self hideQuickTable:nil];
        }
        else
        {
            //lock table view to position
            [self revealQuickTable:nil];
        }        
        
        _swipeStartedAtBottom = NO;
    }
    else //in progress
    {
        if(_swipeStartedAtBottom == NO)
            return;
        
        if([gesture locationInView:self].y <= kBarHeight)
        {
            CGRect quickTableFrame = _quickTable.frame;
            quickTableFrame.origin.y = -(self.frame.size.height - kBarHeight);
            _quickTable.frame = quickTableFrame;
        }
        else
        {
            //draw up tableview
            CGRect quickTableFrame = _quickTable.frame;
            quickTableFrame.origin.y = [gesture locationInView:self].y - quickTableFrame.size.height;
            _quickTable.frame = quickTableFrame;
        }
    }
}

- (void)hideQuickTable:(id)sender
{
    CGRect quickTableFrame = _quickTable.frame;
    quickTableFrame.origin.y = -(quickTableFrame.size.height - kBarHeight);
    
    [UIView animateWithDuration:0.5 
                     animations:^(void){
                         _quickTable.frame = quickTableFrame;
                     }];
    
    [_swipGesture removeTarget:self action:@selector(swipeGestureHide:)];
    [_swipGesture addTarget:self action:@selector(swipeGesture:)];
    
    _swipeStartedAtBottom = NO;
}

- (void)revealQuickTable:(id)sender
{
    CGRect quickTableFrame = _quickTable.frame;
    quickTableFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.5 
                     animations:^(void){
                         _quickTable.frame = quickTableFrame;
                     }];
    
    [_swipGesture removeTarget:self action:@selector(swipeGesture:)];
    [_swipGesture addTarget:self action:@selector(swipeGestureHide:)];
    
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
    
    _isQuickSelect = YES;
    
    CGRect currentCardFrame = _currentCard.frame;
    currentCardFrame.origin.x = _scrollView.frame.size.width * row + (self.frame.size.width / 2) - (kMTCardSize.size.width / 2);
    _currentCard.frame = currentCardFrame;
    
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * row, 0);
    
    _pageControl.currentPage = row;
    
    [self updatedCardPositions];
    [self updateCurrentCard:99];
    
    [self hideQuickTable:nil];
}

- (void)bounceQuickView:(id)sender
{
#if 0
    CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    bounceAnimation.duration = 1.0;
    bounceAnimation.fromValue = [NSNumber numberWithInt:0];
    bounceAnimation.toValue = [NSNumber numberWithInt:kBarHeight];
    bounceAnimation.repeatCount = 3;
    bounceAnimation.autoreverses = YES;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.removedOnCompletion = NO;
        
    [_quickTable.layer addAnimation:bounceAnimation forKey:@"bounce"];

    [UIView beginAnimations:@"bounce" context:nil];
    [UIView setAnimationRepeatCount:2];
    [UIView setAnimationRepeatAutoreverses:YES];
    _quickTable.center = CGPointMake(_quickTable.center.x, _quickTable.center.y + 10);
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [UIView setAnimationRepeatCount:2];
                         [UIView setAnimationRepeatAutoreverses:YES];
                         _quickTable.center = CGPointMake(_quickTable.center.x, _quickTable.center.y + 5);
                     } 
                     completion:^(BOOL finished) {
                         _quickTable.frame = quickTableFrame;
                     }];
#endif 
    CGRect quickTableFrame = _quickTable.frame;

    if(quickTableFrame.origin.y >= 0)
        return;
    
    
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _quickTable.center = CGPointMake(_quickTable.center.x, _quickTable.center.y + 10);
                     } 
                     completion:^(BOOL finished) {
                         if(finished)
                         {
                             [UIView animateWithDuration:0.15
                                              animations:^{
                                                  _quickTable.frame = quickTableFrame;
                                              } completion:^(BOOL finished) {
                                                  if(finished)
                                                  {
                                                      [UIView animateWithDuration:0.15
                                                                       animations:^{
                                                                           _quickTable.center = CGPointMake(_quickTable.center.x, _quickTable.center.y + 5);
                                                                       } completion:^(BOOL finished) {
                                                                           if(finished)
                                                                           {
                                                                               [UIView animateWithDuration:0.1
                                                                                                animations:^{
                                                                                                    _quickTable.frame = quickTableFrame;
                                                                                                }];
                                                                           }
                                                                       }];
                                                  }
                                              }];
                         }
                     }];

}

@end