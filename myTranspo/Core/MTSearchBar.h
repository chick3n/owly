//
//  MTSearchBar.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTSearchBar : UISearchBar
{
    UIActivityIndicatorView*        _loading;
    UIView*                         _searchIcon;
    UITextField*                    _mtSearchField;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
