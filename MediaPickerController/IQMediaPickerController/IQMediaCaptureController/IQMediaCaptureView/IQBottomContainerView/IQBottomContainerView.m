//
//  IQBottomContainerView.m
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

#import "IQBottomContainerView.h"

@implementation IQBottomContainerView
{
    UIView *topContainerView;
    UIView *leftContainerView;
    UIView *middleContainerView;
    UIView *rightContainerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
        topContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        topContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:topContainerView];
        
        leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 70, 70)];
        leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        CGPoint center = leftContainerView.center;
        center.x = CGRectGetMidX(frame)/3;
        leftContainerView.center = center;
        leftContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:leftContainerView];
        
        middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 70, 70)];
        middleContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        center = middleContainerView.center;
        center.x = CGRectGetMidX(frame);
        middleContainerView.center = center;
        middleContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:middleContainerView];
        
        rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 70, 70)];
        rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        center = rightContainerView.center;
        center.x = CGRectGetMidX(frame)+CGRectGetMidX(frame)*2/3;
        rightContainerView.center = center;
        rightContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:rightContainerView];
    }
    return self;
}

-(void)setLeftContentView:(UIView *)leftContentView
{
    _leftContentView = leftContentView;

    leftContentView.frame = leftContainerView.bounds;
    [leftContainerView addSubview:leftContentView];
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{

        for (UIView *view in leftContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        leftContentView.alpha = 1.0;
        
    } completion:NULL];
}

-(void)setTopContentView:(UIView *)topContentView
{
    _topContentView = topContentView;
    
    topContentView.frame = topContainerView.bounds;
    [topContainerView addSubview:topContentView];
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in topContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        topContentView.alpha = 0.5;
        
    } completion:NULL];
}

-(void)setMiddleContentView:(UIView *)middleContentView
{
    _middleContentView = middleContentView;

    middleContentView.frame = middleContainerView.bounds;
    [middleContainerView addSubview:middleContentView];

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in middleContainerView.subviews)
        {
            view.alpha = 0.0;
        }

        middleContentView.alpha = 1.0;
        
    } completion:NULL];
}

-(void)setRightContentView:(UIView *)rightContentView
{
    _rightContentView = rightContentView;
    
    rightContentView.frame = rightContainerView.bounds;
    [rightContainerView addSubview:rightContentView];
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in rightContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        rightContentView.alpha = 1.0;
        
    } completion:NULL];
}

@end


