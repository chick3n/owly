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
- (void)drawCalloutForFrame:(CGRect)size AtPos:(CGPoint)pos IsBelow:(BOOL)below;
@end

@implementation MTCellAlert
@synthesize alert               = _alert;
@synthesize hasButtons          = _hasButtons;
@synthesize runForLength        = _runForLength;
@synthesize refrenceObject      = _refrenceObject;
@synthesize accessoryView       = _accessoryView;
@synthesize delegate            = _delegate;

- (void)setAccessoryView:(DCRoundSwitch *)accessoryView
{
    if(_accessoryView != nil)
    {
        [_accessoryView removeTarget:self action:@selector(accessoryViewClicked:) forControlEvents:UIControlEventValueChanged];
        [_accessoryView removeFromSuperview];
    }
    
    _accessoryView = accessoryView;
    if(_accessoryView == nil)
        return;
    
    //_accessoryView.frame = CGRectMake(0, 0, 30, kCellAlertHeightMax);
    CGRect accessoryViewFrame = accessoryView.frame;
    accessoryViewFrame.origin.y = (self.frame.size.height/2) - (accessoryViewFrame.size.height/2);
    accessoryView.frame = accessoryViewFrame;
    [_accessoryView addTarget:self action:@selector(accessoryViewClicked:) forControlEvents:UIControlEventValueChanged];
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
    self.backgroundColor = [UIColor clearColor];    
    
    UIFont* headingFont = [UIFont fontWithName:@"HelveticaNeue" size:16.];

    CGRect alertFrame = CGRectZero;
    alertFrame.origin.x = kCellAlertIndent;
    alertFrame.origin.y = kCellAlertIndent;
    alertFrame.size.width = self.frame.size.width - (alertFrame.origin.x * 2);
    alertFrame.size.height = self.frame.size.height - (alertFrame.origin.y * 2);
    
    UIImage* alertBaseImage = [UIImage imageNamed:@"flyout_plain_top.png"];
    _alertBase = [[UIImageView alloc] initWithFrame:alertFrame];
    _alertBase.contentMode = UIViewContentModeScaleToFill;
    _alertBase.image = [alertBaseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, kCellAlertLeftOffset, 0, kCellAlertLeftOffset)];
    [self addSubview:_alertBase];
    
    _alertArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flyout_plain_arrow.png"]];
    _alertArrow.contentMode = UIViewContentModeTop;
    CGFloat scale = 0.0;
    if(_alertArrow.image.scale == 1) //non retina
        scale = 2.0;
    else scale = 1.0;
    _alertArrow.frame = CGRectMake(kCellAlertLeftOffset, kCellAlertHeightMax-scale, _alertArrow.frame.size.width, _alertArrow.frame.size.height);
    [self addSubview:_alertArrow];
    
    _alertArrowTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flyout_plaindown_arrow.png"]];
    _alertArrowTop.contentMode = UIViewContentModeTop;
    _alertArrowTop.frame = CGRectMake(kCellAlertLeftOffset, -_alertArrowTop.frame.size.height+2.0, _alertArrowTop.frame.size.width, _alertArrowTop.frame.size.height);
    [self addSubview:_alertArrowTop];
    
    CGRect labelFrame = alertFrame;
    labelFrame.origin.x = 8;
    _alert = [[UILabel alloc] initWithFrame:labelFrame];
    _alert.font = headingFont;
    _alert.backgroundColor = [UIColor clearColor];
    _alert.textAlignment = UITextAlignmentLeft;
    _alert.textColor = [UIColor whiteColor];
    _alert.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _alert.shadowOffset = CGSizeMake(0, -1);
    //_alert.clipsToBounds = YES;
    
    [self addSubview:_alert];
}

