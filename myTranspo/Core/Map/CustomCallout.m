//
//  CustomCallout.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "CustomCallout.h"

@interface CustomCallout ()
//- (void)initializeUI;
@end

@implementation CustomCallout

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#if 0
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI
{
    _customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 60)];
    _customView.backgroundColor = [UIColor brownColor];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 20)];
    _title.text = @"TEST1";
    
    _subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 140, 20)];
    _subtitle.text = @"TEST2";
    
    _callBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _callBack.frame = CGRectMake(0, 40, 100, 100);
    [_callBack setTitle:@"TEST BTN" forState:UIControlStateNormal];
    
    [_customView addSubview:_title];
    [_customView addSubview:_subtitle];
    [_customView addSubview:_callBack];
    
    CGRect customFrame = _customView.frame;
    customFrame.origin.x = self.frame.origin.x;
    customFrame.origin.y = self.frame.origin.y - customFrame.size.height;
    _customView.frame = customFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(selected)
        [self addSubview:_customView];
    else [_customView removeFromSuperview];
    
}
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UILabel* text1, *text2, *text3;
    
    for(UIView* view in self.subviews)
    {
        for(UIView* subview in view.subviews)
        {
            if([subview isKindOfClass:[UILabel class]])
            {
                if(text1 == nil)
                    text1 = (UILabel*)subview;
                else if(text2 == nil)
                    text2 = (UILabel*)subview;
                else if(text3 == nil)
                    text3 = (UILabel*)subview;
            }
#if 0 //adds a darken filter to each image, VERY SLOW
            else if([subview isKindOfClass:[UIImageView class]])
            {
                UIImageView* imageView = (UIImageView*)subview;
                UIImage* defaultImage = imageView.image;
                CIImage* cgImage = [[CIImage alloc] initWithImage:defaultImage];
                CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"];
                
                [filter setDefaults];
                [filter setValue:cgImage forKey:@"inputImage"];
                [filter setValue:[NSNumber numberWithFloat:-2.0] forKey:@"inputEV"];
                
                CIImage* newImage = [filter outputImage];
                CIContext* context = [CIContext contextWithOptions:nil];
                CGImageRef cgImageRef = [context createCGImage:newImage fromRect:newImage.extent];
                UIImage* resultImage = [UIImage imageWithCGImage:cgImageRef];
                
                imageView.image = resultImage;
            }
#endif
        }
    }
    
    UILabel* largest, *second, *third;
    
    if(text1 != nil && text2 != nil && text3 != nil)
    {
        if(text1.frame.size.height > text2.frame.size.height)
        {
            if(text1.frame.size.height > text3.frame.size.height)
            {
                largest = text1;
                second = text2;
                third = text3;
            }
            else 
            {
                largest = text3;
                second = text2;
                third = text1;
            }
        }
        else if(text2.frame.size.height > text3.frame.size.height)
        {
            largest = text2;
            second = text1;
            third = text3;
        }
        else {
            largest = text3;
            second = text2;
            third = text1;
        }
        
        largest.textColor = [UIColor whiteColor];
        largest.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        largest.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.50];
        largest.shadowOffset = CGSizeMake(0, -1);
        
        second.textColor = [UIColor whiteColor];
        second.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        second.shadowColor = largest.shadowColor;
        second.shadowOffset = CGSizeMake(0, -1);
        
        third.textColor = second.textColor;
        third.font = second.font;
        third.shadowColor = second.shadowColor;
        third.shadowOffset = second.shadowOffset;
        
    }   

}

@end
