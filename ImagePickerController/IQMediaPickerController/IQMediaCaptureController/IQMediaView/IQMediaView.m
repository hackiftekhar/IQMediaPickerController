//
//  IQMediaView.m
//  ImagePickerController
//
//  Created by Iftekhar on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQMediaView.h"
#import "IQFeatureOverlay.h"
#import "DPMeterView.h"
#import "PocketSVG.h"

@interface IQMediaView ()<IQFeatureOverlayDelegate>

@property (retain)	DPMeterView *levelMeter;

@end

@implementation IQMediaView
{
    IQFeatureOverlay *focusView;
    IQFeatureOverlay *exposureView;
    
    NSTimer *updateTimer;
    
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
    focusView.alpha = 0.0;
    focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    focusView.center = self.center;
    focusView.delegate = self;
    focusView.image = [UIImage imageNamed:@"appbar_focus"];
    [self addSubview:focusView];
    
    exposureView = [[IQFeatureOverlay alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    exposureView.alpha = 0.0;
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
    
    CGPathRef path = [PocketSVG pathFromSVGFileNamed:@"mic"];
    CGRect rect = CGPathGetBoundingBox(path);

    rect.size.width = CGRectGetMidX(rect)*2;
    rect.size.height = CGRectGetMidY(rect)*2;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    NSLog(@"%@",NSStringFromCGRect(rect));
    
    CGFloat scale = 1.0;

    float mW = self.bounds.size.width / rect.size.width;
    float mH = self.bounds.size.height / rect.size.height;
    if( mH < mW )
        scale = self.bounds.size.height / rect.size.height;
    else if( mW < mH )
        scale = self.bounds.size.width / rect.size.width;
    
    self.levelMeter = [[DPMeterView alloc] initWithFrame:rect shape:path];
    self.levelMeter.trackTintColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    self.levelMeter.progressTintColor = [UIColor purpleColor];
    self.levelMeter.alpha = 0.0;
    self.levelMeter.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.levelMeter.center = CGPointMake(CGRectGetMidX(overlayView.bounds), CGRectGetMidY(overlayView.bounds));
    
    self.levelMeter.transform = CGAffineTransformScale(self.levelMeter.transform, scale, scale);
    [overlayView addSubview:self.levelMeter];
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

-(void)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode
{
    _captureMode = captureMode;
    
    switch (captureMode)
    {
        case IQMediaCaptureControllerCaptureModePhoto:
        case IQMediaCaptureControllerCaptureModeVideo:
        {
            self.levelMeter.alpha = 0.0;
        }
            break;
        case IQMediaCaptureControllerCaptureModeAudio:
        {
            self.levelMeter.alpha = 1.0;
        }
            break;
            
        default:
            break;
    }
}

-(void)setMeteringLevel:(CGFloat)meteringLevel
{
    NSLog(@"%f",meteringLevel);
    [self.levelMeter setProgress:meteringLevel];
//    self.levelMeter.backgroundColor = [UIColor colorWithWhite:meteringLevel alpha:1.0];
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
        
        if (_blur)
        {
            overlayView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:0.3];
        }
        else
        {
            switch (_captureMode)
            {
                case IQMediaCaptureControllerCaptureModePhoto:
                case IQMediaCaptureControllerCaptureModeVideo:
                {
                    overlayView.backgroundColor = [UIColor clearColor];
                }
                    break;
                case IQMediaCaptureControllerCaptureModeAudio:
                {
                    overlayView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1.0];
                }
                    break;
            }
        }
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


