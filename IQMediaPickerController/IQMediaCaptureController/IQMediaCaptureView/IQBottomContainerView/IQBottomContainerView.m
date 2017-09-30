//
//  IQBottomContainerView.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-17 Iftekhar Qurashi.
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
        topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 30)];
        topContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:topContainerView];
        
        leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topContainerView.frame), 100, 66)];
        CGPoint center = leftContainerView.center;
        center.x = CGRectGetMidX(frame)/3;
        leftContainerView.center = center;
        leftContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:leftContainerView];
        
        middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topContainerView.frame), 66, 66)];
        center = middleContainerView.center;
        center.x = CGRectGetMidX(frame);
        middleContainerView.center = center;
        middleContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:middleContainerView];
        
        rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topContainerView.frame), 100, 66)];
        center = rightContainerView.center;
        center.x = CGRectGetMidX(frame)+CGRectGetMidX(frame)*2/3;
        rightContainerView.center = center;
        rightContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:rightContainerView];
        
        //Constraints
        {
            topContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            leftContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            rightContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            middleContainerView.translatesAutoresizingMaskIntoConstraints = NO;

            NSDictionary *views = @{@"topContainerView":topContainerView,@"leftContainerView":leftContainerView,@"middleContainerView":middleContainerView,@"rightContainerView":rightContainerView};
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[leftContainerView]-[middleContainerView(==66)]-[rightContainerView]-|" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[topContainerView]-|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topContainerView(==30)]-[middleContainerView(==66)]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];

            [self addConstraints:constraints];
        }
    }
    return self;
}

-(void)setLeftContentView:(UIView *)leftContentView
{
    _leftContentView = leftContentView;

    if (leftContentView)
    {
        [leftContainerView addSubview:leftContentView];

        //Constraints
        {
            leftContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":leftContentView};
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [leftContainerView addConstraints:constraints];
        }
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{

        for (UIView *view in leftContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        leftContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {

        NSArray *subviews = leftContainerView.subviews;
        for (UIView *view in subviews)
        {
            if (view.alpha == 0)    [view removeFromSuperview];
        }
    }];
}

-(void)setTopContentView:(UIView *)topContentView
{
    _topContentView = topContentView;
    
    if (topContentView)
    {
        [topContainerView addSubview:topContentView];

        //Constraints
        {
            topContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":topContentView};
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [topContainerView addConstraints:constraints];
        }
    }

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in topContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        topContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray *subviews = topContainerView.subviews;
        for (UIView *view in subviews)
        {
            if (view.alpha == 0)    [view removeFromSuperview];
        }
    }];
}

-(void)setMiddleContentView:(UIView *)middleContentView
{
    _middleContentView = middleContentView;

    if (middleContentView)
    {
        [middleContainerView addSubview:middleContentView];

        //Constraints
        {
            middleContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":middleContentView};
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [middleContainerView addConstraints:constraints];
        }
    }

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in middleContainerView.subviews)
        {
            view.alpha = 0.0;
        }

        middleContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray *subviews = middleContainerView.subviews;
        for (UIView *view in subviews)
        {
            if (view.alpha == 0)    [view removeFromSuperview];
        }
    }];
}

-(void)setRightContentView:(UIView *)rightContentView
{
    _rightContentView = rightContentView;
    
    if (rightContentView)
    {
        [rightContainerView addSubview:rightContentView];

        //Constraints
        {
            rightContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":rightContentView};
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [rightContainerView addConstraints:constraints];
        }
    }

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in rightContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        rightContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray *subviews = rightContainerView.subviews;
        for (UIView *view in subviews)
        {
            if (view.alpha == 0)    [view removeFromSuperview];
        }
    }];
}

@end


