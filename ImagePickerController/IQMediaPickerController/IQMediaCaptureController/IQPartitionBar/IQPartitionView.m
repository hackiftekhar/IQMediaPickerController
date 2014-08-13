//
//  IQPartitionView.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQPartitionView.h"

@implementation IQPartitionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setSelected:NO];
        [self setUserInteractionEnabled:YES];

        [self setAdjustsFontSizeToFitWidth:YES];
        
        if ([self respondsToSelector:@selector(setMinimumScaleFactor:)])
        {
            [self setMinimumScaleFactor:0.1];
        }
        else if ([self respondsToSelector:@selector(setMinimumFontSize:)])
        {
            [self setMinimumFontSize:1.0];
        }

        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:_tapRecognizer];
        [self setTextAlignment:NSTextAlignmentCenter];
    }

    return self;
}

-(void)tapAction:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self setSelected:!_selected];
        
        if ([_delegate respondsToSelector:@selector(partitionView:didSelect:)])
        {
            [_delegate partitionView:self didSelect:_selected];
        }
    }
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;

    if (selected)
    {
        [self setTextColor:[UIColor orangeColor]];
        self.backgroundColor = [UIColor colorWithWhite:0.459 alpha:1.000];
    }
    else
    {
        [self setTextColor:[UIColor whiteColor]];
        self.backgroundColor = [UIColor colorWithRed:0.292 green:0.601 blue:0.877 alpha:1.000];
    }
}

@end
