//
//  NoticesDataViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-16.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "NoticesDataViewController.h"

@interface NoticesDataViewController ()
- (void)loadWebViewContent;
- (void)goBack:(id)sender;
@end

@implementation NoticesDataViewController
@synthesize data                = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        MTRightButton* backButton = [[MTRightButton alloc] initWithType:kRightButtonTypeBack];
        [backButton setTitle:NSLocalizedString(@"BACKBUTTON", nil) forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if(_panGesture != nil)
    //    [self.view addGestureRecognizer:_panGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //if(_panGesture != nil)
    //    [self.view removeGestureRecognizer:_panGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //webview
    _webView.delegate = self;
    
    [self loadWebViewContent];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - load View content

- (void)loadWebViewContent
{
    if(_data != nil)
    {
        NSString* content = [_data valueForKey:@"desc"];

        if(content != nil)
        {
            [_webView loadHTMLString:content baseURL:nil];
        }
    }
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    
    _requestedUrl = request;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EXTERNALLINKTITLE", nil)
                                                    message:NSLocalizedString(@"EXTERNALLINKMSG", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"EXTERNALCANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"EXTERNALOK", nil), nil];

    [alert show];
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize webViewContentSize = _webView.scrollView.contentSize;
    CGRect webViewFrame = _webView.frame;
    
    webViewFrame.size.height = webViewContentSize.height;
    
    _webView.frame = webViewFrame;
    
    webViewContentSize.height += _webView.frame.origin.y;
    
    _scrollView.contentSize = webViewContentSize;
    
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && _requestedUrl != nil)
    {
        [[UIApplication sharedApplication] openURL:_requestedUrl.URL];
    }
    
    _requestedUrl = nil;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    _requestedUrl = nil;
}


#pragma mark - Navigation Controller

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
