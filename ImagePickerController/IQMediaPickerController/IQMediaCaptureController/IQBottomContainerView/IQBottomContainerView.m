//
//  IQBottomContainerView.m
//  ImagePickerController
//
//  Created by Canopus 4 on 08/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQBottomContainerView.h"

@implementation IQBottomContainerView
{
    IBOutlet UIView *topContainerView;
    IBOutlet UIView *leftContainerView;
    IBOutlet UIView *middleContainerView;
    IBOutlet UIView *rightContainerView;
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


