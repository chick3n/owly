//
//  MTUserAnnotation.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-06.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MTUserAnnotation : NSObject <MKAnnotation>

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)coordinate;

@property (nonatomic)       CLLocationCoordinate2D      coordinates;

@end
