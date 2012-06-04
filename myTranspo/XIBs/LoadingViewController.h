//
//  LoadingViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-20.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#define WITH_INDEXING 0
#define USE7ZIP 0
#define USESSARCHIVE 1
#define USEOBJECTIVEZIP 0

#import <UIKit/UIKit.h>
#import "MTBaseViewController.h"
#import "AppDelegate.h"
#import "LZMAExtractor.h"

#if USESSARCHIVE
#import "SSZipArchive.h"
#endif

#if USEOBJECTIVEZIP
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#endif

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
