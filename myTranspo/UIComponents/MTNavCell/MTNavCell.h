//
//  MTNavCell.h
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-23.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kMTNAVCELLHEIGHT 44
#define kMTNAVCELLSEPERATORCOLOR [UIColor clearColor]
#define kMTNAVCELLNOTIFIERCOORDS CGRectMake(244, 11, 0, 0)
#define kMTNAVCELLNOTIFIERCOLOR [UIColor colorWithRed:144./255. green:205./255 blue:26./255. alpha:1.0]
#define kMTNAVCELLNOTIFIERNORMALCOLOR [UIColor colorWithRed:39./255. green:46./255 blue:49./255. alpha:1.0]

typedef enum
{
    MTNAVICONACCOUNT = 0
    , MTNAVICONFAVORITES
    , MTNAVICONSTOPS
    , MTNAVICONNOTICES
    , MTNAVICONTRIPPLANNER
    , MTNAVICONTRAINS
} MTNavIcon;

typedef enum
{
    MTNAVNOTIFICATIONTYPENONE = 0
    , MTNAVNOTIFICATIONTYPEALERT
    , MTNAVNOTIFICATIONTYPECOUNT
} MTNavNotificationType;

@interface MTNavCell : UITableViewCell
{
    IBOutlet UIImageView*               _navImage;
    IBOutlet UILabel*                   _navTitle;
    IBOutlet UIView*                    _notificationImage;
    IBOutlet UILabel*                   _notificationMessage;
    UIView*                             _selectedView;
}

- (void)updateNotificationMessage:(NSString*)count isImportant:(BOOL)important;
- (void)updateNavCell:(MTNavIcon)icon WithTitle:(NSString*)title;
- (void)updateNotificationAlert;
- (void)initializeUI;

@end
