//
//  MTCardTimesRowCellCell.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCardCellButton.h"

#define kCardRowCellHeightLong 28
#define kCardRowCellWidthLong 64 //61
#define kRowCount 5

@protocol CardTimesRowCellDelegate <NSObject>
@required
- (void)cardTimesRow:(id)owner ClickedOnCell:(MTCardCellButton*)cell;

@end

@interface MTCardTimesRowCell : UITableViewCell
{
    MTCardCellButton            *_row1;
    MTCardCellButton            *_row2;
    MTCardCellButton            *_row3;
    MTCardCellButton            *_row4;
    MTCardCellButton            *_row5;
    UILabel                     *_message;
    
    UIColor                     *_tileColor;
    UIColor                     *_tileAlternateColor;
}

@property (nonatomic, weak) id<CardTimesRowCellDelegate> delegate;

- (void)updateRowLabelsRow1:(NSString*)row1 Row1Seq:(int)seq1
                       Row2:(NSString*)row2 Row2Seq:(int)seq2
                       Row3:(NSString*)row3 Row3Seq:(int)seq3
                       Row4:(NSString*)row4 Row4Seq:(int)seq4
                       Row5:(NSString*)row5 Row5Seq:(int)seq5 
                    Section:(int)section
                        Row:(int)row;
- (void)updateRowBackgroundColor:(BOOL)alternate;
- (void)addNoticeMesssage:(NSString*)message;

@end
