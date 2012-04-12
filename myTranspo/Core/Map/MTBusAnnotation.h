//
//  MTBusAnnotation.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MTBusAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D 				_coordinates;
}

@property (nonatomic, strong) NSString*			busNumber;
@property (nonatomic, strong) NSString*			busHeading;
@property (nonatomic)         CLLocationCoordinate2D coordinates;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)coordinate;

@end;
