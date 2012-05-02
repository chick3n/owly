//
//  TripDetailsCell.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-29.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "TripDetailsCell.h"

@implementation TripDetailsCell
@synthesize leftAccessoryImage = _leftAccessoryImage;
@synthesize rightAccessoryText = _rightAccessoryText;
@synthesize indent = _indent;
@synthesize text = _text;

- (void)setLeftAccessoryImage:(UIImage *)leftAccessoryImage
{
    _leftAccessory.image = leftAccessoryImage;
}

- (void)setRightAccessoryText:(NSString *)rightAccessoryText
{
    _rightAccessory.text = rightAccessoryText;
}

- (void)setIndent:(BOOL)indent
{
    _indent = indent;
#if 0
    if(indent)
        self.backgroundView.backgroundColor = [UIColor lightGrayColor];
    else self.backgroundView.backgroundColor = [UIColor clearColor];
#endif
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        
        
        CGRect leftFrame = CGRectMake(0, 2, 37, 37);
        //leftFrame.origin.y = (self.frame.size.height / 2) - (leftFrame.size.height / 2);
        _leftAccessory = [[UIImageView alloc] initWithFrame:leftFrame];
        _leftAccessory.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_leftAccessory];
        
        _text = [[UILabel alloc] initWithFrame:CGRectMake(38, 12, 216, 16)];
        _text.backgroundColor = [UIColor clearColor];
        _text.numberOfLines = 0;
        _text.lineBreakMode = UILineBreakModeWordWrap;
        _text.textColor = [UIColor colorWithRed:59./255. green:59./255. blue:59./255. alpha:1.0];
        _text.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        [self.contentView addSubview:_text];
        
        
        _rightAccessory = [[UILabel alloc] initWithFrame:CGRectMake(245, 12, 65, 16)];
        _rightAccessory.backgroundColor = [UIColor clearColor];
        _rightAccessory.textColor = [UIColor colorWithRed:157./255. green:157./255. blue:157./255. alpha:1.0];
        _rightAccessory.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        _rightAccessory.shadowColor = [UIColor whiteColor];
        _rightAccessory.shadowOffset = CGSizeMake(0, 1);
        _rightAccessory.textAlignment = UITextAlignmentRight;
        _rightAccessory.lineBreakMode = UILineBreakModeClip;
        [self.contentView addSubview:_rightAccessory];
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        
        _seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_cell_line.png"]];
        [self.contentView addSubview:_seperator];
        
        self.clipsToBounds = YES;
        self.opaque = NO;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect seperatorFrame = _seperator.frame;
    seperatorFrame.origin.y = self.frame.size.height - 2;
    _seperator.frame = seperatorFrame;
    
#if 0
    CGRect textFrame = _text.frame;
    if(frame.size.height > kMinTripCellHeight)
        textFrame.origin.y = 6;
    else textFrame.origin.y = 12;
    _text.frame = textFrame;
#endif  
    
}

@end
