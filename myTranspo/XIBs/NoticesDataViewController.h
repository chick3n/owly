//
//  NoticesDataViewController.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTBaseViewController.h"
#import "MTRightButton.h"

@interface NoticesDataViewController : MTBaseViewController<UIWebViewDelegate, UIAlertViewDelegate>
{
    NSURLRequest*                   _requestedUrl;
    
    //UI Components
    IBOutlet UIWebView*             _webView;
    IBOutlet UIScrollView*          _scrollView;
    IBOutlet UILabel*               _headerTitle;
    IBOutlet UILabel*               _headerDate;
}

@property (nonatomic, weak)     NSDictionary*       data;

@end
