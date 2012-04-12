//
//  MTSettingsTableView.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTSettingsTableView.h"

@implementation MTSettingsTableView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self window] endEditing:YES];
    
    [super touchesEnded:touches withEvent:event];
}

@end
