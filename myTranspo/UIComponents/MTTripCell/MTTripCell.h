//
//  MTTripCell.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-22.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTrip.h"

#define kMTTRIPCELLHEIGHT 44
#define kMTTRIPHEADERHEIGHT 23
#define kMTTRIPDETAILSVIEWTAG 1
#define kMTTRIPALERTVIEWTAG 2

typedef enum
{
    MTTRIPSEQUENCE_FIRST = 0
    , MTTRIPSEQUENCE_LAST
    , MTTRIPSEQUENCE_MIDDLE
} MTTripSequence;

@protocol MTTripCellDelegate <NSObject>
@required
- (void)mtTripCell:(id)tripCell AlertAddedForTrip:(MTTrip*)trip;
- (void)mtTripCell:(id)tripCell AlertRemovedForTrip:(MTTrip*)trip;
@end

@interface MTTripCell : UITableViewCell
{
    id<MTTripCellDelegate> __weak               _delegate;
    MTTrip*                                     _trip;
    MTLanguage                                  _language;
    
    //ui components
    IBOutlet UILabel*                           _stopName;
    IBOutlet UIImageView*                       _statusImage;
    IBOutlet UIButton*                          _alertImage;
    IBOutlet UIImageView*                       _backgroundImage;
    IBOutlet UIView*                            _detailsView;
    IBOutlet UILabel*                           _tripTime;
    IBOutlet UIImageView*                       _busImage;

}

@property (weak) id<MTTripCellDelegate>         delegate;
@property (nonatomic) MTLanguage                language;
@property (nonatomic) BOOL                      alertSelected;
@property (nonatomic, readonly) MTTrip*         trip;
@property (nonatomic) BOOL                      useForTrain;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLanguage:(MTLanguage)language AndOwner:(id)owner;

- (void)toggleDisplayViews;
- (void)updateCellBackgroundWithStopSequence:(MTTripSequence)sequence;
- (void)updateCellDetails:(MTTrip*)trip;
- (void)updateBusImage:(BOOL)toggle;
- (IBAction)alertButtonClicked:(id)sender;

@end
