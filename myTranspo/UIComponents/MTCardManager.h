//
//  MTCardManager.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-19.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <math.h>

#import "MTIncludes.h"
#import "MTCard.h"
#import "MTCardManagerQuickSelect.h"

#define kQuickSelectFlick 1300.0f
#define kSwipeUpFromY 350.0f
#define kSwipeDownFromY 70.0f

@protocol MTCardManagerDelegate <NSObject>
@required
- (void)cardManager:(id)owner UpdateTimesFor:(MTStop*)stop AndBus:(MTBus*)bus;
- (void)cardManager:(id)card ChangedToStop:(MTStop*)stop AndBus:(MTBus*)bus;
@end

@interface MTCardManager : UIView <UIScrollViewDelegate, MTCardDelegate, MTCardManagerQuickSelectDelegate>
{
    NSMutableArray*         _cards;
    MTStop* __weak          _stop;
    MTLanguage              _language;
    BOOL                    _isAnimating;
    BOOL                    _swipeStartedAtBottom;
    
    //ui components
    UIScrollView*           _scrollView;
    UIPageControl*          _pageControl;
    MTCard*                 _currentCard;
    MTCard*                 _prevCard;
    MTCard*                 _nextCard;
    MTCardManagerQuickSelect* _quickTable;
    UIPanGestureRecognizer* _swipGesture;
}

@property (nonatomic, weak)     MTStop*                     stop;
@property (nonatomic, weak)     id<MTCardManagerDelegate>   delegate;
@property (nonatomic, strong)   NSDate*                     chosenDate;

- (id)initWithLanguage:(MTLanguage)language AndRect:(CGRect)rect;
- (void)updateStop:(MTStop*)stop UsingLanguage:(MTLanguage)language;
- (void)updateDetailsForStop:(MTStop*)stop WithRoute:(MTBus*)route;
- (void)unload;
- (void)forceUpdate;

- (MTBus*)getCurrentBus;

@end
