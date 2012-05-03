//
//  MTRightButton.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-15.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRightButtonTypeBack 0
#define kRightButtonTypeSingle 1
#define kRightButtonTypeAction 2

#define kRightButtonViewTag 101

@interface MTRightButton : UIButton
{
    int _type;
}

- (id)initWithType:(int)type;

@end