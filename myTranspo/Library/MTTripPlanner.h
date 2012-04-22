//
//  MTTripPlanner.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTypes.h"
#import "MTBase.h"

@interface MTTripPlanner : MTBase

@property (nonatomic, strong)   NSString*       startingLocation;
@property (nonatomic, strong)   NSString*       endingLocation;
@property (nonatomic, strong)   NSString*       city;
@property (nonatomic, strong)   NSDate*         arriveBy;
@property (nonatomic)           MTLanguage      language;
@property (nonatomic)           BOOL            departBy;               //toggle to show result as depart by arriveby date or if no arriveAt the arriveby date

//OCTranspo specific
@property (nonatomic)           BOOL            accessible;
@property (nonatomic)           BOOL            regulareFare;
@property (nonatomic)           BOOL            excludeSTO;
@property (nonatomic)           BOOL            bikeRack;

@end
