//
//  MTBusAnnotation.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBusAnnotation.h"

@implementation MTBusAnnotation
@synthesize busNumber				= _busNumber;
@synthesize busHeading				= _busHeading;
@synthesize coordinates             = _coordinates;

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
    return _busNumber;
}

- (NSString *)subtitle 
{
    return _busHeading;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinates;
}

@end

