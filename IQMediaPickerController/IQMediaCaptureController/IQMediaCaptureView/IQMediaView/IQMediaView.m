//
//  IQMediaView.m
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


#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

#import "IQMediaView.h"
#import "IQFeatureOverlay.h"
#import "SCSiriWaveformView.h"

@interface IQMediaView ()<IQFeatureOverlayDelegate,UIGestureRecognizerDelegate>

@property SCSiriWaveformView *levelMeter;
@property UIVisualEffectView *blurView;
@property UIView *overlayView;

@property (nonatomic) BOOL blur;

@end

@implementation IQMediaView
{
//    IQFeatureOverlay *focusView;
//    IQFeatureOverlay *exposureView;
    
    
    NSTimer *updateTimer;
    
    
//    UIPanGestureRecognizer *_panRecognizer;
//    UITapGestureRecognizer *_tapRecognizer;
//    UILongPressGestureRecognizer *_longPressRecognizer;
    UISwipeGestureRecognizer *_swipeRightRecognizer;
    UISwipeGestureRecognizer *_swipeLeftRecognizer;
}

-(void)dealloc
{
    
}

-(void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    self.previewLayer.frame = self.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.previewLayer];
    
//    focusView = [[IQFeatureOverlay alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    focusView.alpha = 0.0;
//    focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
//    focusView.center = self.center;
//    focusView.delegate = self;
//    focusView.image = [UIImage imageInsideMediaPickerBundleNamed:@"IQ_focus"];
//    [self addSubview:focusView];
//    
//    exposureView = [[IQFeatureOverlay alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    exposureView.alpha = 0.0;
//    exposureView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
//    exposureView.center = self.center;
//    exposureView.delegate = self;
//    exposureView.image = [UIImage imageInsideMediaPickerBundleNamed:@"IQ_exposure"];
//    [self addSubview:exposureView];
    
    
    _swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
    _swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:_swipeRightRecognizer];
    
    _swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
    _swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:_swipeLeftRecognizer];
    
