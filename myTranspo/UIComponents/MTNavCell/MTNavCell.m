//
//  MTNavCell.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-23.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTNavCell.h"

@interface MTNavCell ()

@end

@implementation MTNavCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray* mtCardCellXib = [[NSBundle mainBundle] loadNibNamed:@"MTNavCell" owner:self options:nil];
        [self addSubview:[mtCardCellXib objectAtIndex:0]];
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIView * background = [[UIView alloc] initWithFrame:self.frame];
    background.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.selectedBackgroundView = background;
}

- (void)initializeUI
{
    _notificationImage.hidden = YES;
    _notificationMessage.hidden = YES;
}

- (void)updateNotificationMessage:(NSString*)count isImportant:(BOOL)important
{
    if(count == nil)
    {
        _notificationMessage.hidden = YES;
        _notificationMessage.text = @"";
        _notificationImage.hidden = YES;
        return;
    }
    
    //_notificationImage.image = [UIImage imageNamed:@""];
    _notificationImage.hidden = NO;
    _notificationMessage.text = count;
    _notificationMessage.hidden = NO;
    
    CGRect frame2 = _notificationMessage.frame;
    frame2.size.width = [count sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16]].width + 13;
    _notificationMessage.frame = frame2;
    
    //set width
    CGRect frame = _notificationImage.frame;
    frame.size.width = _notificationMessage.frame.size.width;
    _notificationImage.frame = frame;
    
    if(important) 
        _notificationImage.backgroundColor = kMTNAVCELLNOTIFIERCOLOR;
    else _notificationImage.backgroundColor = kMTNAVCELLNOTIFIERNORMALCOLOR;
    
    _notificationImage.layer.cornerRadius = 5;
}

- (void)updateNavCell:(MTNavIcon)icon WithTitle:(NSString*)title
{
    switch (icon) {
        case MTNAVICONACCOUNT:
            _navImage.image = [UIImage imageNamed:@"menu_account_icon.png"];
            break;
        case MTNAVICONFAVORITES:
            _navImage.image = [UIImage imageNamed:@"menu_mybuses_icon.png"];
            break;
        case MTNAVICONSTOPS:
            _navImage.image = [UIImage imageNamed:@"menu_busstops_icon.png"];
            break;
        case MTNAVICONTRAINS:
            _navImage.image = [UIImage imageNamed:@"menu_trainblue_icon.png"];
            break;
        case MTNAVICONNOTICES:
            _navImage.image = [UIImage imageNamed:@"menu_news_icon.png"];
            break;
        case MTNAVICONTRIPPLANNER:
            _navImage.image = [UIImage imageNamed:@"menu_tripplanner_icon.png"];
            break;
    }
    
    _navTitle.text = title;
}

- (void)updateNotificationAlert
{
    if(_notificationImage.hidden == NO)
    {
        _notificationMessage.text = @"";
        _notificationMessage.hidden = YES;
    }
    
    //_notificationImage.image = [UIImage imageNamed:@""];
}

@end
