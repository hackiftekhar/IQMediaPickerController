//
//  IQImagePreviewViewController.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2017 Iftekhar Qurashi.
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


#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIVisualEffectView.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIImage.h>
#import "IQImagePreviewViewController.h"

@interface IQImagePreviewViewController ()<UIScrollViewDelegate>

@property UIVisualEffectView *visualEffectView;
@property UIScrollView *scrollView;
@property UIView *containerView;
@property UIImageView *imageView;
@property UITapGestureRecognizer *tapRecognizer;
@property UITapGestureRecognizer *doubleTapRecognizer;

@property CGFloat beginZoomScale;

@end

@implementation IQImagePreviewViewController

-(void)dealloc
{
    
}

- (id) init {
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void) loadView {
    
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
    self.visualEffectView.frame = [[UIScreen mainScreen] bounds];
    self.visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.view = self.visualEffectView;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.visualEffectView.contentView.bounds];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
        {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
#endif

    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = self.visualEffectView.autoresizingMask;
    [self.visualEffectView.contentView addSubview:self.scrollView];
    
    CGSize containerSize = CGSizeZero;
    if (self.liftedImageView)
    {
        containerSize = self.liftedImageView.image.size;
    }
    else
    {
        containerSize = self.image.size;
    }

    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
    self.containerView.autoresizingMask = self.visualEffectView.autoresizingMask;
    [self.scrollView addSubview:self.containerView];

    CGFloat scale = [self zoomScaleThatFits];
    scale = scale *0.9;
    
    self.scrollView.minimumZoomScale = scale;
    self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale*4;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismiss)];
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
}

-(CGFloat)zoomScaleThatFits
{
    CGSize source = CGSizeZero;

    if (self.liftedImageView)
    {
        source = self.liftedImageView.image.size;
    }
    else
    {
        source = self.image.size;
    }

    CGSize target = self.scrollView.bounds.size;
    
    CGFloat w_scale = (target.width / source.width);
    CGFloat h_scale = (target.height / source.height);
    return ((w_scale < h_scale) ? w_scale : h_scale);
}

#pragma mark - Private Methods

- (void) doubleTap {

    CGPoint center = [self.doubleTapRecognizer locationInView:self.containerView];
    CGFloat scale = self.scrollView.zoomScale < (self.scrollView.maximumZoomScale/2) ? self.scrollView.maximumZoomScale: self.scrollView.minimumZoomScale;

    {
        CGSize boundsSize = self.scrollView.bounds.size;
        CGRect zoomRect;
        
        zoomRect.size.width = boundsSize.width / scale;
        zoomRect.size.height = boundsSize.height / scale;
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0f);
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0f);
        
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void) onDismiss {
    
    [self.tapRecognizer.view removeGestureRecognizer:self.tapRecognizer];
    [self.doubleTapRecognizer.view removeGestureRecognizer:self.doubleTapRecognizer];
    //Begin position
    {
        CGRect startFrame = [self.imageView convertRect:self.imageView.bounds toView:self.visualEffectView.contentView];
        
        [self.visualEffectView.contentView addSubview:self.imageView];
        self.imageView.frame = startFrame;
    }
    
    //End position
    {
        CGRect endFrame = CGRectZero;
        
        if (self.liftedImageView)
        {
            endFrame = [self.liftedImageView convertRect:self.liftedImageView.bounds toView:self.visualEffectView.contentView];
        }
        else
        {
            endFrame = [self.fromView convertRect:self.rect toView:self.visualEffectView.contentView];
        }
        
        [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
            
            self.imageView.frame = endFrame;
            self.visualEffectView.effect = nil;
            
        } completion:^(BOOL finished) {
            self.liftedImageView.hidden = NO;
            
            UIViewController *childController = self;
            [childController willMoveToParentViewController:nil];
            [childController.view removeFromSuperview];
            [childController removeFromParentViewController];
        }];
    }
}

-(void)showOverController:(UIViewController*)parentController
{
    UIViewController *childController = self;
    
    [parentController addChildViewController:childController];
    childController.view.frame = parentController.view.bounds;
    [childController willMoveToParentViewController:parentController];
    [parentController.view addSubview:childController.view];
    [childController didMoveToParentViewController:parentController];
    childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;

    //Begin position
    {
        CGRect startFrame = CGRectZero;
        
        if (self.liftedImageView)
        {
            // imageView configuration
            self.imageView.image = self.liftedImageView.image;
            self.imageView.contentMode = self.liftedImageView.contentMode;
            self.imageView.clipsToBounds = self.liftedImageView.clipsToBounds;
            
            startFrame = [self.liftedImageView convertRect:self.liftedImageView.bounds toView:self.visualEffectView.contentView];
        }
        else
        {
            self.imageView.image = self.image;
            self.imageView.contentMode = UIViewContentModeScaleToFill;
            self.imageView.clipsToBounds = YES;
            
            startFrame = [self.fromView convertRect:self.rect toView:self.visualEffectView.contentView];
        }
        self.imageView.frame = startFrame;
        self.liftedImageView.hidden = YES;
        [self.visualEffectView.contentView addSubview:self.imageView];
    }
    
    //End position
    {
        CGRect endFrame = [self.containerView convertRect:self.containerView.bounds toView:self.scrollView];
        
        [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
            self.visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            self.imageView.frame = endFrame;
        } completion:^(BOOL finished) {
            self.imageView.frame = self.containerView.bounds;
            [self.containerView addSubview:self.imageView];
            [self.scrollView addGestureRecognizer:self.tapRecognizer];
            [self.scrollView addGestureRecognizer:self.doubleTapRecognizer];
        }];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)centerContent
{
    CGFloat offsetX = MAX((self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5, 0.0);
    
    self.containerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                                            self.scrollView.contentSize.height * 0.5 + offsetY);
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
