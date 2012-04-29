//
//  MTCardTimesRowCellCell.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCardRowCellHeight 28
#define kCardRowCellWidth 61
#define kRowCount 5

@interface MTCardTimesRowCell : UITableViewCell
{
    UILabel             *_row1;
    UILabel             *_row2;
    UILabel             *_row3;
    UILabel             *_row4;
    UILabel             *_row5;
    UILabel             *_message;
    
    UIColor             *_tileColor;
    UIColor             *_tileAlternateColor;
}

- (void)updateRowLabelsRow1:(NSString*)row1 Row2:(NSString*)row2 Row3:(NSString*)row3 Row4:(NSString*)row4 Row5:(NSString*)row5;
- (void)updateRowBackgroundColor:(BOOL)alternate;
- (void)addNoticeMesssage:(NSString*)message;

@end
