//
//  IQFeatureOverlay.m
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


#import "IQFeatureOverlay.h"
#import <UIKit/UIPanGestureRecognizer.h>

@interface IQFeatureOverlay ()<UIGestureRecognizerDelegate>

@end

@implementation IQFeatureOverlay
{
    UIPanGestureRecognizer *_panRecognizer;
}

-(void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 1)];
        [self.layer setShadowRadius:1.0];
        [self.layer setShadowOpacity:0.5];
        
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        _panRecognizer.delegate = self;
        [self addGestureRecognizer:_panRecognizer];
    }
    return self;
}

-(void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint center = [recognizer locationInView:self.superview];

    [self setCenter:center];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (self.alpha == 0.0)
        {
            [self animate];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(featureOverlay:didEndWithCenter:)])
    {
        [self.delegate featureOverlay:self didEndWithCenter:self.center];
        [self hideAfterSeconds:1];
    }
}

-(void)animate
{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)hideAfterSeconds:(CGFloat)seconds
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:seconds];
}

-(void)hide
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setAlpha:0.0];
    } completion:NULL];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
