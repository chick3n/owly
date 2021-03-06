//
//  MTCardCell.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MTStop.h"
#import "MTDefinitions.h"
#import "MTCellButton.h"
#import "MTCellAlert.h"

#define kHiddenHeight 86
#define kFullHeight 130
#define kCellExpandSpacer 0
#define kElementNextTimesCount 2
#define kElementNextTimesElementCount 4
#define kElementNextTimesSpacer 80
#define kElementNextTimesImageRect CGRectMake(9, 10, 21, 22)
#define kElementMoreDetailsCount 1
#define kElementMoreDetailsElementCount 3

#define kDetailsViewFrameHeight 57
#define kDataScrollViewFrameHeight 55

#define kScrollToRefreshPoint -60

@protocol MTCardCellDelegate <NSObject>
@required
//- (void)mtCardCellnextTimeClickedForStop:(MTStop*)stop;
- (void)mtCardcellDeleteClicked:(id)cell;
- (void)cardCellRefreshRequestedForDisplayedData:(id)cell;
@end

@interface MTCardCell : UITableViewCell <UIScrollViewDelegate>
{
    BOOL                            _modeLarge;
    BOOL                            _remaingTimeShown;
    MTStop* __weak                  _stop;
    id<MTCardCellDelegate> __weak   _delegate;
    MTLanguage                      _language;
    NSString*                       _nextTimeValue;
    BOOL                            _hasExpanded;
    BOOL                            _isAnimatingEdit;
    CGPoint                         _lastContentOffset;
    BOOL                            _isAnimating;
    BOOL                            _isScrollingAutomatically;
    BOOL                            _singleCellAnimating;
    
    //UI Components
    IBOutlet UILabel*               _busNumber;
    IBOutlet UILabel*               _busHeading;
    IBOutlet UILabel*               _streetName;
    IBOutlet UILabel*               _prevTime;
    IBOutlet MTCellButton*          _nextTime;
    IBOutlet UILabel*               _distance;
    IBOutlet UILabel*               _direction;
    IBOutlet UIView*                _titleView;
    IBOutlet UIView*                _detailsView;
    IBOutlet UIScrollView*          _dataScrollView;
    IBOutlet UIActivityIndicatorView* _loadingAnimation;
    IBOutlet UIImageView*           _titleBackground;
    IBOutlet UIImageView*           _detailsBackground;
    IBOutlet UIImageView*           _busNumberBackground;
    IBOutlet UIImageView*           _arrowImage;
    IBOutlet UILabel*               _prevHeading;
    IBOutlet UILabel*               _nextHeading;
    IBOutlet UILabel*               _distanceHeading;
    IBOutlet UILabel*               _directionHeading;
    IBOutlet UIButton*              _delete;
    IBOutlet MTCellAlert*           _timesAlert;
    UILabel*                        _refreshLabel;
    UIImageView*                    _refreshArrow;
    
    //page 1
    NSMutableArray*                 _nextTimes;
    //page 2
    NSMutableArray*                 _moreDetails;
}

@property (weak)            id<MTCardCellDelegate>  delegate;
@property (nonatomic)       MTLanguage              language;
@property (nonatomic)       int                     indexRow;
@property (nonatomic, weak) MTStop                  *stop;

@property (nonatomic)       BOOL                    hasExpanded;
@property (nonatomic)       BOOL                    isExpanding;

- (IBAction)nextTimeClicked:(id)sender;
- (IBAction)deleteClicked:(id)sender;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLanguage:(MTLanguage)language;

- (NSInteger)getCellHeight;
- (BOOL)isCellUpdated;
- (void)updateCellMode:(BOOL)large;
- (void)updateCellDetails:(MTStop*)stop New:(BOOL)newData;
- (void)updateCellHeader:(MTStop*)stop;
- (void)expandCellWithAnimation:(BOOL)animate;
- (void)toggleLoadingAnimation:(BOOL)toggle;
- (void)initializeUI;

//NEW for mybuses v2
- (void)updateCellBusNumber:(NSString*)busNumber AndBusDisplayHeading:(NSString*)busDisplayHeading AndStopStreentName:(NSString*)stopStreetName IsStopFavorite:(BOOL)stopFavorite;
- (void)updateCellPrevTime:(NSString*)prevTime AndDistance:(NSString*)distance AndDirection:(NSString*)direction AndNextTime:(MTTime*)nextTime AndNextTimes:(NSArray*)nextTimes AndSpeed:(NSString*)speed IsStopFavorite:(BOOL)stopFavorite;
- (void)updateCellDetailsWithFlash;
- (void)updateCellDetailsAnimation:(BOOL)animate;
- (void)updateCellDetailsClose:(BOOL)animate;
- (void)updateCellForIndividualUpdate:(BOOL)update;

- (void)editMode:(id)sender;
- (void)defaultMode:(id)sender;

@end
