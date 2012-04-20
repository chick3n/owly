//
//  MTRefreshTableView.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-26.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTRefreshTableView.h"

@implementation MTRefreshTableView
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize isLoading;
@synthesize isDragging;
@synthesize refreshDelegate                = _refreshDelegate;

- (void)setupRefresh:(MTLanguage)language
{
    textPull = NSLocalizedString(@"MTDEF_PULLDOWNTOREFRESH", nil);
    textRelease = NSLocalizedString(@"MTDEF_RELEASETOREFRESH", nil);
    textLoading = NSLocalizedString(@"MTDEF_LOADING", nil);
    
    animationArray = [[NSArray alloc] initWithObjects:
                      [UIImage imageNamed:@"1.png"]
                      , nil];
    loadingArray = [[NSArray alloc] initWithObjects:
                    [UIImage imageNamed:@"2.png"]
                    , [UIImage imageNamed:@"3.png"]
                    , [UIImage imageNamed:@"4.png"]
                    , [UIImage imageNamed:@"5.png"]
                    , [UIImage imageNamed:@"4.png"]
                    , [UIImage imageNamed:@"3.png"]
                    , nil];
    
    incrementalCounter = REFRESH_HEADER_HEIGHT / animationArray.count;
    
    loadingAnimation = [[UIImageView alloc] initWithFrame:kImageRect];
	loadingAnimation.animationImages = loadingArray;
	loadingAnimation.animationDuration = 0.25;
    loadingAnimation.hidden = YES;
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:kViewRect];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, refreshHeaderView.frame.size.height/2 - (32/ 2), 320, 32)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    refreshLabel.textColor = [UIColor colorWithRed:154./255. green:154./255. blue:154./255. alpha:1.0];
    refreshLabel.shadowColor = [UIColor whiteColor];
    refreshLabel.shadowOffset = CGSizeMake(0, 1.0);
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[animationArray objectAtIndex:0]];
    refreshArrow.frame = kImageRect;
        
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:loadingAnimation];
    [self addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) 
    {
        if (scrollView.contentOffset.y > 0)
            self.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } 
    else if (isDragging && scrollView.contentOffset.y < 0) 
    {
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) 
        {
            refreshLabel.text = self.textRelease;
            refreshArrow.image = [animationArray objectAtIndex:0];
        } 
        else
        { 
            refreshLabel.text = self.textPull;
            double offset = scrollView.contentOffset.y;
            if(offset < 0)
                offset *= -1;
            
            int index = ceil(offset/incrementalCounter);
            if(index >= animationArray.count)
                index = animationArray.count - 1;
            
            refreshArrow.image = [animationArray objectAtIndex:index];
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)automaticallyStartLoading:(BOOL)animated
{
    if(animated)
        [self startLoading];
    else [self refresh];
}

- (void)startLoadingWithoutDelegate
{
    self.isLoading = YES;
    
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = NO;
    loadingAnimation.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^(void){
        self.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    }];    
	[loadingAnimation startAnimating];
}

- (void)startLoading {
    self.isLoading = YES;
    
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = NO;
    loadingAnimation.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^(void){
        self.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    }];    
	[loadingAnimation startAnimating];
    
    [self refresh];
}

- (void)stopLoading {
    self.isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.contentInset;
    tableContentInset.top = 0.0;
    self.contentInset = tableContentInset;
    refreshArrow.image = [animationArray objectAtIndex:0];
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    loadingAnimation.hidden = YES;
    [loadingAnimation stopAnimating];
}

- (void)refresh {
    if([_refreshDelegate conformsToProtocol:@protocol(MTRefreshDelegate)])
        [_refreshDelegate refreshTableViewNeedsRefresh];
}

@end
