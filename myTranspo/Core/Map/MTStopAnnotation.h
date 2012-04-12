//
//  MTStopAnnotation.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-28.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MTStop.h"

@interface MTStopAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D 				_coordinates;
}

@property (nonatomic, strong) NSString*			stopCode;
@property (nonatomic, strong) NSString*			stopStreetName;
@property (nonatomic, copy) NSArray*			stopRoutes;
@property (nonatomic, strong) MTStop*           stop;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)coordinate;

@end;
