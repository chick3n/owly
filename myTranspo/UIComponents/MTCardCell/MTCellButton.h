//
//  MTCellButton.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-27.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTCellButton : UIButton
{
    BOOL        _originalHeadingIsHidden;
    BOOL        _helperHeadingIsHidden;
    
    //UIComponents
    UILabel*    _helperLabel;
    UIView*     _helperView;
}

@property (nonatomic)           BOOL                useSecondaryHeading;
@property (nonatomic)           BOOL                useHelperHeading;
@property (nonatomic, strong)   NSString*           originalHeading;
@property (nonatomic, strong)   NSString*           secondaryHeading;
@property (nonatomic, strong)   NSString*           helperHeading;

@end
