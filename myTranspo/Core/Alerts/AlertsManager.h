//
//  AlertsManager.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-06-03.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTypes.h"
#import "Alert.h"

#define kAlertManagerHeight 43
#define kAlertManagerSpacer 50

@interface AlertsManager : UIView
{
    NSMutableArray *_alerts;
    BOOL            _isActive;
    NSTimer        *_alertTimer;
    
    //UI Components
    UILabel         *_title, *_number, *_desc;
    UIImageView     *_busImage;
    UITapGestureRecognizer *_tapGesture;
}

- (void)addAlert:(UILocalNotification*)notification;

@end
