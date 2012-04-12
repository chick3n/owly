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

@protocol MTCardCellDelegate <NSObject>
@required
- (void)mtCardCellnextTimeClickedForStop:(MTStop*)stop;
@end

@interface MTCardCell : UITableViewCell
{
    BOOL                            _modeLarge;
    MTStop*                         _stop;
    id<MTCardCellDelegate> __weak   _delegate;
    MTLanguage                      _language;
    
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
    IBOutlet UIActivityIndicatorView* _loadingAnimation;
    IBOutlet UIImageView*           _titleBackground;
    IBOutlet UIImageView*           _detailsBackground;
    IBOutlet UIImageView*           _busNumberBackground;
    IBOutlet UIImageView*           _arrowImage;
    IBOutlet UILabel*               _prevHeading;
    IBOutlet UILabel*               _nextHeading;
    IBOutlet UILabel*               _distanceHeading;
    IBOutlet UILabel*               _directionHeading;
}

@property (weak) id<MTCardCellDelegate>     delegate;
@property (nonatomic)   MTLanguage          language;

- (IBAction)nextTimeClicked:(id)sender;

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