- (void)displayAlert:(NSString*)alertText AtPos:(CGPoint)pos ConstrainedTo:(CGSize)size UpsideDown:(BOOL)bottom
{
    if(alertText == nil)
        return;
    
    if(alertText.length <= 0)
        return;
    
    CGPoint alertArrowPoint = CGPointZero;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAlert) object:nil];
    
    CGSize alertTextSize = [alertText sizeWithFont:_alert.font constrainedToSize:CGSizeMake(kCellAlertWidthMax, kCellAlertHeightMax)];
    if(alertTextSize.width < kCellAlertWidthMin)
    {
        alertTextSize.width = kCellAlertWidthMin;
        _alert.textAlignment = UITextAlignmentCenter;
    }
    else {
        _alert.textAlignment = UITextAlignmentLeft;
    }
    
    
    CGRect alertFrame = _alert.frame;
    CGRect viewFrame = self.frame;
    
    alertFrame.size.width = alertTextSize.width;
    viewFrame.size.width = alertTextSize.width + (kCellAlertIndent * 2);
    
    if(_accessoryView != nil)
    {
        viewFrame.size.width += (_accessoryView.frame.size.width + 8);
        CGRect accessoryFrame = _accessoryView.frame;
        accessoryFrame.origin.x = viewFrame.size.width - (accessoryFrame.size.width + 8);
        _accessoryView.frame = accessoryFrame;
    }
    
    viewFrame.origin.x = pos.x - (viewFrame.size.width / 2);
    alertArrowPoint.x = (viewFrame.size.width / 2) - (_alertArrow.frame.size.width / 2);
    
    if(bottom == NO)
        viewFrame.origin.y = pos.y - (viewFrame.size.height + (kCellAlertIndent * 2));
    else {
        viewFrame.origin.y = pos.y + (kCellAlertIndent/2 + (kCellAlertIndent * 2));
        //rotate arrow
    }
    
   
    if(viewFrame.origin.x + viewFrame.size.width > size.width)
    {
        float newOrigin = size.width - ((viewFrame.origin.x + viewFrame.size.width) + 2);
        alertArrowPoint.x -= newOrigin; //this is a negative value newOrigin
        viewFrame.origin.x += newOrigin; //always be negative, 4 is to show corner not at edge
    }
    if(viewFrame.origin.x < 0)
    {
        float newOrigin = fabs(viewFrame.origin.x) + 2;
        viewFrame.origin.x += newOrigin;
        alertArrowPoint.x -= newOrigin;
    }
    
    _alert.frame = alertFrame;
    _alert.text = alertText;
    [self drawCalloutForFrame:viewFrame AtPos:alertArrowPoint IsBelow:bottom];
    self.frame = viewFrame;
    
    self.hidden = NO;

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
    
#if 0
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     }
                    completion:^(BOOL finished) {
                        self.hidden = YES;
                        self.alpha = 1.0;
                    }];
#endif
    
    self.hidden = YES;
}

- (void)resumeAlertWithSelfInvoke:(BOOL)invoke
{
    if(invoke)
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAlert) object:nil];
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:_runForLength];
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
        //_accessoryView.selected = toggle;
        [_accessoryView setOn:toggle animated:NO ignoreControlEvents:YES];
    }
}

- (void)accessoryViewClicked:(id)sender
{
    if([_delegate conformsToProtocol:@protocol(CellAlertDelegate)])
        [_delegate cellAlertAccessoryViewClicked:self];
}

- (void)drawCalloutForFrame:(CGRect)size AtPos:(CGPoint)pos IsBelow:(BOOL)below
{
    size.origin.x = 0;
    size.origin.y = 0;
    
    _alertBase.frame = size;
    
    if(below)
    {
        _alertArrow.hidden = YES;
        _alertArrowTop.hidden = NO;
        
        if((pos.x + _alertArrowTop.frame.size.width) > (size.size.width - kCellAlertLeftOffset))
            pos.x = (size.size.width - kCellAlertLeftOffset) - (_alertArrowTop.frame.size.width);
        
        CGRect arrow = _alertArrowTop.frame;
        arrow.origin.x = pos.x;
        _alertArrowTop.frame = arrow;
    }
    else {
        _alertArrowTop.hidden = YES;
        _alertArrow.hidden = NO;
        
        if((pos.x + _alertArrow.frame.size.width) > (size.size.width - kCellAlertLeftOffset))
            pos.x = (size.size.width - kCellAlertLeftOffset) - (_alertArrow.frame.size.width);
        
        CGRect arrow = _alertArrow.frame;
        arrow.origin.x = pos.x;
        _alertArrow.frame = arrow;
    }

#if 0
    if(below)
    {
        _alertBase.transform = CGAffineTransformMakeRotation(M_PI);
        _alertArrow.transform = CGAffineTransformMakeRotation(M_PI);
    }
#endif
}

@end
