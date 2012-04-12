//
//  MTBaseViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myTranspoOC.h"

@interface MTBaseViewController : UIViewController
{
    MTLanguage              _language;
    myTranspoOC* __weak     _transpo;
    
    //UI Components
    UIPanGestureRecognizer* __weak  _panGesture;
    UIPanGestureRecognizer* __weak  _navPanGesture;
}

@property (nonatomic)           MTLanguage                  language;
@property (nonatomic, weak)     myTranspoOC*                transpo;
@property (nonatomic, weak)     UIPanGestureRecognizer*     panGesture;
@property (nonatomic, weak)     UIPanGestureRecognizer*     navPanGesture;

@end
