//
//  MTBaseViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"

@implementation MTBaseViewController
@synthesize language                = _language;
@synthesize transpo                 = _transpo;
@synthesize panGesture              = _panGesture;
@synthesize navPanGesture           = _navPanGesture;
@synthesize menuControl             = _menuControl;
@synthesize viewControllerType      = _viewControllerType;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

@end
