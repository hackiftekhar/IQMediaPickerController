//
//  IQMediaView.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQMediaView.h"
#import "IQFeatureOverlay.h"

@interface IQMediaView ()<IQFeatureOverlayDelegate>

@end

@implementation IQMediaView
{
    IQFeatureOverlay *focusView;
    IQFeatureOverlay *exposureView;
    
    UIView *overlayView;
    UIPanGestureRecognizer *_panRecognizer;
    UITapGestureRecognizer *_tapRecognizer;
}

+(Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

-(void)initialize
{
    self.backgroundColor = [UIColor blackColor];
    [(AVCaptureVideoPreviewLayer*)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    focusView = [[IQFeatureOverlay alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    focusView.center = self.center;
    focusView.delegate = self;
    focusView.image = [UIImage imageNamed:@"appbar_focus"];
    [self addSubview:focusView];
    
    exposureView = [[IQFeatureOverlay alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    exposureView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    exposureView.center = self.center;
    exposureView.delegate = self;
    exposureView.image = [UIImage imageNamed:@"appbar_exposure"];
    [self addSubview:exposureView];
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:_panRecognizer];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self addGestureRecognizer:_tapRecognizer];
    
    overlayView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, -CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds))];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlayView.userInteractionEnabled = NO;
    overlayView.backgroundColor = [UIColor clearColor];
    [self addSubview:overlayView];
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

-(void)tapGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint center = [recognizer locationInView:self];
    
    [exposureView setCenter:center];
    
    if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
    {
        [self.delegate mediaView:self exposurePointOfInterest:exposureView.center];
    }
}


-(void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint center = [recognizer locationInView:self];
    
    [exposureView setCenter:center];
    
    if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
    {
        [self.delegate mediaView:self exposurePointOfInterest:exposureView.center];
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void)setPreviewSession:(AVCaptureSession *)previewSession
{
    _previewSession = previewSession;
    [(AVCaptureVideoPreviewLayer*)self.layer setSession:_previewSession];
}

-(void)setBlur:(BOOL)blur
{
    [UIView animateWithDuration:0.3 animations:^{
        _blur = blur;
        
        [self.layer setShouldRasterize:_blur];
        
        self.layer.rasterizationScale = (_blur)?0.02:[[UIScreen mainScreen] scale];
        
        overlayView.backgroundColor = (_blur)?[[UIColor whiteColor] colorWithAlphaComponent:0.3]:[UIColor clearColor];
    }];
}

-(void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    _focusMode = focusMode;
    
    if (focusMode == AVCaptureFocusModeAutoFocus)
    {
        focusView.alpha = 1.0;
    }
    else
    {
        focusView.alpha = 0.0;
    }
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    _exposureMode = exposureMode;
    
    if (exposureMode == AVCaptureExposureModeContinuousAutoExposure)
    {
        exposureView.alpha = 1.0;
    }
    else
    {
        exposureView.alpha = 0.0;
    }
}

-(void)setFocusPointOfInterest:(CGPoint)focusPointOfInterest
{
    _focusPointOfInterest = focusPointOfInterest;
    
    CGPoint point = [(AVCaptureVideoPreviewLayer*)self.layer pointForCaptureDevicePointOfInterest:focusPointOfInterest];
    
    if (isnan(point.x) == false && isnan(point.y) == false)
    {
        focusView.center = point;
    }
}

-(void)setExposurePointOfInterest:(CGPoint)exposurePointOfInterest
{
    _exposurePointOfInterest = exposurePointOfInterest;
    
    CGPoint point = [(AVCaptureVideoPreviewLayer*)self.layer pointForCaptureDevicePointOfInterest:exposurePointOfInterest];

    if (isnan(point.x) == false && isnan(point.y) == false)
    {
        exposureView.center = point;
    }
}

-(void)featureOverlay:(IQFeatureOverlay*)featureOverlay didEndWithCenter:(CGPoint)center
{
    if (featureOverlay == focusView)
    {
        if ([self.delegate respondsToSelector:@selector(mediaView:focusPointOfInterest:)])
        {
            [self.delegate mediaView:self focusPointOfInterest:[(AVCaptureVideoPreviewLayer*)self.layer captureDevicePointOfInterestForPoint:center]];
        }
    }
    else if (featureOverlay == exposureView)
    {
        if ([self.delegate respondsToSelector:@selector(mediaView:exposurePointOfInterest:)])
        {
            [self.delegate mediaView:self exposurePointOfInterest:[(AVCaptureVideoPreviewLayer*)self.layer captureDevicePointOfInterestForPoint:center]];
        }
    }
}

@end