//    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
//    _longPressRecognizer.delegate = self;
//    [self addGestureRecognizer:_longPressRecognizer];
//
//    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
//    [_panRecognizer requireGestureRecognizerToFail:_longPressRecognizer];
//    [_panRecognizer requireGestureRecognizerToFail:_swipeRightRecognizer];
//    [_panRecognizer requireGestureRecognizerToFail:_swipeLeftRecognizer];
//    _panRecognizer.delegate = self;
//    [self addGestureRecognizer:_panRecognizer];
//    
//    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
//    [_tapRecognizer requireGestureRecognizerToFail:_panRecognizer];
//    [_tapRecognizer requireGestureRecognizerToFail:_longPressRecognizer];
//    [_tapRecognizer requireGestureRecognizerToFail:_swipeRightRecognizer];
//    [_tapRecognizer requireGestureRecognizerToFail:_swipeLeftRecognizer];
//    _tapRecognizer.delegate = self;
//    [self addGestureRecognizer:_tapRecognizer];
    
    _overlayView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, -CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds))];
    _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _overlayView.userInteractionEnabled = NO;
    _overlayView.backgroundColor = [UIColor clearColor];
    [self addSubview:_overlayView];
    
    //Audio Meter View
    {
        self.levelMeter = [[SCSiriWaveformView alloc] initWithFrame:CGRectInset(self.bounds, 0, self.bounds.size.height/4)];
        self.levelMeter.backgroundColor = [UIColor clearColor];
        [self.levelMeter setWaveColor:[UIColor colorWithRed:192.0/255.0 green:1 blue:1 alpha:1]];
        [self.levelMeter setPrimaryWaveLineWidth:3.0f];
        [self.levelMeter setSecondaryWaveLineWidth:1.0];
        self.levelMeter.phaseShift = -0.5;
        self.levelMeter.alpha = 0.0;
        self.levelMeter.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.levelMeter.center = CGPointMake(CGRectGetMidX(_overlayView.bounds), CGRectGetMidY(_overlayView.bounds));
        [_overlayView addSubview:self.levelMeter];
    }
    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _blurView.hidden = YES;
    _blurView.frame = self.bounds;
    [self addSubview:_blurView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

//-(void)tapGestureRecognizer:(UIPanGestureRecognizer*)recognizer
//{
//    CGPoint center = [recognizer locationInView:self];
//    
//    [exposureView setCenter:center];
//    
//    if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
//    {
//        [self.delegate mediaView:self exposurePointOfInterest:exposureView.center];
//        [exposureView hideAfterSeconds:1];
//
//        if (exposureView.alpha == 0.0)
//        {
//            [exposureView animate];
//        }
//    }
//}

//-(void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
//{
//    CGPoint center = [recognizer locationInView:self];
//    
//    [exposureView setCenter:center];
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//        if (exposureView.alpha == 0.0)
//        {
//            [exposureView animate];
//        }
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
//    {
//        [self.delegate mediaView:self exposurePointOfInterest:exposureView.center];
//        [exposureView hideAfterSeconds:1];
//    }
//}

//-(void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)recognizer
//{
//    CGPoint center = [recognizer locationInView:self];
//    
//    [focusView setCenter:center];
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//        if (focusView.alpha == 0.0)
//        {
//            [focusView animate];
//        }
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
//    {
//        [self.delegate mediaView:self focusPointOfInterest:focusView.center];
//        [focusView hideAfterSeconds:1];
//    }
//}

-(void)swipeGestureRecognizer:(UISwipeGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(mediaView:swipeDirection:)])
        {
            [self.delegate mediaView:self swipeDirection:(gesture == _swipeLeftRecognizer?UISwipeGestureRecognizerDirectionLeft : UISwipeGestureRecognizerDirectionRight)];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

-(void)setPreviewInset:(UIEdgeInsets)previewInset
{
    _previewInset = previewInset;
    
    CGRect previewRect = UIEdgeInsetsInsetRect(self.bounds, previewInset);

    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    self.previewLayer.frame = previewRect;
    [CATransaction commit];
}

-(void)setCaptureMode:(PHAssetMediaType)captureMode
{
    _captureMode = captureMode;
    
    [self updateGesturesState];
}

-(void)setRecording:(BOOL)recording
{
    _recording = recording;
    
    [self updateGesturesState];
}

-(void)updateGesturesState
{
    if (_recording)
    {
//        _tapRecognizer.enabled = NO;
//        _panRecognizer.enabled = NO;
//        _longPressRecognizer.enabled = NO;
//        focusView.userInteractionEnabled = NO;
//        exposureView.userInteractionEnabled = NO;
        _swipeRightRecognizer.enabled = NO;
        _swipeLeftRecognizer.enabled = NO;
    }
    else
    {
        _swipeRightRecognizer.enabled = _blur == NO;
        _swipeLeftRecognizer.enabled = _blur == NO;

        switch (self.captureMode)
        {
            case PHAssetMediaTypeImage:
            case PHAssetMediaTypeVideo:
            {
//                _tapRecognizer.enabled = YES;
//                _panRecognizer.enabled = YES;
//                _longPressRecognizer.enabled = YES;
//                focusView.userInteractionEnabled = YES;
//                exposureView.userInteractionEnabled = YES;
                
                self.levelMeter.alpha = 0.0;
            }
                break;
            case PHAssetMediaTypeAudio:
            {
//                _tapRecognizer.enabled = NO;
//                _panRecognizer.enabled = NO;
//                _longPressRecognizer.enabled = NO;
//                focusView.userInteractionEnabled = NO;
//                exposureView.userInteractionEnabled = NO;
                
                self.levelMeter.alpha = 1.0;
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)setMeteringLevel:(CGFloat)meteringLevel
{
    [self.levelMeter updateWithLevel:meteringLevel];
}

-(void)setPreviewSession:(AVCaptureSession *)previewSession
{
    _previewSession = previewSession;
    [self.previewLayer setSession:_previewSession];
}

-(void)setBlur:(BOOL)blur
{
    [self setBlur:blur completion:nil];
}

-(void)setBlur:(BOOL)blur completion:(void (^)(void))completion
{
    _blur = blur;
    [self updateGesturesState];

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        if (weakSelf.blur == YES)
        {
            weakSelf.blurView.hidden = NO;
        }
        
        weakSelf.blurView.effect = weakSelf.blur?[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]:nil;
        
        switch (weakSelf.captureMode)
        {
            case PHAssetMediaTypeImage:
            case PHAssetMediaTypeVideo:
            {
                weakSelf.overlayView.backgroundColor = [UIColor clearColor];
            }
                break;
            case PHAssetMediaTypeAudio:
            {
                weakSelf.overlayView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
            }
                break;
            case PHAssetMediaTypeUnknown:
                break;
        }
    } completion:^(BOOL finished) {

        if (finished && weakSelf.blur == NO)
        {
            weakSelf.blurView.hidden = YES;
        }
        
        if (completion)
        {
            completion();
        }
    }];
}

-(void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    _focusMode = focusMode;
    
//    if (focusMode == AVCaptureFocusModeAutoFocus)
//    {
//        focusView.alpha = 1.0;
//    }
//    else
//    {
//        focusView.alpha = 0.0;
//    }
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    _exposureMode = exposureMode;
    
//    if (exposureMode == AVCaptureExposureModeContinuousAutoExposure)
//    {
//        exposureView.alpha = 1.0;
//    }
//    else
//    {
//        exposureView.alpha = 0.0;
//    }
}

-(void)setFocusPointOfInterest:(CGPoint)focusPointOfInterest
{
    _focusPointOfInterest = focusPointOfInterest;
    
//    CGPoint point = [self.previewLayer pointForCaptureDevicePointOfInterest:focusPointOfInterest];
//    
//    if (isnan(point.x) == false && isnan(point.y) == false)
//    {
//        focusView.center = point;
//    }
}

-(void)setExposurePointOfInterest:(CGPoint)exposurePointOfInterest
{
    _exposurePointOfInterest = exposurePointOfInterest;
    
//    CGPoint point = [self.previewLayer pointForCaptureDevicePointOfInterest:exposurePointOfInterest];
//
//    if (isnan(point.x) == false && isnan(point.y) == false)
//    {
//        exposureView.center = point;
//    }
}

-(void)featureOverlay:(IQFeatureOverlay*)featureOverlay didEndWithCenter:(CGPoint)center
{
//    if (featureOverlay == focusView)
//    {
//        if ([self.delegate respondsToSelector:@selector(mediaView:focusPointOfInterest:)])
//        {
//            [self.delegate mediaView:self focusPointOfInterest:[self.previewLayer captureDevicePointOfInterestForPoint:center]];
//        }
//    }
//    else if (featureOverlay == exposureView)
//    {
//        if ([self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
//        {
//            [self.delegate mediaView:self exposurePointOfInterest:[self.previewLayer captureDevicePointOfInterestForPoint:center]];
//        }
//    }
}

@end


