//
//  MTSearchBar.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTSearchBar.h"

@interface MTSearchBar ()
- (void)initAppearance;
@end

@implementation MTSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initAppearance];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initAppearance];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initAppearance];
    }
    return self;
}

- (void)initAppearance
{
#if 0
    [[UIButton appearanceWhenContainedIn:[MTSearchBar class], nil] setBackgroundImage:[UIImage imageNamed:@"global_right_btn.png"] forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[MTSearchBar class], nil] setBackgroundImage:[UIImage imageNamed:@"global_right_btn.png"] forState:UIControlStateHighlighted];
#endif
    
    for(UIView* view in self.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            _mtSearchField = (UITextField*)view;
            [(UITextField*)view setClearButtonMode:UITextFieldViewModeWhileEditing];
        }
    }
    if(_mtSearchField != nil)
    {
        if(_loading == nil)
        {
            _loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _searchIcon = _mtSearchField.leftView;
        //_mtSearchField.leftView = _loading;
    }
    
    /*[[UIButton appearanceWhenContainedIn:[MTSearchBar class], nil] 
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor blackColor], UITextAttributeTextColor
     , [UIColor whiteColor], UITextAttributeTextShadowColor
     //, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset
     , [UIFont fontWithName:@"HelveticaNeue" size:16.0], UITextAttributeFont
     , nil] forState:UIControlStateNormal];*/
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for(UIView* view in self.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            UITextField* text = (UITextField*)view;
            text.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
            text.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        }
        else if([view isKindOfClass:[UIButton class]]) //make cancel button bigger
        {
            CGRect btnFrame = view.frame;
            btnFrame.size.width += 10;
            btnFrame.origin.x -= 10;
            view.frame = btnFrame;
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    if([subview isKindOfClass:[UIButton class]])
    {
        [(UIButton*)subview setBackgroundImage:[UIImage imageNamed:@"global_alt_btn.png"] forState:UIControlStateNormal];
        [(UIButton*)subview setBackgroundImage:[UIImage imageNamed:@"global_alt_btn.png"] forState:UIControlStateHighlighted];
        [((UIButton*)subview).titleLabel setShadowOffset:CGSizeMake(0, 1)];
    }
}

- (void)startAnimating
{
    if(_mtSearchField == nil)
        return;
    
    _mtSearchField.leftView = _loading;
    [_loading startAnimating];
    
}

- (void)stopAnimating
{
    _mtSearchField.leftView = _searchIcon;
    [_loading stopAnimating];
}

@end
