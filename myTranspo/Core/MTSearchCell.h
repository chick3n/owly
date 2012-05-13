//
//  MTSearchCell.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTHelper.h"

#define kMTSEARCHCELLHEIGHT 44
#define kMTSEARCHCELLSHAPEHEIGHT 45
#define kMTSEARCHCELLSHAPEWIDTH 45

#define kOffSetOriginX 0
#define kOffSetOriginY 13
#define kOffSetSubtitleOriginX kOffSetOriginX + 45
#define kOffSetSubtitleOriginY kOffSetOriginY

#define kOffSetBusDrawOriginX 0
#define kOffSetBusDrawOriginY -2

typedef enum
{
    CELLBUS = 0
    , CELLSTOP
    , CELLSTREET
    , CELLNOTICE
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
    UIImageView*            _backgroundImage;
    UIImageView*            _cellImage;
}

@property (nonatomic, strong)   NSString*               title;
@property (nonatomic, strong)   NSString*               subtitle;
@property (nonatomic)           MTSearchType            type;

- (void)update;
- (void)hideBusImage:(BOOL)toggle;

@end
