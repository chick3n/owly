//
//  MTNavHeader.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-23.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTypes.h"
#import "MTDefinitions.h"

#define kMTNAVHEADERHEIGHT 23

typedef enum
{
    MTNAVHEADERMENU = 0
} MTNavHeaderTitle;

@interface MTNavHeader : UIView
{
    UIView*             _view;
    MTLanguage          _language;
    NSString*           _title;
    MTNavHeaderTitle    _titleType;
}

- (id)initWithLanguage:(MTLanguage)language AndTitle:(MTNavHeaderTitle)titleType;

@end
