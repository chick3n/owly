//
//  CustomCallout.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol CustomCalloutDelegate <NSObject>

- (void)customCalloutClicked:(id)sender;

@end

@interface CustomCallout : MKAnnotationView
{
    UIView*         _customView;
    UILabel*        _title;
    UILabel*        _subtitle;
    UIButton*       _callBack;
}

@property (nonatomic, weak) id<CustomCalloutDelegate>delegate;

@end
