//
//  IQBottomContainerView.m
//  ImagePickerController
//
//  Created by Iftekhar on 08/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

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


