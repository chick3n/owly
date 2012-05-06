//
//  TripTextField.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "TripTextField.h"

@implementation TripTextField
@synthesize hasTyped;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect 
{
    [[UIColor colorWithRed:157./255. green:157./255. blue:157./255. alpha:1.0] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect leftFrame = self.leftView.frame;
    leftFrame.origin.y = 3;
    self.leftView.frame = leftFrame;
    
    CGRect rightFrame = self.rightView.frame;
    rightFrame.origin.x -= 7;
    self.rightView.frame = rightFrame;
}

@end
