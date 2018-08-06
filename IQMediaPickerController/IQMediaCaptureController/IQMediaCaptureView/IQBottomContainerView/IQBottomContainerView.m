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

@interface IQBottomContainerView()

@property UIView *topContainerView;
@property UIView *leftContainerView;
@property UIView *middleContainerView;
@property UIView *rightContainerView;

@end

@implementation IQBottomContainerView

-(void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 30)];
        _topContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_topContainerView];
        
        _leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topContainerView.frame), 100, 66)];
        CGPoint center = _leftContainerView.center;
        center.x = CGRectGetMidX(frame)/3;
        _leftContainerView.center = center;
        _leftContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftContainerView];
        
        _middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topContainerView.frame), 66, 66)];
        center = _middleContainerView.center;
        center.x = CGRectGetMidX(frame);
        _middleContainerView.center = center;
        _middleContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_middleContainerView];
        
        _rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topContainerView.frame), 100, 66)];
        center = _rightContainerView.center;
        center.x = CGRectGetMidX(frame)+CGRectGetMidX(frame)*2/3;
        _rightContainerView.center = center;
        _rightContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightContainerView];
        
        //Constraints
        {
            _topContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            _leftContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            _rightContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            _middleContainerView.translatesAutoresizingMaskIntoConstraints = NO;

            NSDictionary *views = @{@"topContainerView":_topContainerView,@"leftContainerView":_leftContainerView,@"middleContainerView":_middleContainerView,@"rightContainerView":_rightContainerView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
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
        [_leftContainerView addSubview:leftContentView];

        //Constraints
        {
            leftContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":leftContentView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [_leftContainerView addConstraints:constraints];
        }
    }
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{

        for (UIView *view in weakSelf.leftContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        leftContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {

        NSArray<UIView*> *subviews = weakSelf.leftContainerView.subviews;
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
        [_topContainerView addSubview:topContentView];

        //Constraints
        {
            topContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":topContentView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [_topContainerView addConstraints:constraints];
        }
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in weakSelf.topContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        topContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray<UIView*> *subviews = weakSelf.topContainerView.subviews;
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
        [_middleContainerView addSubview:middleContentView];

        //Constraints
        {
            middleContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":middleContentView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [_middleContainerView addConstraints:constraints];
        }
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in weakSelf.middleContainerView.subviews)
        {
            view.alpha = 0.0;
        }

        middleContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray<UIView*> *subviews = weakSelf.middleContainerView.subviews;
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
        [_rightContainerView addSubview:rightContentView];

        //Constraints
        {
            rightContentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"contentView":rightContentView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
            
            [_rightContainerView addConstraints:constraints];
        }
    }

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        for (UIView *view in weakSelf.rightContainerView.subviews)
        {
            view.alpha = 0.0;
        }
        
        rightContentView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        NSArray<UIView*> *subviews = weakSelf.rightContainerView.subviews;
        for (UIView *view in subviews)
        {
            if (view.alpha == 0)    [view removeFromSuperview];
        }
    }];
}

@end


