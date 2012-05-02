//
//  MTRightButton.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-15.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTRightButton.h"

@interface MTRightButton ()
- (void)initializeUI;
@end

@implementation MTRightButton

- (id)initWithType:(int)type
{
    self = [super init];
    if(self)
    {
        _type = type;
        self.tag = kRightButtonViewTag;
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI
{
    self.frame = CGRectMake(0, 0, 50, 29);
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    UIImage *defaultBackground = nil;
    if(_type == kRightButtonTypeBack)
        defaultBackground = [UIImage imageNamed:@"global_backempty_btn.png"];
    else defaultBackground = [UIImage imageNamed:@"global_right_btn.png"];
    
    //resize it
    UIImage *strechBackground = [defaultBackground resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    
    [self setBackgroundImage:strechBackground forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
}

#if 1
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    CGSize textSize = [title sizeWithFont:self.titleLabel.font];
    
    if(textSize.width > 40)
        textSize.width = 40;
    
    CGRect frame = self.frame;
    frame.size.width = textSize.width + ((_type == kRightButtonTypeBack) ? 20 : 20);
    self.frame = frame;
    
    [super setTitle:title forState:state];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(_type == kRightButtonTypeBack)
    {
        CGRect frame = self.titleLabel.frame;
        frame.origin.x += 4;
        self.titleLabel.frame = frame;
    }
}
#endif
@end
