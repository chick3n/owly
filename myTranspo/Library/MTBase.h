//
//  MTBase.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-24.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTBase : NSObject

@property (nonatomic)       BOOL        cancelQueue;
@property (nonatomic)       BOOL        isUpdating;
@property (nonatomic)       BOOL        isFavorite;

@end
