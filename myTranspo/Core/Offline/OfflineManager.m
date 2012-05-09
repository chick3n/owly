//
//  OfflineManager.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-08.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "OfflineManager.h"

@interface OfflineManager ()
- (void)initialize;
- (NSURLRequest*)generateRequestForUrl:(NSString*)url;
@end

@implementation OfflineManager
@synthesize filePath =      _filePath;
@synthesize delegate =      _delegate;
@synthesize state =         _state;
@synthesize expectedFileSize =      _expectedFileSize;
@synthesize newVersionAvailable =   _newVersionAvailable;
@synthesize inProgress =    _inProgress;

- (id)init
{
    self = [super init];
    if(self)
    {
        _state = OM_INITIALIZED;
        [self initialize];        
    }
    return self;
}

- (void)initialize
{
    _inProgress = NO;
    _filePath = nil;
    _currentVersion = [MTSettings ocOfflineVersion];
    _expectedFileSize = 0.0;
    
}

- (BOOL)hasNewVersion
{
    return NO;
}

- (void)getLatestVersion
{
    _state = OM_VERSION;
    _inProgress = YES;
    
    MTCity city = [MTSettings cityPreference];
    if(city == MTCITYOTTAWA)
    {
        _connection = [[NSURLConnection alloc] initWithRequest:[self generateRequestForUrl:@"http://www.vicestudios.com/apps/owly/oc/oc_offline.php"] 
                                                      delegate:self 
                                              startImmediately:YES];
    }
    else {        
        _inProgress = NO;
        _state = OM_FINISHED;
        if([_delegate conformsToProtocol:@protocol(OfflineManagerDelegate)])
            [_delegate offlineManager:self didFinishWithResult:NO ForState:_state];
    }

}

- (void)downloadLatestVersion
{
    _state = OM_DOWNLOADING;
    _inProgress = YES;
    
    MTCity city = [MTSettings cityPreference];
    if(city == MTCITYOTTAWA)
    {
        _connection = [[NSURLConnection alloc] initWithRequest:[self generateRequestForUrl:@"http://www.vicestudios.com/apps/owly/offline/OCTranspoOffline.zip"] 
                                                      delegate:self 
                                              startImmediately:YES];
    }
    else {        
        _inProgress = NO;
        _state = OM_FINISHED;
        if([_delegate conformsToProtocol:@protocol(OfflineManagerDelegate)])
            [_delegate offlineManager:self didFinishWithResult:NO ForState:_state];
    }
}

- (NSURLRequest*)generateRequestForUrl:(NSString*)url
{
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] 
															 cachePolicy: NSURLRequestReloadIgnoringCacheData 
														 timeoutInterval:MTDEF_CONNECTIONTIMEOUT];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(_state == OM_VERSION)
    {
        _data = [[NSMutableData alloc] init];
    }
    else if(_state == OM_DOWNLOADING)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if(httpResponse != nil)
            _expectedFileSize = [httpResponse expectedContentLength];
        
        _filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OCTranspoOffline.zip"];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:_filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
        }
        
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        _file = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        
        if (_file)   
        {            
            [_file seekToEndOfFile];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(_state == OM_DOWNLOADING)
    {
        if(_file)
        {
            [_file seekToEndOfFile];
            [_file writeData:data];
        }
        
        if([_delegate conformsToProtocol:@protocol(OfflineManagerDelegate)])
            [_delegate offlineManagerTotalReceived:(float)[data length] 
                                           ForSize:_expectedFileSize];
    }
    else
    {
        if(_data)
        {
            [_data appendData:data];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    MTLog(@"OfflineFailed: %@", [error localizedDescription]);
    _inProgress = NO;
    _state = OM_FINISHED;
    
    _data = nil;
    if(_file)
    {
        [_file closeFile];
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    BOOL status = NO;
    
    if(_state == OM_DOWNLOADING)
    {
        if(_file)
        {
            [_file closeFile];
            status = YES;
        }
    }
    else if(_state == OM_VERSION) //save json
    {
        if(_data)
        {
            NSError* error;
            _versionInformation = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:_data 
                                                                                 options:NSJSONReadingMutableContainers 
                                                                                   error:&error];
            if(_versionInformation == nil)
            {
                MTLog(@"OfflineManager: JSON FAILED %@", [error description]);
                status = NO;
            }
            else {
                status = YES;
                NSNumber *version = [_versionInformation objectForKey:@"version"];
                if(version == nil)
                    version = [NSNumber numberWithFloat:0.0];
                
                if(version.floatValue > _currentVersion)
                    _newVersionAvailable = YES;
            }
        }
    }
    
    if([_delegate conformsToProtocol:@protocol(OfflineManagerDelegate)])
        [_delegate offlineManager:self didFinishWithResult:status ForState:_state];
    
    _state = OM_FINISHED;
    _inProgress = NO;
}

@end
