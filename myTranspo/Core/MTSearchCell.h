//
//  MTSearchCell.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    CELLBUS = 0
    , CELLSTOP
    , CELLSTREET
} MTSearchType;

@interface MTSearchCellShape : UIView
@property (nonatomic) CGSize size;
@property (nonatomic) MTSearchType type;
@end

@interface MTSearchCell : UITableViewCell
{
    UILabel*                _titleLabel;
    UILabel*                _subtitleLabel;
    MTSearchCellShape*      _titleBackground;
}

@property (nonatomic, strong)   NSString*               title;
@property (nonatomic, strong)   NSString*               subtitle;
@property (nonatomic)           MTSearchType            type;

- (void)update;

@end
