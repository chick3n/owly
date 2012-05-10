//
//  NSString+URLEncoding.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)
- (NSString*)URLEncodedString
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault
                                                                                    , (__bridge CFStringRef)self
                                                                                    , NULL
                                                                                    , CFSTR("?=&+")
                                                                                    , kCFStringEncodingUTF8);
    return result;
}
@end
