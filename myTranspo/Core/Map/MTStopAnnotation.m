//
//  MTStopAnnotation.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTStopAnnotation.h"

@implementation MTStopAnnotation
@synthesize stopCode					= _stopCode;
@synthesize stopStreetName				= _stopStreetName;
@synthesize stopRoutes					= _stopRoutes;
@synthesize stop                        = _stop;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
{
    self = [super init];
	if(self)
	{
		_coordinates = coordinate;
	}
    return self;
}

- (NSString *)title 
{
    return [NSString stringWithFormat:@"%@ %@", _stopCode, _stopStreetName];
}

- (NSString *)subtitle 
{
    NSMutableString *routes = [[NSMutableString alloc] init];
    
    for(MTBus* bus in _stopRoutes)
    {
        [routes appendFormat:@"%@   ", bus.BusNumber];
    }
    
    if(routes.length >= 3) //strip off last comma
    {
        NSRange lastComma = NSMakeRange(routes.length-2, 2);
        [routes replaceCharactersInRange:lastComma withString:@""];
    }
    
    return routes;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinates;
}

@end
