//
//  SettingsMultiType.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-01.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsMultiType.h"

@implementation SettingsMultiType
@synthesize options             = _options;

- (id)init
{
    self = [super init];
    if(self)
    {
        _options = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addOption:(NSString*)title WithValue:(int)value
{
    [_options setValue:[NSNumber numberWithInt:value] forKey:title];
}

@end
