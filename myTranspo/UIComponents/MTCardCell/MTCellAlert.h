//
//  MTCellAlert.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kCellAlertFrame CGRectMake(0, 0, 100, 30)
#define kCellAlertWidthMax 200
#define kCellAlertHeightMax 30
#define kCellAlertIndent 4

@interface MTCellAlert : UIView
{
    CGPoint _staticPos;
}

@property (nonatomic)           BOOL        hasButtons;
@property (nonatomic, strong)   UILabel     *alert;
@property (nonatomic)           float       runForLength;
@property (nonatomic, weak)     id          refrenceObject;

- (id)init;
- (void)displayAlert:(NSString*)alertText AtPos:(CGPoint)pos ConstrainedTo:(CGSize)size UpsideDown:(BOOL)bottom;
- (void)hideAlertWithSelfInvoke:(BOOL)invoke;
- (void)adjustCoordinates:(CGPoint)coords;

@end
