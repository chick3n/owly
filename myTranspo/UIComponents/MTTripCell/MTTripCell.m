//
//  MTTripCell.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-22.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTTripCell.h"

@interface MTTripCell ()
- (void)initializeUI;
@end

@implementation MTTripCell
@synthesize delegate =              _delegate;
@synthesize language =              _language;
@synthesize alertSelected =         _alertSelected;
@synthesize trip =                  _trip;
@synthesize useForTrain =           _useForTrain;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLanguage:(MTLanguage)language AndOwner:(id)owner
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTTripCell" owner:self options:nil];
        [self addSubview:[mtCardCellXib objectAtIndex:0]];
        _language = language;
        _alertSelected = NO;
        
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlertSelected:(BOOL)alertSelected
{
    if(alertSelected)
        _alertImage.alpha = 1.0;
    else _alertImage.alpha = 0.5;
    _alertSelected = alertSelected;
}

- (void)setUseForTrain:(BOOL)useForTrain
{
    _useForTrain = useForTrain;
    
    if(_useForTrain == YES)
        _busImage.image = [UIImage imageNamed:@"global_train_arrival.png"];
    else _busImage.image = [UIImage imageNamed:@"route_cell_bus.png"];
}

- (void)initializeUI
{
    
}

- (void)toggleDisplayViews
{
    if(_alertImage.hidden)
    {
        CGRect alertImageFrame = _alertImage.frame;
        CGRect origAlertImageFrame = _alertImage.frame;
        CGRect newStopFrame = _stopName.frame;
        
        alertImageFrame.origin.x = self.frame.size.width;
        newStopFrame.size.width = newStopFrame.size.width - origAlertImageFrame.size.width;
        
        _alertImage.frame = alertImageFrame;
        _alertImage.hidden = NO;
        
        [UIView animateWithDuration:0.25
                         animations:^(void){
                             _alertImage.frame = origAlertImageFrame;
                             _stopName.frame = newStopFrame;
                             //_tripTime.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             //_tripTime.hidden = YES;
                         }];
    }
    else
    {
        CGRect alertImageFrame = _alertImage.frame;
        CGRect origAlertImageFrame = _alertImage.frame;
        CGRect newStopFrame = _stopName.frame;
        
        alertImageFrame.origin.x = self.frame.size.width;
        newStopFrame.size.width = newStopFrame.size.width + origAlertImageFrame.size.width;
        //_tripTime.hidden = NO;
        
        [UIView animateWithDuration:0.25
                         animations:^(void){
                             _alertImage.frame = alertImageFrame;
                             _stopName.frame = newStopFrame;
                             //_tripTime.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             _alertImage.hidden = YES;
                             _alertImage.frame = origAlertImageFrame;
                         }];
    }
}

- (void)updateCellBackgroundWithStopSequence:(MTTripSequence)sequence
{
    if(sequence == MTTRIPSEQUENCE_FIRST)
    {
        _statusImage.image = [UIImage imageNamed:@"route_cell_dotbottom.png"];
    }
    else if(sequence == MTTRIPSEQUENCE_LAST)
    {
        _statusImage.image = [UIImage imageNamed:@"route_cell_dottop.png"];
    }
    else
    {
        _statusImage.image = [UIImage imageNamed:@"route_cell_dotfull.png"];
    }
}

- (void)updateBusImage:(BOOL)toggle
{
    _busImage.hidden = toggle;
}

- (void)updateCellDetails:(MTTrip*)trip
{
    if(trip == nil)
        return;
    
    _trip = trip;
    
    _stopName.text = _trip.StopName;
    _tripTime.text = [_trip.Time getTimeForDisplay];
}

- (IBAction)alertButtonClicked:(id)sender
{
    if([_delegate conformsToProtocol:@protocol(MTTripCellDelegate)])
    {
        if(!_alertSelected)
        {
            [_delegate mtTripCell:self AlertAddedForTrip:_trip];
        }
        else
        {
            [_delegate mtTripCell:self AlertRemovedForTrip:_trip];
        }
    }        
}

@end
