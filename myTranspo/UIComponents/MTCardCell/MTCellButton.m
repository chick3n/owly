//
//  MTCellButton.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-27.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCellButton.h"

@implementation MTCellButton

@synthesize useSecondaryHeading             = _useSecondaryHeading;
@synthesize useHelperHeading                = _useHelperHeading;
@synthesize originalHeading                 = _originalHeading;
@synthesize secondaryHeading                = _secondaryHeading;
@synthesize helperHeading                   = _helperHeading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _originalHeadingIsHidden = NO;
        _helperHeadingIsHidden = YES;
        _useSecondaryHeading = NO;
        _useHelperHeading = NO;
    }
    return self;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [super sendAction:action to:target forEvent:event];
    
    if(_useHelperHeading && _helperView)
    {
#if 0
        NSLog(@"HELPER HEADING: %@", _helperHeading);

        _helperHeadingIsHidden = !_helperHeadingIsHidden;
        if(_helperHeadingIsHidden)
            [_helperView removeFromSuperview];
        else [self addSubview:_helperView];
#endif
    }
    
    if(_useSecondaryHeading)
    {
        NSLog(@"SECONDARY HEADING: %@", _secondaryHeading);
    }
}



@end
