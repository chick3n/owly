//
//  TripDetailsDisplay.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kActionAt @"AT"
#define kActionWait @"WAIT"
#define kActionTransfer @"TRANSFER"
#define kActionWalk @"WALK"
#define kActionNote @"NOTE"
#define kActionArrive @"ARRIVE"
#define kActionUnknown @"UNKNOWN"

#define kTripDetialsDisplaySize CGSizeMake(216, 2000)

@interface TripDetailsDisplay : NSObject
{
    CGSize                  _detailsSize;
}

@property (nonatomic, strong)   NSString*       title;
@property (nonatomic, strong)   NSString*       details;
@property (nonatomic, strong)   UIImage*        icon;
@property (nonatomic, strong)   NSString*       duration;
@property (readonly)            CGSize          detailsSize;
@property (nonatomic)           BOOL            indent;
@property (nonatomic)           CGSize          displaySize;

@end
