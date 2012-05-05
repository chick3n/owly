//
//  MTCellAlert.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DCRoundSwitch.h"

#define kCellAlertWidthMin 80
#define kCellAlertWidthMax 200
#define kCellAlertHeightMax 43 //does not include arrow
#define kCellAlertIndent 10
#define kCellAlertLeftOffset 11
#define kCellAlertFrame CGRectMake(0, 0, kCellAlertWidthMin, kCellAlertHeightMax)


@protocol CellAlertDelegate <NSObject>
@required
- (void)cellAlertAccessoryViewClicked:(id)cellAlert;
@end

@interface MTCellAlert : UIView
{
    CGPoint _staticPos;
    UIImageView* _alertBase;
    UIImageView* _alertArrow;
}

@property (nonatomic)           BOOL        hasButtons;
@property (nonatomic, strong)   UILabel     *alert;
@property (nonatomic)           float       runForLength;
@property (nonatomic, weak)     id          refrenceObject;
//@property (nonatomic, strong)   UIButton    *accessoryView;
@property (nonatomic, strong)   DCRoundSwitch* accessoryView;

@property (nonatomic, weak)     id<CellAlertDelegate>          delegate;

- (id)init;
- (void)displayAlert:(NSString*)alertText AtPos:(CGPoint)pos ConstrainedTo:(CGSize)size UpsideDown:(BOOL)bottom;
- (void)toggleAccessoryButton:(BOOL)toggle;
- (void)hideAlertWithSelfInvoke:(BOOL)invoke;
- (void)resumeAlertWithSelfInvoke:(BOOL)invoke;
- (void)adjustCoordinates:(CGPoint)coords;

@end
