//
//  SettingsMultiType.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-01.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsMultiType : NSObject

@property (nonatomic, strong)       NSMutableDictionary*        options;

- (void)addOption:(NSString*)title WithValue:(int)value;

@end
