//
//  MTNavFooter.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-23.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTNavFooter.h"

@implementation MTNavFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_view];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
