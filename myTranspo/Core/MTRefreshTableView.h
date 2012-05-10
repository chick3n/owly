//
//  MTRefreshTableView.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-03-26.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MTDefinitions.h"
#import "MTTypes.h"

#define kViewRect CGRectMake(0, -70, 320, 70)
#define kImageRect CGRectMake(12, 0, 70, 70)
#define REFRESH_HEADER_HEIGHT kViewRect.size.height

@protocol MTRefreshDelegate <NSObject>
@required
- (void)refreshTableViewNeedsRefresh;
@end

@interface MTRefreshTableView : UITableView
{
    UIView          *refreshHeaderView;
    UILabel         *refreshLabel;
    UILabel         *emptyTable;
    UIImageView     *refreshArrow;
    UIImageView     *loadingAnimation;
    BOOL            isDragging;
    BOOL            isLoading;
    NSString        *textPull;
    NSString        *textRelease;
    NSString        *textLoading;
    NSArray         *animationArray;
    NSArray         *loadingArray;
    int             incrementalCounter;
    NSTimer         *longLoadingTimer;
    
    UIActivityIndicatorView *refreshSpinner;
}

@property (nonatomic, strong)   UIView                  *refreshHeaderView;
@property (nonatomic, strong)   UILabel                 *refreshLabel;
@property (nonatomic, strong)   NSString                *refreshExtendedDurationText;
@property (nonatomic, strong)   UIImageView             *refreshArrow;
@property (nonatomic, strong)   UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, strong)   NSString                *textPull;
@property (nonatomic, strong)   NSString                *textRelease;
@property (nonatomic, strong)   NSString                *textLoading;
@property (nonatomic)           BOOL                    isLoading;
@property (nonatomic)           BOOL                    isDragging;
@property (nonatomic, weak)     id<MTRefreshDelegate>   refreshDelegate;

- (void)setupRefresh:(MTLanguage)language;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;
- (void)automaticallyStartLoading:(BOOL)animated;
- (void)startLoadingWithoutDelegate;
- (void)setEmptyTableText:(NSString*)emptyText;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
