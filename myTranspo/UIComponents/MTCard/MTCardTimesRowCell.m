//
//  MTCardTimesRowCellCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCardTimesRowCell.h"

@interface MTCardTimesRowCell ()
- (void)initializeUI;
- (void)cellClicked:(id)sender;
@end

@implementation MTCardTimesRowCell
@synthesize delegate =          _delegate;

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    uint leftPos = 0;
    
    _tileColor = [UIColor whiteColor];
    _tileAlternateColor = [UIColor colorWithRed:247./255. green:247./255. blue:247./255. alpha:1.0];
    UIColor *timeColor = [UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0];
    UIColor *dividerColor = [UIColor colorWithRed:239./255. green:238./255. blue:236./255. alpha:1.0];
    
    UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    //background color
    self.contentView.backgroundColor = _tileColor;
    
    //add 5 dividers & 5 labels
    _row1 = [[MTCardCellButton alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidthLong, kCardRowCellHeightLong)], leftPos += kCardRowCellWidthLong;
    _row2 = [[MTCardCellButton alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidthLong, kCardRowCellHeightLong)], leftPos += kCardRowCellWidthLong;
    _row3 = [[MTCardCellButton alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidthLong, kCardRowCellHeightLong)], leftPos += kCardRowCellWidthLong;
    _row4 = [[MTCardCellButton alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidthLong, kCardRowCellHeightLong)], leftPos += kCardRowCellWidthLong;
    _row5 = [[MTCardCellButton alloc] initWithFrame:CGRectMake(leftPos, 0, kCardRowCellWidthLong, kCardRowCellHeightLong)], leftPos += kCardRowCellWidthLong;
    _message = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kCardRowCellHeightLong)];
    
    NSArray *labels = [NSArray arrayWithObjects:_row1, _row2, _row3, _row4, _row5, nil];
    
    for(int x=0; x<labels.count; x++)
    {
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(kCardRowCellWidthLong - 1, 0, 1, kCardRowCellHeightLong)];
        [divider setBackgroundColor:dividerColor];
        
        MTCardCellButton *row = [labels objectAtIndex:x];
        [row addSubview:divider];
        [row setTitleColor:timeColor forState:UIControlStateNormal];
        [row setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [row setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [row addTarget:self action:@selector(cellClicked:) forControlEvents:UIControlEventTouchUpInside];
        row.backgroundColor = [UIColor clearColor];
        row.titleLabel.font = timeFont;
        
        [self.contentView addSubview:row];
        
        leftPos += kCardRowCellWidthLong;
    }
    
    
    _message.backgroundColor = _tileColor;
    _message.textAlignment = UITextAlignmentCenter;
    _message.textColor = timeColor;
    _message.font = timeFont;
    _message.hidden = YES;
    [self.contentView addSubview:_message];
}

- (void)updateRowLabelsRow1:(NSString*)row1 Row1Seq:(int)seq1
                       Row2:(NSString*)row2 Row2Seq:(int)seq2
                       Row3:(NSString*)row3 Row3Seq:(int)seq3
                       Row4:(NSString*)row4 Row4Seq:(int)seq4
                       Row5:(NSString*)row5 Row5Seq:(int)seq5 
                    Section:(int)section 
                        Row:(int)row
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
    
    //NSLog(@"%@ %@ %@ %@ %@", row1, row2, row3, row4, row5);
    
    if(row1 == nil) row1 = @"", seq1 = 0;
    if(row2 == nil) row2 = @"", seq2 = 0;
    if(row3 == nil) row3 = @"", seq3 = 0;
    if(row4 == nil) row4 = @"", seq4 = 0;
    if(row5 == nil) row5 = @"", seq5 = 0;
    
    [_row1 setTitle:row1 forState:_row1.state];
    [_row2 setTitle:row2 forState:_row2.state];
    [_row3 setTitle:row3 forState:_row3.state];
    [_row4 setTitle:row4 forState:_row4.state];
    [_row5 setTitle:row5 forState:_row5.state];
    
    _row1.tag = seq1;
    _row2.tag = seq2;
    _row3.tag = seq3;
    _row4.tag = seq4;
    _row5.tag = seq5;
    
    _row1.extraValue1 = section, _row1.extraValue2 = row;
    _row2.extraValue1 = section, _row2.extraValue2 = row;
    _row3.extraValue1 = section, _row3.extraValue2 = row;
    _row4.extraValue1 = section, _row4.extraValue2 = row;
    _row5.extraValue1 = section, _row5.extraValue2 = row;
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

- (void)cellClicked:(id)sender
{
    if([_delegate conformsToProtocol:@protocol(CardTimesRowCellDelegate)])
        [_delegate cardTimesRow:self ClickedOnCell:(MTCardCellButton*)sender];
}

@end
