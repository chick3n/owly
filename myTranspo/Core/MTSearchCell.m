//
//  MTSearchCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-05.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "MTSearchCell.h"

#define kOffSetOriginX 10

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
        gradient = [self normalGradient:[UIColor orangeColor] colorEnd:[UIColor redColor]];
        CGPathAddArc(outlinePath, NULL, _size.width/2 + kOffSetOriginX, _size.height/2, ((_size.width > _size.height) ? _size.height : _size.width)/2, 0, 2*3.142, 0);
        CGPathCloseSubpath(outlinePath);
    }
    else
    {
        if(_type == CELLSTOP)
            gradient = [self normalGradient:[UIColor cyanColor] colorEnd:[UIColor blueColor]];
        else gradient = [self normalGradient:[UIColor magentaColor] colorEnd:[UIColor purpleColor]];
        
        float radius = 5.0;
        CGRect rrect = CGRectMake(kOffSetOriginX, 0, _size.width, _size.height); 
        CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect); 
        CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect); 
        
        CGPathMoveToPoint(outlinePath, nil, minx, midy); 
        CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius); 
        CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius); 
        CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius); 
        CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);
    }
    
    CGContextSetShadow(ctx, CGSizeMake(0,1), 2); 
    CGContextAddPath(ctx, outlinePath); 
    CGContextFillPath(ctx); 
    
    CGContextAddPath(ctx, outlinePath); 
    CGContextClip(ctx);
    
    CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    
    CGPathRelease(outlinePath);
    
    if(gradient != NULL)
        CGGradientRelease(gradient);
    
    if(_type == CELLBUS)
    {
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(ctx, 8.0);
        CGContextStrokeEllipseInRect(ctx, CGRectMake(kOffSetOriginX, 0, _size.width, _size.height));
    }
    
}

@end

@interface MTSearchCell ()
- (void)initializeUI;
- (void)drawBus;
- (void)drawStop;
- (void)drawStreet;
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

#define kDefaultLabelFrame CGRectMake(kOffSetOriginX, 0, 48, 47)
- (void)initializeUI
{
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    
    _titleBackground = [[MTSearchCellShape alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _titleBackground.backgroundColor = [UIColor grayColor];
    [self addSubview:_titleBackground];
    
    _titleLabel = [[UILabel alloc] initWithFrame:kDefaultLabelFrame];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLabel];
    
}

- (void)update
{
    //redraw based on type
    _titleBackground.type = _type;
    
    if(_type == CELLBUS)
        [self drawBus];
    else if(_type == CELLSTOP)
        [self drawStop];
    else [self drawStop];    
    
    [_titleBackground setNeedsDisplay];
}

- (void)drawBus
{
    _titleLabel.text = _title;
    _titleLabel.frame = kDefaultLabelFrame;
    _titleBackground.size = CGSizeMake(48, 48);
}

- (void)drawStop
{
    _titleLabel.text = _title;
    int titleWidth = [_title sizeWithFont:_titleLabel.font].width;
    
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = titleWidth + 20;
    _titleLabel.frame = titleFrame;
    
    _titleBackground.size = CGSizeMake(titleWidth + 20, 48);
}

- (void)drawStreet
{
    _titleLabel.text = _title;
    int titleWidth = [_title sizeWithFont:_titleLabel.font].width;
    _titleBackground.size = CGSizeMake(titleWidth + 20, 48);
}

@end
