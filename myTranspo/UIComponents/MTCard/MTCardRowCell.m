//
//  MTCardRowCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-26.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardRowCell.h"

@interface MTCardRowCell ()
- (void)initializeUI;
@end

@implementation MTCardRowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
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
    uint leftPos = 0;
    
    _tileColor = [UIColor whiteColor];
    _tileAlternateColor = [UIColor colorWithRed:247./255. green:247./255. blue:247./255. alpha:1.0];
    UIColor *timeColor = [UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0];
    UIColor *dividerColor = [UIColor colorWithRed:239./255. green:238./255. blue:236./255. alpha:1.0];
    
    UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    //background color
    self.contentView.backgroundColor = _tileColor;
    
    //add 5 dividers & 5 labels
    _row1 = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidth, kCardRowCellHeight)], leftPos += kCardRowCellWidth;
    _row2 = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidth, kCardRowCellHeight)], leftPos += kCardRowCellWidth;
    _row3 = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidth, kCardRowCellHeight)], leftPos += kCardRowCellWidth;
    _row4 = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidth, kCardRowCellHeight)], leftPos += kCardRowCellWidth;
    _row5 = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidth, kCardRowCellHeight)], leftPos += kCardRowCellWidth;
    _message = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kCardRowCellHeight)];
    
    NSArray *labels = [NSArray arrayWithObjects:_row1, _row2, _row3, _row4, _row5, nil];
    
    for(int x=0; x<labels.count; x++)
    {
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(59, 0, 1, 28)];
        [divider setBackgroundColor:dividerColor];
        
        UILabel *row = [labels objectAtIndex:x];
        [row addSubview:divider];
        row.textColor = timeColor;
        row.backgroundColor = [UIColor clearColor];
        row.textAlignment = UITextAlignmentCenter;
        row.font = timeFont;
        
        [self.contentView addSubview:row];
        
        leftPos += kCardRowCellWidth;
    }
    
    
    _message.backgroundColor = _tileColor;
    _message.textAlignment = UITextAlignmentCenter;
    _message.textColor = timeColor;
    _message.font = timeFont;
    _message.hidden = YES;
    [self.contentView addSubview:_message];
}

- (void)updateRowLabelsRow1:(NSString*)row1 Row2:(NSString*)row2 Row3:(NSString*)row3 Row4:(NSString*)row4 Row5:(NSString*)row5
{
    if(row1 == nil && row2 == nil && row3 == nil && row4 == nil && row5 == nil)
    {
        _message.hidden = NO;
        _message.text = NSLocalizedString(@"MTDEF_CARDNOTIME", nil);
        
        _row1.hidden = YES;
        _row2.hidden = YES;
        _row3.hidden = YES;
        _row4.hidden = YES;
        _row5.hidden = YES;
        return;
    }
    
    if(!_message.hidden)
        _message.hidden = YES;
    if(_row1.hidden)
        _row1.hidden = NO;
    if(_row2.hidden)
        _row2.hidden = NO;
    if(_row3.hidden)
        _row3.hidden = NO;
    if(_row4.hidden)
        _row4.hidden = NO;
    if(_row5.hidden)
        _row5.hidden = NO;
    
    _row1.text = (row1 == nil) ? @"" : row1;
    _row2.text = (row2 == nil) ? @"" : row2;
    _row3.text = (row3 == nil) ? @"" : row3;
    _row4.text = (row4 == nil) ? @"" : row4;
    _row5.text = (row5 == nil) ? @"" : row5;
}

- (void)updateRowBackgroundColor:(BOOL)alternate
{
    if(alternate == YES && self.backgroundColor != _tileAlternateColor)
        self.contentView.backgroundColor = _tileAlternateColor;
    else if(alternate == NO && self.backgroundColor != _tileColor)
        self.contentView.backgroundColor = _tileColor;
}

- (void)addNoticeMesssage:(NSString*)message
{
    _message.hidden = NO;
    _message.text = message;
    
    _row1.hidden = YES;
    _row2.hidden = YES;
    _row3.hidden = YES;
    _row4.hidden = YES;
    _row5.hidden = YES;
    return;
}

@end
