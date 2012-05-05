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

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if(_title != nil)
    {
        if([_title isEqualToString:kActionAt])
            _icon = [UIImage imageNamed:@"tripplanner_bus_icon.png"];
        else if([_title isEqualToString:kActionArrive])
            _icon = [UIImage imageNamed:@"tripplanner_destination_icon.png"];
        else if([_title isEqualToString:kActionTransfer])
            _icon = [UIImage imageNamed:@"tripplanner_route_icon.png"];
        else if([_title isEqualToString:kActionWait])
            _icon = [UIImage imageNamed:@"tripplanner_time_icon.png"];
        else if([_title isEqualToString:kActionWalk])
            _icon = [UIImage imageNamed:@"tripplanner_walking_icon.png"];
        else if([_title isEqualToString:kActionNote])
            _icon = [UIImage imageNamed:@"tripplanner_attention_icon.png"];
        else _icon = nil;
    }
    else _icon = nil;
    
    if(_indent == YES && ![_title isEqualToString:kActionNote])
        _icon = nil;
}

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
        _displaySize = kTripDetialsDisplaySize;
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
