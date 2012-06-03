//
//  AlertsManager.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-06-03.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "AlertsManager.h"

@interface AlertsManager ()
- (void)displayAlert;
- (void)hideAlert;
- (void)initializeUI;
- (void)tapRecognizer:(UITapGestureRecognizer*)recognizer;
- (void)alertTimerTick;
- (void)displayNextAlert;
@end

@implementation AlertsManager

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _alerts = [[NSMutableArray alloc] init];
        _isActive = NO;
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI
{
    self.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"global_alert.png"]] colorWithAlphaComponent:0.98];
    
    _busImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_busnumber_bg.png"]];
    //_busImage.contentMode = UIViewContentModeScaleAspectFit;
    CGRect busFrame = _busImage.frame;
    busFrame.origin.x = 4;
    busFrame.origin.y = 3;
    busFrame.size.height = 38;
    busFrame.size.width = 38;
    _busImage.frame = busFrame;
    [self addSubview:_busImage];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(kAlertManagerSpacer, 8, 320-kAlertManagerSpacer, 14)];
    _title.backgroundColor = [UIColor clearColor];
    _title.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
    _title.textColor = [UIColor whiteColor];
    _title.shadowColor = [UIColor blackColor];
    _title.shadowOffset = CGSizeMake(0, -1);
    [self addSubview:_title];
    
    _number = [[UILabel alloc] initWithFrame:CGRectMake(8, 15, 30, 14)];
    _number.backgroundColor = [UIColor clearColor];
    _number.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
    _number.textColor = [UIColor whiteColor];
    _number.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.10];
    _number.shadowOffset = CGSizeMake(0, 1);
    _number.textAlignment = UITextAlignmentCenter;
    [self addSubview:_number];
    
    _desc = [[UILabel alloc] initWithFrame:CGRectMake(kAlertManagerSpacer, 22, 320-kAlertManagerSpacer, 14)];
    _desc.backgroundColor = [UIColor clearColor];
    _desc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    _desc.textColor = [UIColor whiteColor];
    _desc.shadowColor = [UIColor blackColor];
    _desc.shadowOffset = CGSizeMake(0, -1);
    [self addSubview:_desc];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
    [self addGestureRecognizer:_tapGesture];
}

- (void)addAlert:(UILocalNotification *)notification
{
#if 1
    NSDictionary *userInfo = notification.userInfo;
    
    Alert *alert = [[Alert alloc] init];
    
    alert.number = [userInfo valueForKey:kMTNotificationBusNumberKey];
    alert.title = [userInfo valueForKey:kMTNotificationBusDisplayHeading];
    alert.desc = [NSString stringWithFormat:NSLocalizedString(@"MTDEF_NEWALERTTIMEMESSAGE", nil)
                  , [userInfo valueForKey:kMTNotificationTripTimeKey]];
    
    [_alerts addObject:alert];
#endif    
    
#if 0
    Alert *alert = [[Alert alloc] init];
    Alert *alert2 = [[Alert alloc] init];
    
    [_alerts addObject:alert];
    [_alerts addObject:alert2];
#endif
    if(!_isActive)
    {
        _isActive = YES;
        
        //launch pop up
        [self displayAlert];
    }
}

- (void)displayAlert
{
    //populate fields
#if 1
    Alert *alert = [_alerts objectAtIndex:0];
    [_alerts removeObjectAtIndex:0];
    
    _number.text = alert.number;
    _title.text = alert.title;
    _desc.text = alert.desc;
#endif
#if 0
    _number.text = @"123";
    _title.text = @"Fallowfield Station";
    _desc.text = @"is scheduled to arrive at 6:15 PM";
#endif
    CGRect displayFrame = self.frame;
    displayFrame.origin.y -= displayFrame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.frame = displayFrame;
                     }
     completion:^(BOOL finished) {
         if(finished)
         {
             if(_alertTimer != nil)
             {
                 [_alertTimer invalidate];
                 _alertTimer = nil;
             }
             _alertTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(alertTimerTick) userInfo:nil repeats:YES];
         }
     }];
}

- (void)displayNextAlert
{
    //populate fields
    _number.alpha = 0.f;
    _title.alpha = 0.f;
    _desc.alpha = 0.f;
    
#if 1
    Alert *alert = [_alerts objectAtIndex:0];
    [_alerts removeObjectAtIndex:0];
    
    _number.text = alert.number;
    _title.text = alert.title;
    _desc.text = alert.desc;
#endif
#if 0
    _number.text = @"456";
    _title.text = @"Baseline Station";
    _desc.text = @"is scheduled to arrive at 12:15 PM";
#endif
    [UIView animateWithDuration:0.5
                     animations:^{
                         _number.alpha = 1.f;
                         _title.alpha = 1.f;
                         _desc.alpha = 1.f;
                     }];
}

- (void)hideAlert
{
    CGRect displayFrame = self.frame;
    
    displayFrame.origin.y += displayFrame.size.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.frame = displayFrame;
                     }];
    
    _isActive = NO;
    
    if(_alertTimer)
    {
        [_alertTimer invalidate];
        _alertTimer = nil;
    }
}

- (void)tapRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self hideAlert];
}

- (void)alertTimerTick
{
    if(_alerts.count > 0)
    {
        [self displayNextAlert];
    }
    else {
        [self hideAlert];
    }
}

@end
