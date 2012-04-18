//
//  MTNavItem.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-25.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTIncludes.h"
#import "MTNavCell.h"
#import "MTNavFooter.h"
#import "MTNavHeader.h"
#import "ViewControllers.h"


@interface MTNavItem : NSObject

@property (nonatomic, strong)   NSString*               title;
@property (nonatomic, strong)   NSString*               notificationMessage;
@property (nonatomic)           MTNavIcon               icon;
@property (nonatomic)           MTNavNotificationType   type;
@property (nonatomic)           BOOL                    hasAlert; //show an alert
@property (nonatomic)           BOOL                    hasImportantAlert; //show a bolder alert
@property (nonatomic)           MTLanguage              language;
@property (nonatomic)           MTViewControllers       viewController;

- (id)initWithTitle:(NSString*)title WithIcon:(MTNavIcon)icon WithLanguage:(MTLanguage)language;
- (id)initWithDictionary:(NSDictionary *)dic WithLanguage:(MTLanguage)language;

@end
