//
//  OfflineManager.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-08.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSettings.h"
#import "MTTypes.h"
#import "MTDefinitions.h"

typedef enum
{
    OM_INITIALIZED = 0
    , OM_VERSION
    , OM_DOWNLOADING
    , OM_FINISHED
}OfflineState;

@protocol OfflineManagerDelegate <NSObject>
@required
- (void)offlineManager:(id)offlineMgr didFinishWithResult:(BOOL)result ForState:(OfflineState)state;
- (void)offlineManagerTotalReceived:(CGFloat)received ForSize:(CGFloat)size;

@end

@interface OfflineManager : NSObject <NSURLConnectionDataDelegate>
{
    CGFloat             _currentVersion;
    NSFileHandle*       _file;
    NSURLConnection*    _connection;
    NSDictionary*       _versionInformation;
    OfflineState        _state;
    BOOL                _inProgress;
    NSMutableData*      _data;
    CGFloat             _expectedFileSize;
}

@property (nonatomic, strong)   NSString*   filePath;
@property (nonatomic, weak)     id<OfflineManagerDelegate>  delegate;
@property (nonatomic)           OfflineState    state;
@property (nonatomic)           BOOL    newVersionAvailable;
@property (nonatomic)           CGFloat expectedFileSize;
@property (nonatomic)           BOOL    inProgress;

- (void)getLatestVersion;
- (void)downloadLatestVersion;

@end
