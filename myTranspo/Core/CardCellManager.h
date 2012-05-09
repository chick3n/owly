//
//  CardCellManager.h
//  myTranspo
//
//  Created by Lion User on 09/05/2012.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTStop.h"

typedef enum
{
    CCM_EMPTY = 0
    , CCM_FULL
} CellManagerState;

typedef enum
{
    CMS_IDLE = 0
    , CMS_UPDATING
} CellManagerStatus;

@interface CardCellManager : NSObject

@property (nonatomic)           CellManagerState                state;
@property (nonatomic)           CellManagerStatus               status;
@property (nonatomic)           BOOL                            isAnimating;
@property (nonatomic)           BOOL                            hasAnimated;
@property (nonatomic, strong)   MTStop                          *stop;

//ui values
@property (nonatomic, strong)   NSString                        *busHeadingDisplay;
@property (nonatomic, strong)   NSString                        *busNumber;
@property (nonatomic, strong)   NSString                        *stopStreetName;
@property (nonatomic, strong)   NSString                        *prevTime;
@property (nonatomic, strong)   NSString                        *distance;
@property (nonatomic, strong)   NSString                        *heading;
@property (nonatomic, strong)   MTTime                          *nextTime;
@property (nonatomic, strong)   NSArray                         *additionalNextTimes;
@property (nonatomic, strong)   NSString                        *busSpeed;

- (void)updateDisplayObjects;

@end
