//
//  MTSearchCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

//stop gradient: BLUE: bottom: 68 194 244, top: 114 210 248, inner drop shadow: color: 0 100 140, 18% alpha position 1, 0
//color: black, 15% alpha, 0, 1
//cell background trip cell
//search bar background image.

#import "MTSearchCell.h"

@interface MTSearchCellShape ()
- (CGGradientRef)normalGradient:(UIColor*)colorStart colorEnd:(UIColor*)colorEnd;
@end

@implementation MTSearchCellShape
@synthesize size    = _size;
@synthesize type    = _type;

- (CGGradientRef)normalGradient:(UIColor*)colorStart colorEnd:(UIColor*)colorEnd
{
    
    NSMutableArray *normalGradientLocations = [NSMutableArray arrayWithObjects:
                                               [NSNumber numberWithFloat:0.0f],
                                               [NSNumber numberWithFloat:1.0f],
                                               nil];
    
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    [colors addObject:(id)[colorStart CGColor]];
    [colors addObject:(id)[colorEnd CGColor]];

    NSMutableArray  *normalGradientColors = colors;
    
    int locCount = [normalGradientLocations count];
    CGFloat locations[locCount];
    for (int i = 0; i < [normalGradientLocations count]; i++)
    {
        NSNumber *location = [normalGradientLocations objectAtIndex:i];
        locations[i] = [location floatValue];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)normalGradientColors, locations);
    CGColorSpaceRelease(space);
    
    return normalGradient;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef outlinePath = CGPathCreateMutable(); 
    CGGradientRef gradient = NULL;
    
    if(_type == CELLBUS)
    {
        //new
        CGSize circleSize = CGSizeMake(_size.width, _size.height);
        CGLayerRef circleLayer = CGLayerCreateWithContext(ctx, circleSize, NULL);
        CGContextRef circleRef = CGLayerGetContext(circleLayer);
        
        CGContextSaveGState(ctx); 
        
        CGContextSetStrokeColorWithColor(circleRef, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(circleRef, 4.0);
        CGContextStrokeEllipseInRect(circleRef, CGRectMake(kOffSetOriginX, 0, circleSize.width-4, circleSize.height-4));
        CGContextDrawLayerAtPoint(ctx, CGPointMake(2, 2), circleLayer);
        
        CGLayerRelease(circleLayer);
        
        CGContextRestoreGState(ctx);
        //endnew
        
        gradient = [self normalGradient:[UIColor colorWithRed:68./255. green:194./255. blue:244./255. alpha:1.0] 
                               colorEnd:[UIColor colorWithRed:0 green:100./255. blue:140./255. alpha:1.0]];
        CGPathAddArc(outlinePath
                     , NULL
                     , _size.width/2 + kOffSetOriginX   //x coord of center
                     , _size.height/2                   //y coord of center
                     , ((_size.width > _size.height) ? _size.height : _size.width)/2 - 4        //radius
                     , 0                                //start of angle
                     , 2*3.142                          //end of angle point
                     , 0);
        
        CGPathCloseSubpath(outlinePath);
    }
    else
    {
        if(_type == CELLSTOP)
            gradient = [self normalGradient:[UIColor cyanColor] colorEnd:[UIColor blueColor]];
        else gradient = [self normalGradient:[UIColor magentaColor] colorEnd:[UIColor purpleColor]];
        
        float radius = 5.0;
        CGRect rrect = CGRectMake(kOffSetOriginX - 4, 0, _size.width, _size.height); 
        CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect); 
        CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect); 
        
        CGPathMoveToPoint(outlinePath, nil, minx, midy); 
        CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius); 
        CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius); 
        CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius); 
        CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);
    }
    
    //CGContextSetShadow(ctx, CGSizeMake(0,1), 4); 
    //CGContextAddPath(ctx, outlinePath); 
    //CGContextFillPath(ctx); 
    
    CGContextAddPath(ctx, outlinePath); 
    CGContextClip(ctx);
    
    CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    
    CGPathRelease(outlinePath);
    
    if(gradient != NULL)
        CGGradientRelease(gradient);
    
#if 0
    if(_type == CELLBUS)
    {        
        CGLayerRef circleLayer = CGLayerCreateWithContext(ctx, _size, NULL);
        CGContextRef circleRef = CGLayerGetContext(circleLayer);
        
        CGContextSetStrokeColorWithColor(circleRef, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(circleRef, 8.0);
        CGContextStrokeEllipseInRect(circleRef, CGRectMake(kOffSetOriginX, 0, _size.width, _size.height));
        CGContextDrawLayerAtPoint(ctx, CGPointZero, circleLayer);
        
        CGLayerRelease(circleLayer);
    }
#endif
    
}

@end

@interface MTSearchCell ()
- (void)initializeUI;
- (void)drawBus;
- (void)drawStop;
- (void)drawStreet;
- (void)drawNotice;
@end

