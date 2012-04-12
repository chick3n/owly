//
//  MTCardCell.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardCell.h"

@interface MTCardCell ()

@end

@implementation MTCardCell
@synthesize delegate =          _delegate;
@synthesize language =          _language;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLanguage:(MTLanguage)language
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTCardCell" owner:self options:nil];
        [self addSubview:[mtCardCellXib objectAtIndex:0]];
        _language = language;
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeUI
{   
    CGRect frame = _detailsView.frame;
    frame.origin.y -= _titleView.frame.size.height - frame.size.height + 24;
    _detailsView.frame = frame;
    
    _detailsView.hidden = NO;
    _arrowImage.hidden = YES;
    
    _prevHeading.text = NSLocalizedString(@"MTDEF_CARDPREVIOUS", nil);
    _nextHeading.text = NSLocalizedString(@"MTDEF_CARDNEXT", nil);
    _distanceHeading.text = NSLocalizedString(@"MTDEF_CARDDISTANCE", nil);
    _directionHeading.text = NSLocalizedString(@"MTDEF_CARDDIRECTION", nil);
}

- (NSInteger)getCellHeight
{
    if(_modeLarge)
        return kFullHeight;
    return kHiddenHeight;
}

- (void)updateCellMode:(BOOL)large
{
    _modeLarge = large;
    
    if(large)
    {
        [_loadingAnimation stopAnimating];
        _arrowImage.hidden = NO;
    }
}

- (void)updateCellHeader:(MTStop*)stop
{
    _stop = stop;
    
    _busNumber.text = stop.Bus.BusNumber;
    _busHeading.text = stop.Bus.DisplayHeading;
    _streetName.text = stop.StopName;
    
    if(stop.IsUpdating)
    {
        [self toggleLoadingAnimation:YES];
    }
    else [self toggleLoadingAnimation:NO];
}

- (void)updateCellDetails:(MTStop*)stop New:(BOOL)newData
{
    _stop = stop;
    
    _prevTime.text = stop.Bus.PrevTime;
    _direction.text = [stop.Bus getBusHeadingShortForm];
    _distance.text = [stop getDistanceOfStop];
    
    [_nextTime setTitle:stop.Bus.NextTime forState:UIControlStateNormal];
    
    [self toggleLoadingAnimation:NO];
    
    if(newData)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _prevTime.alpha = 0.0;
            _nextTime.alpha = 0.0;
            _distance.alpha = 0.0;
        } completion:^(BOOL finished){
            _prevTime.alpha = 1.0;
            _nextTime.alpha = 1.0;
            _distance.alpha = 1.0;
        }];
    }
}

- (void)expandCellWithAnimation:(BOOL)animate
{
    if(_modeLarge)
        return;
    
    _modeLarge = YES;
    [self toggleLoadingAnimation:NO];
    
    //_titleBackground.image = [UIImage imageNamed:@"cardcell_top_background.png"];
    
#if 0
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, _titleBackground.frame.size.height, _detailsView.frame.size.width, _detailsView.frame.size.height));
    
    CAShapeLayer* mask = [CAShapeLayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"cardcell_top_background.png"] CGImage];
    //mask.fillColor = [[UIColor whiteColor] CGColor];
    //mask.backgroundColor = [[UIColor clearColor] CGColor];
    //mask.frame = _detailsView.bounds;
    mask.path = path;
    _detailsView.layer.mask = mask;
    
    CGRect titleBackgroundFrame = _titleBackground.frame;
    titleBackgroundFrame.origin.y -= 15;
    _titleBackground.frame = titleBackgroundFrame;
    
#endif

        
    CGRect titleFrame = _busNumber.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busNumber.frame = titleFrame;
    
    titleFrame = _busHeading.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busHeading.frame = titleFrame;
    
    titleFrame = _busNumberBackground.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _busNumberBackground.frame = titleFrame;
    
    titleFrame = _arrowImage.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _arrowImage.frame = titleFrame;
    
    titleFrame = _streetName.frame;
    titleFrame.origin.y -= kCellExpandSpacer;
    _streetName.frame = titleFrame;
    
    CGRect frame = _detailsView.frame;
    frame.origin.y = _titleBackground.frame.origin.y + (_titleBackground.frame.size.height - 3);
    
    if(animate)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _detailsView.frame = frame;
        }];
    }
    else
    {
        _detailsView.frame = frame;
    }
}

- (BOOL)isCellUpdated
{
    return _modeLarge;
}

- (void)toggleLoadingAnimation:(BOOL)toggle
{
    if(toggle)
    {
        _arrowImage.hidden =YES;
        [_loadingAnimation startAnimating];
    }
    else 
    {
        _arrowImage.hidden = NO;
        [_loadingAnimation stopAnimating];   
    }
}

- (IBAction)nextTimeClicked:(id)sender
{
    //if([_delegate respondsToSelector:@selector(mtCardCellnextTimeClickedForStop:)])
    if([_delegate conformsToProtocol:@protocol(MTCardCellDelegate)])
        [_delegate mtCardCellnextTimeClickedForStop:_stop];
}

@end
