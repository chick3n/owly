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
    if(indent)
        self.backgroundView.backgroundColor = [UIColor lightGrayColor];
    else self.backgroundView.backgroundColor = [UIColor clearColor];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        
        CGRect textFrame = self.textLabel.frame;
        textFrame.origin.x = 60;
        _text = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 210, 16)];
        _text.backgroundColor = [UIColor clearColor];
        _text.numberOfLines = 0;
        _text.lineBreakMode = UILineBreakModeWordWrap;
        _text.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        [self.contentView addSubview:_text];
        
        CGRect leftFrame = CGRectMake(0, 0, 40, 20);
        //leftFrame.origin.y = (self.frame.size.height / 2) - (leftFrame.size.height / 2);
        _leftAccessory = [[UIImageView alloc] initWithFrame:leftFrame];
        _leftAccessory.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_leftAccessory];
        
        _rightAccessory = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 14)];
        _rightAccessory.backgroundColor = [UIColor clearColor];
        self.accessoryView = _rightAccessory;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        
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
    
    CGRect leftFrame = _leftAccessory.frame;
    leftFrame.size.height = frame.size.height;
    leftFrame.origin.y = 0;
    _leftAccessory.frame = leftFrame;
}

@end
