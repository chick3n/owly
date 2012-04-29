//
//  MTCellAlert.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTCellAlert.h"

@interface MTCellAlert ()
- (void)initializeUI;
- (void)hideAlert;
- (void)accessoryViewClicked:(id)sender;
@end

@implementation MTCellAlert
@synthesize alert               = _alert;
@synthesize hasButtons          = _hasButtons;
@synthesize runForLength        = _runForLength;
@synthesize refrenceObject      = _refrenceObject;
@synthesize accessoryView       = _accessoryView;
@synthesize delegate            = _delegate;

- (void)setAccessoryView:(UIButton *)accessoryView
{
    if(_accessoryView != nil)
    {
        [_accessoryView removeTarget:self action:@selector(accessoryViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView removeFromSuperview];
    }
    
    _accessoryView = accessoryView;
    if(_accessoryView == nil)
        return;
    
    _accessoryView.frame = CGRectMake(0, 0, 30, kCellAlertHeightMax);
    [_accessoryView addTarget:self action:@selector(accessoryViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_accessoryView];
}

- (id)init
{
    self = [super initWithFrame:kCellAlertFrame];
    if (self) {
        _hasButtons = NO;
        _runForLength = 2.0;
        [self initializeUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.frame = kCellAlertFrame;
        _hasButtons = NO;
        _runForLength = 2.0;
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI
{
    //self.clipsToBounds = YES;
    self.hidden = YES;
    self.backgroundColor = [UIColor blackColor];    
    
    UIFont* headingFont = [UIFont fontWithName:@"HelveticaNeue" size:14.];

    CGRect alertFrame = CGRectZero;
    alertFrame.origin.x = kCellAlertIndent;
    alertFrame.origin.y = kCellAlertIndent;
    alertFrame.size.width = self.frame.size.width - (alertFrame.origin.x * 2);
    alertFrame.size.height = self.frame.size.height - (alertFrame.origin.y * 2);
    
    _alert = [[UILabel alloc] initWithFrame:alertFrame];
    _alert.font = headingFont;
    _alert.backgroundColor = [UIColor clearColor];
    _alert.textAlignment = UITextAlignmentCenter;
    _alert.textColor = [UIColor whiteColor];
    //_alert.clipsToBounds = YES;
    
    [self addSubview:_alert];
}

- (void)displayAlert:(NSString*)alertText AtPos:(CGPoint)pos ConstrainedTo:(CGSize)size UpsideDown:(BOOL)bottom
{
    if(alertText == nil)
        return;
    
    if(alertText.length <= 0)
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAlert) object:nil];
    
    CGSize alertTextSize = [alertText sizeWithFont:_alert.font constrainedToSize:CGSizeMake(kCellAlertWidthMax, kCellAlertHeightMax)];
    
    CGRect alertFrame = _alert.frame;
    CGRect viewFrame = self.frame;
    
    alertFrame.size.width = alertTextSize.width;
    viewFrame.size.width = alertTextSize.width + (kCellAlertIndent * 2);
    
    if(_accessoryView != nil)
    {
        viewFrame.size.width += _accessoryView.frame.size.width;
        CGRect accessoryFrame = _accessoryView.frame;
        accessoryFrame.origin.x = viewFrame.size.width - accessoryFrame.size.width;
        _accessoryView.frame = accessoryFrame;
    }
    
    viewFrame.origin.x = pos.x - (viewFrame.size.width / 2);
    if(bottom == NO)
        viewFrame.origin.y = pos.y - (viewFrame.size.height + (kCellAlertIndent * 2));
    else {
        viewFrame.origin.y = pos.y + (viewFrame.size.height + (kCellAlertIndent * 2));
        //rotate arrow
    }
    
    if(viewFrame.origin.x + viewFrame.size.width > size.width)
        viewFrame.origin.x += size.width - (viewFrame.origin.x + viewFrame.size.width); //always be negative
    if(viewFrame.origin.x < 0)
        viewFrame.origin.x = 0;
    
    _alert.frame = alertFrame;
    _alert.text = alertText;
    self.frame = viewFrame;
    
    self.hidden = NO;
#if 0
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(hideAlert) withObject:nil afterDelay:_runForLength];
                     }];
#endif
    self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.8],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.3;
    bounceAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    self.layer.transform = CATransform3DIdentity;
    
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:_runForLength];
}

- (void)hideAlert
{
    [self hideAlertWithSelfInvoke:NO];
}

- (void)hideAlertWithSelfInvoke:(BOOL)invoke
{
    if(invoke)
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAlert) object:nil];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     }
                    completion:^(BOOL finished) {
                        self.hidden = YES;
                        self.alpha = 1.0;
                    }];
}

- (void)adjustCoordinates:(CGPoint)coords
{
    CGRect frame = self.frame;
    frame.origin.x = coords.x;
    //float newPos = coords.x - frame.origin.x;
    
    //frame.origin.x += newPos - frame.origin.x;
    //frame.origin.x = coords.x - _staticPos.x;
    self.frame = frame;
}

- (void)toggleAccessoryButton:(BOOL)toggle
{
    if(_accessoryView != nil)
    {
        _accessoryView.selected = toggle;
    }
}

- (void)accessoryViewClicked:(id)sender
{
    NSLog(@"Click accessory view");
    if([_delegate conformsToProtocol:@protocol(CellAlertDelegate)])
        [_delegate cellAlertAccessoryViewClicked:self];
}

@end
