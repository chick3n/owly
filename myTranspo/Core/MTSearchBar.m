//
//  MTSearchBar.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTSearchBar.h"

@implementation MTSearchBar

- (void)layoutSubviews
{    
    for(UIView* view in self.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            _mtSearchField = (UITextField*)view;
            break;
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
    
    [super layoutSubviews];
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
