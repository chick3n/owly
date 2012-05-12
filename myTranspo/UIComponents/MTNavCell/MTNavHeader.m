//
//  MTNavHeader.m
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-23.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTNavHeader.h"

@interface MTNavHeader ()
- (void)initializeUI;
@end

@implementation MTNavHeader

- (id)initWithLanguage:(MTLanguage)language AndTitle:(MTNavHeaderTitle)titleType
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, kMTNAVHEADERHEIGHT)];
    if (self) {
        
        _language = language;
        _titleType = titleType;
        
        switch (titleType) {
            case MTNAVHEADERMENU:
                _title = NSLocalizedString(@"MTDEF_MENUHEADERBUS", nil);
                break;
        }
        
        [self initializeUI];
    }
    return self;
}

- (void)initializeUI
{
    UIImageView* categoryBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_category_bar.jpg"]];
    categoryBar.frame = CGRectMake(0, 0, 320, kMTNAVHEADERHEIGHT);
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, categoryBar.frame.size.width - 24, categoryBar.frame.size.height - 7)];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = _title;
    headerLabel.shadowColor = [UIColor colorWithRed:38./255. green:154./255. blue:201./255. alpha:1.0];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    [categoryBar addSubview:headerLabel];
    
    [self addSubview:categoryBar];
}

@end
