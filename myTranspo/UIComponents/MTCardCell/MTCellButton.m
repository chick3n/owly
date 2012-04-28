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

- (void)setHelperHeading:(NSString *)helperHeading
{
    _helperHeading = helperHeading;
    
    if(_useHelperHeading)
    {       
        UIFont* headingFont = [UIFont fontWithName:@"HelveticaNeue" size:14.];
        CGSize helperHeadingSize = [helperHeading sizeWithFont:headingFont constrainedToSize:CGSizeMake(100, 20)];
        
        if(_helperLabel == nil && _helperView == nil)
        { 
            _helperLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
            _helperLabel.font = headingFont;
            _helperLabel.backgroundColor = [UIColor clearColor];
            _helperLabel.textAlignment = UITextAlignmentCenter;
            _helperLabel.textColor = [UIColor whiteColor];
            
            _helperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
            _helperView.backgroundColor = [UIColor blackColor];
            
            [_helperView addSubview:_helperLabel];
        }
        
        CGRect helperLabelFrame = _helperLabel.frame;
        CGRect helperViewFrame = _helperView.frame;
        
        helperLabelFrame.size.width = helperHeadingSize.width;
        helperViewFrame.size.width = helperHeadingSize.width + 20;
        
        helperViewFrame.origin.x = (helperHeadingSize.width / 2) - ((helperHeadingSize.width + 20) / 2);
        helperViewFrame.origin.y = 30;
        
        _helperLabel.frame = helperLabelFrame;
        _helperView.frame = helperViewFrame;
        
    }
    
    _helperLabel.text = helperHeading;
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
