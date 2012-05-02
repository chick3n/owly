//
//  TripDetailsCell.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinTripCellHeight 44

@interface TripDetailsCell : UITableViewCell
{
    UIImageView*            _leftAccessory;
    UILabel*                _rightAccessory;
    UILabel*                _text;
    UIImageView*            _seperator;
}

@property (nonatomic, weak)     UIImage*        leftAccessoryImage;
@property (nonatomic, weak)     NSString*       rightAccessoryText;
@property (nonatomic)           BOOL            indent;
@property (nonatomic, strong)   UILabel*        text;

@end
