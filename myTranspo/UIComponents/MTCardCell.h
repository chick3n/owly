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

#define kHiddenHeight 86
#define kFullHeight 130
#define kCellExpandSpacer 1
#define kElementNextTimesCount 2
#define kElementNextTimesElementCount 4
#define kElementNextTimesSpacer 80
#define kElementNextTimesImageRect CGRectMake(9, 10, 21, 22)
#define kElementMoreDetailsCount 1
#define kElementMoreDetailsElementCount 3

@protocol MTCardCellDelegate <NSObject>
@required
- (void)mtCardCellnextTimeClickedForStop:(MTStop*)stop;
- (void)mtCardcellDeleteClicked:(id)cell;
@end

@interface MTCardCell : UITableViewCell //<UIScrollViewDelegate>
{
    BOOL                            _modeLarge;
    BOOL                            _remaingTimeShown;
    MTStop*                         _stop;
    id<MTCardCellDelegate> __weak   _delegate;
    MTLanguage                      _language;
    NSString*                       _nextTimeValue;
    BOOL                            _hasExpanded;
    
    //UI Components
    IBOutlet UILabel*               _busNumber;
    IBOutlet UILabel*               _busHeading;
    IBOutlet UILabel*               _streetName;
    IBOutlet UILabel*               _prevTime;
    IBOutlet UIButton*              _nextTime;
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
    //page 1
    NSMutableArray*                 _nextTimes;
    //page 2
    NSMutableArray*                 _moreDetails;
}

@property (weak) id<MTCardCellDelegate>     delegate;
@property (nonatomic)   MTLanguage          language;
@property (nonatomic)   int                 indexRow;

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

@end
