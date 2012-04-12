//
//  MTQueueSafe.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-24.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MTQueueSafe 
@required
- (void)cancelQueues;
@end
