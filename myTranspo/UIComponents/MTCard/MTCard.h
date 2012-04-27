//
//  MTCard.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-19.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTStop.h"
#import "MTBus.h"
#import "MTCardRowCell.h"

#define kMTCardSize CGRectMake(0, 0, 309, 344)

@protocol MTCardDelegate <NSObject>

@required
- (void)MTCardNextClicked;
- (void)MTCardPrevClicked;

@end

@interface MTCard : UIView <UITableViewDataSource, UITableViewDelegate>
{
    id<MTCardDelegate> __weak           _delegate;
    MTLanguage                          _language;
    MTStop*                             _stop;
    MTBus*                              _bus;
    uint                                _scrollViewContentHeight;
    BOOL                                _hideDetailsView;
    BOOL                                _hidePaging;
    
    NSArray*                            _timesWeekday;
    NSArray*                            _timesSaturday;
    NSArray*                            _timesSunday;
    
    //UI Components
    UIActivityIndicatorView*            _loader;
    IBOutlet UILabel*                   _busNumber;
    IBOutlet UILabel*                   _busHeading;
    IBOutlet UILabel*                   _stopStreet;
    IBOutlet UILabel*                   _distance;
    IBOutlet UILabel*                   _prevTime;
    IBOutlet UILabel*                   _nextTime;
    IBOutlet UILabel*                   _direction;
    IBOutlet UIScrollView*              _scrollView;
    IBOutlet UIView*                    _detailsView;
    IBOutlet UIButton*                  _prevButton;
    IBOutlet UIButton*                  _nextButton;
    IBOutlet UILabel*                   _prevHeading;
    IBOutlet UILabel*                   _nextHeading;
    IBOutlet UILabel*                   _distanceHeading;
    IBOutlet UILabel*                   _directionHeading;
    IBOutlet UITableView*               _tableView;
    
}

@property (nonatomic, weak) id<MTCardDelegate>          delegate;
@property (nonatomic, strong) MTStop*                   stop;
@property (nonatomic, strong) MTBus*                    bus;
@property (nonatomic, strong) IBOutlet UILabel*         currentPage;
@property (nonatomic, strong) IBOutlet UILabel*         numOfPages;

- (id)initWithoutDetailsViewWithLanguage:(MTLanguage)language;
- (id)initWithoutDetailsViewAndPagingWithLanguage:(MTLanguage)language;
- (id)initWithoutPagingWithLanguage:(MTLanguage)language;
- (id)initWithLanguage:(MTLanguage)language;

- (BOOL)updateCardForStop:(MTStop*)stop AndBus:(MTBus*)bus;
- (BOOL)updateCard;
- (void)updateBusHeading:(NSString *)heading;
- (void)updateBusNumber:(NSString *)busNumber;
- (void)updateStreetName:(NSString *)name;
- (void)updatePrevTime:(NSString *)time;
- (void)updateNextTime:(NSString *)time IsLive:(BOOL)live;
- (void)updateDirection:(NSString *)direction;
- (void)updateDistance:(NSString *)distance;
- (void)updateWeekdayTimes:(NSArray*)times;
- (void)updateSundayTimes:(NSArray*)times;
- (void)updateSaturdayTimes:(NSArray*)times;
- (void)updateTimes:(NSArray *)times  WithHeader:(NSString*)header;
- (void)toggleLoading:(BOOL)toggle;
- (void)hideNavigationButtonsPrev:(BOOL)prev AndNext:(BOOL)next;
- (void)cleanUp;
- (void)clearData; //removes scrollview data!

- (IBAction)prevClicked:(id)sender;
- (IBAction)nextClicked:(id)sender;

@end
