//
//  IQPartitionView.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [self setMinimumFontSize:1.0];
#pragma GCC diagnostic pop
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
