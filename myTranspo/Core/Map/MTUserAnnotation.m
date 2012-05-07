//
//  MTUserAnnotation.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTUserAnnotation.h"

@implementation MTUserAnnotation
@synthesize coordinates;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if(self)
    {
        self.coordinates = coordinate;
    }
    return self;
}

- (NSString *)title
{
    return @":)";
}

- (NSString *)subtitle
{
    return @"";
}

- (CLLocationCoordinate2D)coordinate
{
    return self.coordinates;
}

@end
