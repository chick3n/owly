//
//  MTStopHelper.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-13.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTStopHelper : NSObject

@property (nonatomic)       BOOL        hideRoute;
@property (nonatomic, strong) NSString  *routeNumber;
@property (nonatomic, strong) NSString  *routeHeading;

@end
