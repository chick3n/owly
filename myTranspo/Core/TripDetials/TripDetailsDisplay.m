//
//  TripDetailsDisplay.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "TripDetailsDisplay.h"

@implementation TripDetailsDisplay
@synthesize icon            = _icon;
@synthesize title           = _title;
@synthesize details         = _details;
@synthesize duration        = _duration;
@synthesize detailsSize;
@synthesize indent          = _indent;
@synthesize displaySize     = _displaySize;

- (id)init
{
    self = [super init];
    if(self)
    {
        _icon = nil;
        _detailsSize = CGSizeZero;
        _details = @"";
        _duration = @"";
        _indent = NO;
        _displaySize = CGSizeZero;
    }
    return self;
}

- (CGSize)detailsSize
{
    if(!CGSizeEqualToSize(CGSizeZero, _detailsSize))
        return _detailsSize;
    
    //NSString *joined = [NSString stringWithFormat:@"%@%@: %@", ((_indent) ? @"-" : @""), _title, _details];
    NSString* joined = _details;
    _detailsSize = [joined sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]
                                constrainedToSize:_displaySize
                            lineBreakMode:UILineBreakModeWordWrap];
    
    return _detailsSize;
}

@end
