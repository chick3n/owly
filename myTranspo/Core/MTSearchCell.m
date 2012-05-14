//
//  MTSearchCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

//stop gradient: BLUE: bottom: 68 194 244, top: 114 210 248, inner drop shadow: color: 0 100 140, 18% alpha position 1, 0
//color: black, 15% alpha, 0, 1
//cell background trip cell
//search bar background image.

#import "MTSearchCell.h"


@interface MTSearchCell ()
- (void)initializeUI;
- (void)drawBus;
- (void)drawStop;
- (void)drawStreet;
- (void)drawNotice;
@end

@implementation MTSearchCell
@synthesize title               = _title;
@synthesize subtitle            = _subtitle;
@synthesize type                = _type;
@synthesize displayAccessoryView = _displayAccessoryView;
@synthesize myAccessoryView     = _myAccessoryView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(_displayAccessoryView == YES)
    {
        CGRect frame = self.accessoryView.frame;
        frame.origin.x += 10;
        self.accessoryView.frame = frame;
    }
}


#define kDefaultLabelFrame CGRectMake(kOffSetOriginX, kOffSetOriginY, kMTSEARCHCELLSHAPEWIDTH, 16)
#define kSubtitleLabelFrame CGRectMake(kOffSetSubtitleOriginX, kOffSetOriginY, 320 - kOffSetSubtitleOriginX, 16)

- (void)initializeUI
{
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
        
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_cell_line.png"]];
    CGRect frame = _backgroundImage.frame;
    frame.origin.y = self.frame.size.height - 2;
    _backgroundImage.frame = frame;
    [_backgroundImage setFrame:frame];
    [self.contentView addSubview:_backgroundImage];
    
    _cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(kOffSetBusDrawOriginX, kOffSetBusDrawOriginY, 20, 20)];
    _cellImage.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:_cellImage];
    
    _titleLabel = [[UILabel alloc] initWithFrame:kDefaultLabelFrame];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.10];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:kSubtitleLabelFrame];
    _subtitleLabel.textColor = [UIColor colorWithRed:59./255. green:59./255. blue:59./255. alpha:1.0];
    _subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    _subtitleLabel.textAlignment = UITextAlignmentLeft;
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_subtitleLabel];
    
    UIView * selection = [[UIView alloc] initWithFrame:self.frame];
    selection.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.04];
    self.selectedBackgroundView = selection;
}

- (void)update
{
    //redraw based on type
    _titleBackground.type = _type;
    
    if(_type == CELLBUS)
        [self drawBus];
    else if(_type == CELLSTOP)
        [self drawStop];
    else if(_type == CELLSTREET)
        [self drawStreet];
    else if(_type == CELLNOTICE)
        [self drawNotice];
    
    if(_displayAccessoryView && _subtitleLabel.frame.size.width >= kSubtitleLabelFrame.size.width)
    {
        CGRect frame = _subtitleLabel.frame;
        frame.size.width = 206;
        _subtitleLabel.frame = frame;
    }
    
    //[_titleBackground setNeedsDisplay];
}

- (void)hideBusImage:(BOOL)toggle
{
    _cellImage.hidden = toggle;
    
    CGRect frame = _subtitleLabel.frame;
    if(toggle == YES)
        frame.origin.x = 8;
    else frame.origin.x = kSubtitleLabelFrame.origin.x;
    _subtitleLabel.frame = frame;
}

- (void)drawBus
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    _subtitleLabel.text = _subtitle;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_busnumber_bg.png"];
}

- (void)drawStop
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_busstop_icon.png"];
    
    _subtitleLabel.text = _subtitle;
}

- (void)drawStreet
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_street_icon.png"];

    _subtitleLabel.text = _subtitle;
}

- (void)drawNotice
{
    //48 12 206 16 21
    //262 12 48 21

    _titleLabel.frame = CGRectMake(10, 12, self.frame.size.width - 40, 21);
    //_subtitleLabel.frame = CGRectMake(self.frame.size.width - 80 - 10, 12, 80, 21);
    
    _titleLabel.textColor =[UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
    _titleLabel.textAlignment = UITextAlignmentLeft;
    _titleLabel.shadowColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    _titleLabel.text = _title;
   // _subtitleLabel.text = [f2 stringFromDate:[f dateFromString:_subtitle]];
}

@end
