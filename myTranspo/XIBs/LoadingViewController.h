//
//  LoadingViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBaseViewController.h"
#import "AppDelegate.h"
#import "LZMAExtractor.h"


#define WITH_INDEXING 0

typedef enum
{
    BEGINNING_INSTALL = 0
    , EXTRACTING
    , RUNNINGQUERIES
    , FINISHINGUP
}LoadingStatus;

@interface LoadingViewController : MTBaseViewController <MyTranspoDelegate>
{
    IBOutlet UILabel *_notifier;
}

@end