@implementation MTSearchCell
@synthesize title               = _title;
@synthesize subtitle            = _subtitle;
@synthesize type                = _type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kDefaultLabelFrame CGRectMake(kOffSetOriginX, kOffSetOriginY, kMTSEARCHCELLSHAPEWIDTH, 16)
#define kSubtitleLabelFrame CGRectMake(kOffSetSubtitleOriginX, kOffSetOriginY, 320 - kOffSetSubtitleOriginX, 16)

- (void)initializeUI
{
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    
#if 0
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trip_cell_bg.png"]];
    [self addSubview:_backgroundImage];
#endif
    
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_cell_line.png"]];
    CGRect frame = _backgroundImage.frame;
    frame.origin.y = self.frame.size.height - 2;
    _backgroundImage.frame = frame;
    [_backgroundImage setFrame:frame];
    [self.contentView addSubview:_backgroundImage];
    
#if 0
    _titleBackground = [[MTSearchCellShape alloc] initWithFrame:CGRectMake(kOffSetBusDrawOriginX, kOffSetBusDrawOriginY, kOffSetSubtitleOriginX - 10, kMTSEARCHCELLHEIGHT)];
    _titleBackground.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleBackground];
#endif
    
    _cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(kOffSetBusDrawOriginX, kOffSetBusDrawOriginY, 20, 20)];
    _cellImage.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:_cellImage];
    
    _titleLabel = [[UILabel alloc] initWithFrame:kDefaultLabelFrame];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.10];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:kSubtitleLabelFrame];
    _subtitleLabel.textColor = [UIColor colorWithRed:59./255. green:59./255. blue:59./255. alpha:1.0];
    _subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    _subtitleLabel.textAlignment = UITextAlignmentLeft;
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_subtitleLabel];
}

- (void)update
{
    //redraw based on type
    _titleBackground.type = _type;
    
    if(_type == CELLBUS)
        [self drawBus];
    else if(_type == CELLSTOP)
        [self drawStop];
    else if(_type == CELLSTREET)
        [self drawStreet];
    else if(_type == CELLNOTICE)
        [self drawNotice];
    
    //[_titleBackground setNeedsDisplay];
}

- (void)drawBus
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    _subtitleLabel.text = _subtitle;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_busnumber_bg.png"];
    
#if 0    
    _titleBackground.size = CGSizeMake(kMTSEARCHCELLSHAPEHEIGHT, kMTSEARCHCELLSHAPEHEIGHT);
#endif
}

- (void)drawStop
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_busstop_icon.png"];
    
#if 0
    int titleWidth = [_title sizeWithFont:_titleLabel.font].width;
    
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = titleWidth + 20;
    _titleLabel.frame = titleFrame;
#endif
    _subtitleLabel.text = _subtitle;
#if 0   
    _titleBackground.size = CGSizeMake(kMTSEARCHCELLSHAPEWIDTH, kMTSEARCHCELLSHAPEHEIGHT);
#endif
}

- (void)drawStreet
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    
    CGRect imageFrame = _cellImage.frame;
    imageFrame.size.width = kMTSEARCHCELLSHAPEHEIGHT;
    imageFrame.size.height = kMTSEARCHCELLSHAPEHEIGHT;
    _cellImage.frame = imageFrame;
    _cellImage.image = [UIImage imageNamed:@"search_street_icon.png"];
    
#if 0
    int titleWidth = [_title sizeWithFont:_titleLabel.font].width;
    
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = titleWidth + 20;
    _titleLabel.frame = titleFrame;
#endif
    _subtitleLabel.text = _subtitle;
#if 0   
    _titleBackground.size = CGSizeMake(kMTSEARCHCELLSHAPEWIDTH, kMTSEARCHCELLSHAPEHEIGHT);
#endif
}

- (void)drawNotice
{
    //48 12 206 16 21
    //262 12 48 21

    _titleLabel.frame = CGRectMake(10, 12, self.frame.size.width - 40, 21);
    //_subtitleLabel.frame = CGRectMake(self.frame.size.width - 80 - 10, 12, 80, 21);
    
    _titleLabel.textColor =[UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
    _titleLabel.textAlignment = UITextAlignmentLeft;
    _titleLabel.shadowColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
#if 0
    
    _subtitleLabel.textColor = [UIColor colorWithRed:140./255. green:140./255. blue:140./255. alpha:1.0];
    _subtitleLabel.textAlignment = UITextAlignmentRight;
    _subtitleLabel.shadowColor = [UIColor whiteColor];
    _subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    _subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];

    NSDateFormatter* f = [MTHelper MTDateFormatterDashesYYYYMMDD];
    [f setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDateFormatter* f2 = [[NSDateFormatter alloc] init];
    f2.timeZone = [NSTimeZone localTimeZone];
    f2.dateStyle = NSDateFormatterShortStyle;
#endif
    _titleLabel.text = _title;
   // _subtitleLabel.text = [f2 stringFromDate:[f dateFromString:_subtitle]];
}

@end
