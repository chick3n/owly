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
    
    _stopName.text = _trip.StopNameDisplay;
    _tripTime.text = [_trip.Time getTimeForDisplay];
}

- (void)updateCellDetailsQuick:(NSString*)title ForSecond:(NSString*)second
{
    _stopName.text = title;
    _tripTime.text = second;
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
