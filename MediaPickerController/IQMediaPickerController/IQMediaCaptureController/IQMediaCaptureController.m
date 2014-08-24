//
//  IQMediaCaptureController.m
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


#import "IQMediaCaptureController.h"
#import "IQMediaView.h"
#import "IQCaptureSession.h"
#import "IQFileManager.h"
#import "IQPartitionBar.h"
#import "IQBottomContainerView.h"
#import "IQMediaPickerControllerConstants.h"

@interface IQMediaCaptureController ()<IQCaptureSessionDelegate,IQPartitionBarDelegate,IQMediaViewDelegate>
{
    IQMediaCaptureControllerCaptureMode _expectedCaptureMode;
    IQMediaCaptureControllerCameraDevice _expectedCameraDevice;
    
    CADisplayLink *displayDuratioUpdate;
    
    NSMutableArray *videoURLs;
    NSMutableArray *audioURLs;
    NSMutableArray *arrayImagesAttribute;

    NSUInteger videoCounter;
    NSUInteger audioCounter;
    NSUInteger imageCounter;
    
    BOOL _previousNavigationBarHidden;
    BOOL _previousStatusBarHidden;

    NSOperationQueue *operationQueue;
}

@property(nonatomic, strong, readonly) IQMediaView *mediaView;

@property(nonatomic, strong, readonly) UIView *settingsContainerView;
@property(nonatomic, strong, readonly) UIButton *buttonSettings, *buttonFlash, *buttonTorch, *buttonFocus, *buttonExposure, *buttonToggleCamera;

@property(nonatomic, strong, readonly) IQBottomContainerView *bottomContainerView;
@property(nonatomic, strong, readonly) IQPartitionBar *partitionBar;
@property(nonatomic, strong, readonly) UIImageView *imageViewProcessing;
@property(nonatomic, strong, readonly) UIButton *buttonCancel, *buttonCapture, *buttonToggleMedia, *buttonSelect, *buttonDelete;

@property(nonatomic, strong, readonly) IQCaptureSession *session;

@end

@implementation IQMediaCaptureController
@synthesize session = _session;
@synthesize mediaView = _mediaView;

@synthesize settingsContainerView = _settingsContainerView;
@synthesize partitionBar = _partitionBar,imageViewProcessing = _imageViewProcessing, buttonCancel = _buttonCancel, buttonCapture = _buttonCapture, buttonToggleMedia = _buttonToggleMedia, buttonSelect = _buttonSelect, buttonDelete = _buttonDelete;

@synthesize bottomContainerView = _bottomContainerView;
@synthesize buttonSettings = _buttonSettings, buttonFlash = _buttonFlash, buttonTorch = _buttonTorch, buttonFocus = _buttonFocus, buttonExposure = _buttonExposure, buttonToggleCamera = _buttonToggleCamera;


#pragma mark - Lifetime
+(void)load
{
    [super load];

    [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];
}

-(void)dealloc
{
    [operationQueue cancelAllOperations];
    [operationQueue cancelAllOperations];
    
    operationQueue = nil;
    operationQueue = nil;
    
    [[self session] stopRunning];
    _session = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _expectedCaptureMode = IQMediaCaptureControllerCaptureModePhoto;
        _expectedCameraDevice = IQMediaCaptureControllerCameraDeviceRear;
        
        videoURLs = [[NSMutableArray alloc] init];
        audioURLs = [[NSMutableArray alloc] init];
        arrayImagesAttribute = [[NSMutableArray alloc] init];
        
        videoCounter = 0;
        audioCounter = 0;
        imageCounter = 0;
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.mediaView];
    [self.view addSubview:self.settingsContainerView];
    [self.view addSubview:self.bottomContainerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonToggleMedia.hidden = YES;    //Toggling media type in running mode is officially not supported. Explicitly hides toggle button.
    
    [self.settingsContainerView.layer setCornerRadius:CGRectGetHeight(self.settingsContainerView.bounds)/2.0];

    [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];

    [self showSettings:NO animated:NO];

    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _session.delegate = self;
    
    [[self session] startRunning];
    [self setCaptureMode:_expectedCaptureMode animated:NO];
    [self setCaptureDevice:_expectedCameraDevice animated:NO];
    self.mediaView.previewSession = [self session].captureSession;

    _previousNavigationBarHidden = self.navigationController.navigationBarHidden;
    _previousStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _session.delegate = nil;
    
    [[self session] stopRunning];
    
    [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [displayDuratioUpdate invalidate];
    displayDuratioUpdate = nil;
    
    self.navigationController.navigationBarHidden = _previousNavigationBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:_previousStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - UI handling

- (void)settingTriggerAction:(UIButton *)button
{
    [self showSettings:self.buttonSettings.selected animated:YES];
}

-(void)showSettings:(BOOL)show animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated)?0.3:0 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        [self.buttonSettings setSelected:!show];

        if (show)
        {
            [self.buttonSettings setTransform:CGAffineTransformIdentity];
            
            CGPoint center = self.buttonSettings.center;
            center.x += 44;
            self.buttonFlash.center = center;
            center.x += 44;
            self.buttonTorch.center = center;
            center.x += 44;
            self.buttonFocus.center = center;
            center.x += 44;
            self.buttonExposure.center = center;
            center.x += 44;
            self.buttonToggleCamera.center = center;
            
            self.buttonFlash.alpha = 1.0;
            self.buttonTorch.alpha = 1.0;
            self.buttonFocus.alpha = 1.0;
            self.buttonExposure.alpha = 1.0;
            self.buttonToggleCamera.alpha = 1.0;

            CGRect frame = self.settingsContainerView.frame;
            frame.size.width = center.x+33;
            self.settingsContainerView.frame = frame;
        }
        else
        {
            [self.buttonFlash setCenter:self.buttonSettings.center];
            [self.buttonTorch setCenter:self.buttonSettings.center];
            [self.buttonFocus setCenter:self.buttonSettings.center];
            [self.buttonExposure setCenter:self.buttonSettings.center];
            [self.buttonToggleCamera setCenter:self.buttonSettings.center];

            [self.buttonSettings setTransform:CGAffineTransformMakeRotation(-M_PI_2)];

            CGRect frame = self.settingsContainerView.frame;
            frame.size.width = frame.size.height;
            self.settingsContainerView.frame = frame;

            self.buttonFlash.alpha = 0.0;
            self.buttonTorch.alpha = 0.0;
            self.buttonFocus.alpha = 0.0;
            self.buttonExposure.alpha = 0.0;
            self.buttonToggleCamera.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

-(void)updateUI
{
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        self.buttonToggleCamera.enabled = ([[IQCaptureSession supportedVideoCaptureDevices] count]>1)?YES:NO;
        
        //Flash
        if ([[self session] hasFlash])
        {
            if ([self session].flashMode == AVCaptureFlashModeOn)
                [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash"] forState:UIControlStateNormal];
            else if ([self session].flashMode == AVCaptureFlashModeOff)
                [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash_off"] forState:UIControlStateNormal];
            else if ([self session].flashMode == AVCaptureFlashModeAuto)
                [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash_auto"] forState:UIControlStateNormal];
            
            self.buttonFlash.enabled = YES;
        }
        else
        {
            [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash_off"] forState:UIControlStateNormal];
            self.buttonFlash.enabled = NO;
        }
        
        //Torch
        if ([[self session] hasTorch])
        {
            if ([self session].torchMode == AVCaptureTorchModeOn)
                [self.buttonTorch setImage:[UIImage imageNamed:@"IQ_torch_on"] forState:UIControlStateNormal];
            else if ([self session].torchMode == AVCaptureTorchModeOff)
                [self.buttonTorch setImage:[UIImage imageNamed:@"IQ_torch_off"] forState:UIControlStateNormal];
            else if ([self session].torchMode == AVCaptureTorchModeAuto)
                [self.buttonTorch setImage:[UIImage imageNamed:@"IQ_torch_auto"] forState:UIControlStateNormal];
            
            self.buttonTorch.enabled = YES;
        }
        else
        {
            [self.buttonTorch setImage:[UIImage imageNamed:@"IQ_torch_off"] forState:UIControlStateNormal];
            self.buttonTorch.enabled = NO;
        }
        
        //Focus
        {
            [self.mediaView setFocusMode:[self session].focusMode];
            [self.mediaView setFocusPointOfInterest:[self session].focusPoint];
            
            if ([[self session] hasFocus])
            {
                if ([self session].focusMode == AVCaptureFocusModeLocked)
                    [self.buttonFocus setImage:[UIImage imageNamed:@"IQ_focus_off"] forState:UIControlStateNormal];
                else if ([self session].focusMode == AVCaptureFocusModeAutoFocus)
                    [self.buttonFocus setImage:[UIImage imageNamed:@"IQ_focus_on"] forState:UIControlStateNormal];
                else if ([self session].focusMode == AVCaptureFocusModeContinuousAutoFocus)
                    [self.buttonFocus setImage:[UIImage imageNamed:@"IQ_focus_auto"] forState:UIControlStateNormal];
                
                self.buttonFocus.enabled = YES;
            }
            else
            {
                [self.buttonFocus setImage:[UIImage imageNamed:@"IQ_focus_off"] forState:UIControlStateNormal];
                self.buttonFocus.enabled = NO;
            }
        }

        //Exposure
        {
            [self.mediaView setExposureMode:[self session].exposureMode];
            [self.mediaView setExposurePointOfInterest:[self session].exposurePoint];
            
            if ([[self session] hasExposure])
            {
                if ([self session].exposureMode == AVCaptureExposureModeLocked)
                    [self.buttonExposure setImage:[UIImage imageNamed:@"IQ_exposure_off"] forState:UIControlStateNormal];
                else if ([self session].exposureMode == AVCaptureExposureModeAutoExpose)
                    [self.buttonExposure setImage:[UIImage imageNamed:@"IQ_exposure_on"] forState:UIControlStateNormal];
                else if ([self session].exposureMode == AVCaptureExposureModeContinuousAutoExposure)
                    [self.buttonExposure setImage:[UIImage imageNamed:@"IQ_exposure_auto"] forState:UIControlStateNormal];
                
                self.buttonExposure.enabled = YES;
            }
            else
            {
                [self.buttonExposure setImage:[UIImage imageNamed:@"IQ_exposure_off"] forState:UIControlStateNormal];
                self.buttonExposure.enabled = NO;
            }
        }
        
        {
            if ([[self session] isSessionRunning] == NO)
            {
                [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_neutral_mode"] forState:UIControlStateNormal];
            }
            else
            {
                if ([[self session] isRecording] == NO)
                {
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_start_capture_mode"] forState:UIControlStateNormal];
                }
                else
                {
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_stop_capture_mode"] forState:UIControlStateNormal];
                }
            }
        }
        
    } completion:^(BOOL finished) {
    }];
}

-(void)updateDuration
{
     if ([[self session] isRecording])
    {
        NSMutableArray *durations;
        
        if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
        {
            durations = [[IQFileManager durationsOfFilesAtPath:[[self class] temporaryAudioStoragePath]] mutableCopy];
        }
        else if (self.captureMode == IQMediaCaptureControllerCaptureModeVideo)
        {
            durations = [[IQFileManager durationsOfFilesAtPath:[[self class] temporaryVideoStoragePath]] mutableCopy];
        }
        
        double duration = [[self session] recordingDuration];
        bool isInfinite = isinf(duration);
        if (isInfinite == false)
        {
            [durations addObject:[NSNumber numberWithDouble:duration]];
        }
        
        [self.partitionBar setPartitions:durations animated:NO];
        
        [self.buttonCapture setTransform:CGAffineTransformConcat(self.buttonCapture.transform, CGAffineTransformMakeRotation((1.0/90.0)*M_PI))];;
    }
    else
    {
        [self.buttonCapture setTransform:CGAffineTransformIdentity];;

        [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [displayDuratioUpdate invalidate];
        displayDuratioUpdate = nil;
    }
}

#pragma mark - Camera Session Settings

-(void)setCaptureDevice:(IQMediaCaptureControllerCameraDevice)captureDevice
{
    [self setCaptureDevice:captureDevice animated:NO];
}

-(void)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode animated:(BOOL)animated
{
    if (_mediaView == nil)
    {
        _expectedCaptureMode = captureMode;
    }
    else
    {
        [self.mediaView setBlur:YES];
        
        [operationQueue addOperationWithBlock:^{
            
            BOOL success = NO;
            
            if (captureMode == IQMediaCaptureControllerCaptureModePhoto)
            {
                success = [[self session] setCaptureMode:IQCameraCaptureModePhoto];
            }
            else if (captureMode == IQMediaCaptureControllerCaptureModeVideo)
            {
                success = [[self session] setCaptureMode:IQCameraCaptureModeVideo];
            }
            else if (captureMode == IQMediaCaptureControllerCaptureModeAudio)
            {
                success = [[self session] setCaptureMode:IQCameraCaptureModeAudio];
            }
            
            if (success)
            {
                _captureMode = captureMode;
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [UIView transitionWithView:self.buttonToggleMedia duration:((animated && success)?0.5:0) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    [self.mediaView setCaptureMode:_captureMode];

                    
                    if ([self session].captureMode == IQCameraCaptureModePhoto)
                    {
                        self.settingsContainerView.hidden = NO;

//                        [self.mediaView setOverlayColor:nil];
                        
                        [self.bottomContainerView setTopContentView:nil];
                        [self.buttonToggleMedia setImage:[UIImage imageNamed:@"IQ_camera"] forState:UIControlStateNormal];
                    }
                    else if ([self session].captureMode == IQCameraCaptureModeVideo)
                    {
                        self.settingsContainerView.hidden = NO;
//                        [self.mediaView setOverlayColor:nil];
                        
                        NSArray *durations = [IQFileManager durationsOfFilesAtPath:[[self class] temporaryVideoStoragePath]];
                        [self.partitionBar setPartitions:durations animated:YES];
                        
                        [self.bottomContainerView setTopContentView:self.partitionBar];
                        [self.buttonToggleMedia setImage:[UIImage imageNamed:@"IQ_video"] forState:UIControlStateNormal];
                    }
                    else if ([self session].captureMode == IQCameraCaptureModeAudio)
                    {
                        self.settingsContainerView.hidden = YES;
//                        [self.mediaView setOverlayColor:[UIColor orangeColor]];
                        
                        NSArray *durations = [IQFileManager durationsOfFilesAtPath:[[self class] temporaryAudioStoragePath]];
                        [self.partitionBar setPartitions:durations animated:YES];
                        
                        [self.bottomContainerView setTopContentView:self.partitionBar];
                        [self.buttonToggleMedia setImage:[UIImage imageNamed:@"IQ_audio"] forState:UIControlStateNormal];
                    }
                    
                } completion:^(BOOL finished) {
                    [self updateUI];
                    [self.mediaView setBlur:NO];
                }];
            }];
        }];
    }
}

-(void)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode
{
    [self setCaptureMode:captureMode animated:NO];
}

-(void)setCaptureDevice:(IQMediaCaptureControllerCameraDevice)captureDevice animated:(BOOL)animated
{
    if (_mediaView == nil)
    {
        _expectedCameraDevice = captureDevice;
    }
    else
    {
        [self.mediaView setBlur:YES];
        
        [operationQueue addOperationWithBlock:^{
            
            BOOL success = NO;
            
            if (captureDevice == IQMediaCaptureControllerCameraDeviceRear)
            {
                success = [[self session] setCameraPosition:AVCaptureDevicePositionBack];
            }
            else if (captureDevice == IQMediaCaptureControllerCameraDeviceFront)
            {
                success = [[self session] setCameraPosition:AVCaptureDevicePositionFront];
            }
            
            if (success)
            {
                _captureDevice = captureDevice;
            }
            
            if (success)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [UIView transitionWithView:self.mediaView duration:((animated && success)?0.5:0) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseOut animations:^{
                        
                        [self updateUI];
                        
                    } completion:^(BOOL finished) {
                        
                        [self.mediaView setBlur:NO];
                    }];
                }];
            }
        }];
    }
}

- (void)toggleCameraAction:(UIButton *)sender
{
    if ([self session].cameraPosition == AVCaptureDevicePositionBack)
    {
        [self setCaptureDevice:IQMediaCaptureControllerCameraDeviceFront animated:YES];
    }
    else
    {
        [self setCaptureDevice:IQMediaCaptureControllerCameraDeviceRear animated:YES];
    }
}

- (void)toggleCaptureMode:(UIButton *)sender
{
    if ([self session].captureMode == IQCameraCaptureModePhoto)
    {
        [self setCaptureMode:IQMediaCaptureControllerCaptureModeVideo animated:YES];
    }
    else if ([self session].captureMode == IQCameraCaptureModeVideo)
    {
        [self setCaptureMode:IQMediaCaptureControllerCaptureModeAudio animated:YES];
    }
    else if ([self session].captureMode == IQCameraCaptureModeAudio)
    {
        [self setCaptureMode:IQMediaCaptureControllerCaptureModePhoto animated:YES];
    }
}

- (void)toggleFlash:(UIButton *)sender
{
    if ([self session].flashMode == AVCaptureFlashModeOff)
    {
        if ([[self session] isFlashModeSupported:AVCaptureFlashModeOn])
            [[self session] setFlashMode:AVCaptureFlashModeOn];
        else if ([[self session] isFlashModeSupported:AVCaptureFlashModeAuto])
            [[self session] setFlashMode:AVCaptureFlashModeAuto];
    }
    else if ([self session].flashMode == AVCaptureFlashModeOn)
    {
        if ([[self session] isFlashModeSupported:AVCaptureFlashModeAuto])
            [[self session] setFlashMode:AVCaptureFlashModeAuto];
        else if ([[self session] isFlashModeSupported:AVCaptureFlashModeOff])
            [[self session] setFlashMode:AVCaptureFlashModeOff];
    }
    else if ([self session].flashMode == AVCaptureFlashModeAuto)
    {
        if ([[self session] isFlashModeSupported:AVCaptureFlashModeOff])
            [[self session] setFlashMode:AVCaptureFlashModeOff];
        else if ([[self session] isFlashModeSupported:AVCaptureFlashModeOn])
            [[self session] setFlashMode:AVCaptureFlashModeOn];
    }
    
    [self updateUI];
}

- (void)toggleTorch:(UIButton *)sender
{
    if ([self session].torchMode == AVCaptureTorchModeOff)
    {
        if ([[self session] isTorchModeSupported:AVCaptureTorchModeOn])
            [[self session] setTorchMode:AVCaptureTorchModeOn];
    }
    else if ([self session].torchMode == AVCaptureTorchModeOn)
    {
        if ([[self session] isTorchModeSupported:AVCaptureTorchModeOff])
            [[self session] setTorchMode:AVCaptureTorchModeOff];
    }
    
    [self updateUI];
}

- (void)toggleFocus:(UIButton *)sender
{
    if ([self session].focusMode == AVCaptureFocusModeLocked ||[self session].focusMode == AVCaptureFocusModeAutoFocus)
    {
        if ([[self session] isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            [[self session] setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    else if ([self session].focusMode == AVCaptureFocusModeContinuousAutoFocus)
    {
        if ([[self session] isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            [[self session] setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    
    [self updateUI];
}


- (void)toggleExposure:(UIButton *)sender
{
    if ([self session].exposureMode == AVCaptureExposureModeLocked)
    {
        if ([[self session] isExposureModeSupported:AVCaptureExposureModeAutoExpose])
            [[self session] setExposureMode:AVCaptureExposureModeAutoExpose];
        else if ([[self session] isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            [[self session] setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    else if ([self session].exposureMode == AVCaptureExposureModeAutoExpose)
    {
        if ([[self session] isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            [[self session] setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        else if ([[self session] isExposureModeSupported:AVCaptureExposureModeLocked])
            [[self session] setExposureMode:AVCaptureExposureModeLocked];
    }
    else if ([self session].exposureMode == AVCaptureExposureModeContinuousAutoExposure)
    {
        if ([[self session] isExposureModeSupported:AVCaptureExposureModeLocked])
            [[self session] setExposureMode:AVCaptureExposureModeLocked];
        else if ([[self session] isExposureModeSupported:AVCaptureExposureModeAutoExpose])
            [[self session] setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    
    [self updateUI];
}

- (void)whiteBalance:(UIButton *)sender
{
    if ([self session].whiteBalanceMode == AVCaptureWhiteBalanceModeLocked)
    {
        if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        else if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    else if ([self session].whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance)
    {
        if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        else if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    }
    else if ([self session].whiteBalanceMode == AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)
    {
        if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        else if ([[self session] isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
            [[self session] setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    
    [self updateUI];
}

- (void)captureAction:(UIButton *)sender
{
    if ([[self session] isSessionRunning] == NO)
    {
        [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_start_capture_mode"] forState:UIControlStateNormal];

        [[self session] startRunning];
        [self.bottomContainerView setRightContentView:self.buttonToggleMedia];
        
        //Resetting
        if (self.allowsCapturingMultipleItems == NO)
        {
            videoCounter = 0;
            audioCounter = 0;
            imageCounter = 0;
            
            [videoURLs removeAllObjects];
            [audioURLs removeAllObjects];
            [arrayImagesAttribute removeAllObjects];
            
            [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
            [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
            [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];
            
            [self.partitionBar setPartitions:[NSArray new] animated:YES];
        }
    }
    else
    {
        if ([self session].captureMode == IQCameraCaptureModePhoto)
        {
            [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_neutral_mode"] forState:UIControlStateNormal];
                self.settingsContainerView.alpha = 0.0;
            } completion:NULL];

            [self.bottomContainerView setLeftContentView:nil];
            [self.bottomContainerView setRightContentView:nil];
            [self.bottomContainerView setMiddleContentView:self.imageViewProcessing];

            [[self session] takePicture];
        }
        else if ([self session].captureMode == IQCameraCaptureModeVideo)
        {
            if ([self session].isRecording == NO)
            {
                [[self session] startVideoRecording];
                
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_stop_capture_mode"] forState:UIControlStateNormal];
                    [self.partitionBar setSelectedIndex:-1];
                    self.settingsContainerView.alpha = 0.0;
                } completion:NULL];
                
                [self.partitionBar setUserInteractionEnabled:NO];
                [self.bottomContainerView setLeftContentView:nil];
                [self.bottomContainerView setRightContentView:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    displayDuratioUpdate = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDuration)];
                    [displayDuratioUpdate addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                });
            }
            else
            {
                [[self session] stopVideoRecording];
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_neutral_mode"] forState:UIControlStateNormal];
                    [self.buttonCapture setTransform:CGAffineTransformIdentity];;
                } completion:NULL];
                
                [self.bottomContainerView setLeftContentView:nil];
                [self.bottomContainerView setRightContentView:nil];
                [self.bottomContainerView setMiddleContentView:self.imageViewProcessing];
                
                [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                [displayDuratioUpdate invalidate];
                displayDuratioUpdate = nil;
                
                [self.partitionBar setUserInteractionEnabled:YES];
            }
        }
        else if ([self session].captureMode == IQCameraCaptureModeAudio)
        {
            if ([self session].isRecording == NO)
            {
                [[self session] startAudioRecording];
                
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_stop_capture_mode"] forState:UIControlStateNormal];
                    [self.partitionBar setSelectedIndex:-1];
                    self.settingsContainerView.alpha = 0.0;
                } completion:NULL];
                
                [self.partitionBar setUserInteractionEnabled:NO];
                [self.bottomContainerView setLeftContentView:nil];
                [self.bottomContainerView setRightContentView:nil];

                displayDuratioUpdate = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDuration)];
                [displayDuratioUpdate addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            }
            else
            {
                [[self session] stopAudioRecording];
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [self.buttonCapture setImage:[UIImage imageNamed:@"IQ_neutral_mode"] forState:UIControlStateNormal];
                    [self.buttonCapture setTransform:CGAffineTransformIdentity];;
                } completion:NULL];
                
                [self.bottomContainerView setLeftContentView:nil];
                [self.bottomContainerView setRightContentView:nil];
                [self.bottomContainerView setMiddleContentView:self.imageViewProcessing];
                
                [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                [displayDuratioUpdate invalidate];
                displayDuratioUpdate = nil;

                [self.partitionBar setUserInteractionEnabled:YES];
            }
        }
    }
}

#pragma mark - Other Actions

- (void)cancelAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaCaptureControllerDidCancel:)])
    {
        [self.delegate mediaCaptureControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaCaptureController:didFinishMediaWithInfo:)])
    {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        
        if ([arrayImagesAttribute count])
        {
            [info setObject:arrayImagesAttribute forKey:IQMediaTypeImage];
        }
        
        if ([videoURLs count])
        {
            NSMutableArray *videoMedias = [[NSMutableArray alloc] init];
            
            for (NSURL *videoURL in videoURLs)
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:videoURL forKey:IQMediaURL];
                [videoMedias addObject:dict];
            }
            
            [info setObject:videoMedias forKey:IQMediaTypeVideo];
        }
        
        if ([audioURLs count])
        {
            NSMutableArray *audioMedias = [[NSMutableArray alloc] init];
            
            for (NSURL *audioURL in audioURLs)
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:audioURL forKey:IQMediaURL];
                [audioMedias addObject:dict];
            }
            
            [info setObject:audioMedias forKey:IQMediaTypeAudio];
        }
        
        [self.delegate mediaCaptureController:self didFinishMediaWithInfo:info];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteAction:(UIButton *)sender
{
    NSURL *mediaURL = [videoURLs objectAtIndex:self.partitionBar.selectedIndex];
    
    [videoURLs removeObject:mediaURL];
    [IQFileManager removeItemAtPath:mediaURL.relativePath];
    
    [self.partitionBar removeSelectedPartition];
    
    if (self.partitionBar.partitions.count > 0)
    {
        [self.bottomContainerView setLeftContentView:self.buttonDelete];
    }
    else
    {
        [self.bottomContainerView setLeftContentView:self.buttonCancel];
    }
}

#pragma mark - IQMediaView Delegates

-(void)mediaView:(IQMediaView*)mediaView focusPointOfInterest:(CGPoint)focusPoint
{
    [[self session] setFocusPoint:focusPoint];
}

-(void)mediaView:(IQMediaView*)mediaView exposurePointOfInterest:(CGPoint)exposurePoint
{
    [[self session] setExposurePoint:exposurePoint];
}

#pragma mark - IQCaptureSession Delegates

- (void)captureSession:(IQCaptureSession*)audioSession didUpdateMeterLevel:(CGFloat)meterLevel
{
    self.mediaView.meteringLevel = meterLevel;
}

-(void)captureSession:(IQCaptureSession*)captureSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError*)error
{
    [[self session] stopRunning];
    
    //Resetting
    if (self.allowsCapturingMultipleItems == NO)
    {
        videoCounter = 0;
        audioCounter = 0;
        imageCounter = 0;
        
        [videoURLs removeAllObjects];
        [audioURLs removeAllObjects];
        [arrayImagesAttribute removeAllObjects];
        
        [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
        [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
        [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];
        
        [self.partitionBar setPartitions:[NSArray new] animated:YES];
    }

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        self.settingsContainerView.alpha = 1.0;
    } completion:NULL];
    
    [self.bottomContainerView setLeftContentView:self.buttonCancel];
    [self.bottomContainerView setMiddleContentView:self.buttonCapture];
    [self.bottomContainerView setRightContentView:self.buttonSelect];
    
    if (error == nil)
    {
        if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeVideo])
        {
            NSURL *mediaURL = [info objectForKey:IQMediaURL];
            
            NSString *nextMediaPath = [[[self class] temporaryVideoStoragePath] stringByAppendingFormat:@"/movie%lu.mov",(unsigned long)videoCounter++];
            
            [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
            
            [videoURLs addObject:[IQFileManager URLForFilePath:nextMediaPath]];
            
            NSArray *durations = [IQFileManager durationsOfFilesAtPath:[[self class] temporaryVideoStoragePath]];
            
            [self.partitionBar setPartitions:durations animated:NO];
        }
        else if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeImage])
        {
            NSURL *mediaURL = [info objectForKey:IQMediaURL];
            
            NSString *nextMediaPath = [[[self class] temporaryImageStoragePath] stringByAppendingFormat:@"/image%lu.jpg",(unsigned long)imageCounter++];
            
            [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
            
            NSMutableDictionary *dict = [info mutableCopy];
            [dict removeObjectForKey:IQMediaType];
            [dict setObject:[IQFileManager URLForFilePath:nextMediaPath] forKey:IQMediaURL];
            
            [arrayImagesAttribute addObject:dict];
        }
        else if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeAudio])
        {
            NSURL *mediaURL = [info objectForKey:IQMediaURL];
            
            NSString *nextMediaPath = [[[self class] temporaryAudioStoragePath] stringByAppendingFormat:@"/audio%lu.m4a",(unsigned long)audioCounter++];
            
            [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
            
            [audioURLs addObject:[IQFileManager URLForFilePath:nextMediaPath]];
            
            NSArray *durations = [IQFileManager durationsOfFilesAtPath:[[self class] temporaryAudioStoragePath]];
            
            [self.partitionBar setPartitions:durations animated:NO];
        }
    }
}

#pragma mark - IQPartitionBar Delegate
-(void)partitionBar:(IQPartitionBar*)bar didSelectPartitionIndex:(NSUInteger)index
{
    if (index != -1 && bar.partitions.count > 0)
    {
        [self.bottomContainerView setLeftContentView:self.buttonDelete];
    }
    else
    {
        [self.bottomContainerView setLeftContentView:self.buttonCancel];
    }
}

#pragma mark - Overrides
-(IQCaptureSession *)session
{
    if (_session == nil)
    {
        _session = [[IQCaptureSession alloc] init];
        [_session setExposureMode:AVCaptureExposureModeLocked];
        [_session setFocusMode:AVCaptureFocusModeLocked];
    }
    return _session;
}

-(IQMediaView *)mediaView
{
    if (_mediaView == nil)
    {
        _mediaView = [[IQMediaView alloc] initWithFrame:self.view.bounds];
        _mediaView.delegate = self;
    }
    
    return _mediaView;
}

-(UIView *)settingsContainerView
{
    if (_settingsContainerView == nil)
    {
        _settingsContainerView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 275, 44)];
        _settingsContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        [_settingsContainerView addSubview:self.buttonToggleCamera];
        [_settingsContainerView addSubview:self.buttonExposure];
        [_settingsContainerView addSubview:self.buttonFocus];
        [_settingsContainerView addSubview:self.buttonTorch];
        [_settingsContainerView addSubview:self.buttonFlash];
        [_settingsContainerView addSubview:self.buttonSettings];
    }
    
    return _settingsContainerView;
}

-(UIButton *)buttonSettings
{
    if (_buttonSettings == nil)
    {
        _buttonSettings          = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_buttonSettings         setImage:[UIImage imageNamed:@"IQ_settings"] forState:UIControlStateNormal];
        [_buttonSettings         addTarget:self action:@selector(settingTriggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonSettings;
}

-(UIButton *)buttonFlash
{
    if (_buttonFlash == nil)
    {
        _buttonFlash             = [[UIButton alloc] initWithFrame:CGRectMake(44, 0, 44, 44)];
        [_buttonFlash            setImage:[UIImage imageNamed:@"IQ_camera_flash_off"] forState:UIControlStateNormal];
        [_buttonFlash            addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonFlash;
}

-(UIButton *)buttonTorch
{
    if (_buttonTorch == nil)
    {
        _buttonTorch             = [[UIButton alloc] initWithFrame:CGRectMake(88, 0, 44, 44)];
        [_buttonTorch            setImage:[UIImage imageNamed:@"IQ_torch_off"] forState:UIControlStateNormal];
        [_buttonTorch            addTarget:self action:@selector(toggleTorch:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonTorch;
}

-(UIButton *)buttonFocus
{
    if (_buttonFocus == nil)
    {
        _buttonFocus             = [[UIButton alloc] initWithFrame:CGRectMake(132, 0, 44, 44)];
        [_buttonFocus            setImage:[UIImage imageNamed:@"IQ_focus_off"] forState:UIControlStateNormal];
        [_buttonFocus            addTarget:self action:@selector(toggleFocus:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonFocus;
}

-(UIButton *)buttonExposure
{
    if (_buttonExposure == nil)
    {
        _buttonExposure          = [[UIButton alloc] initWithFrame:CGRectMake(176, 0, 44, 44)];
        [_buttonExposure         setImage:[UIImage imageNamed:@"IQ_exposure_off"] forState:UIControlStateNormal];
        [_buttonExposure         addTarget:self action:@selector(toggleExposure:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonExposure;
}

-(UIButton *)buttonToggleCamera
{
    if (_buttonToggleCamera == nil)
    {
        _buttonToggleCamera      = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 44, 44)];
        [_buttonToggleCamera     setImage:[UIImage imageNamed:@"IQ_camera_switch"] forState:UIControlStateNormal];
        [_buttonToggleCamera     addTarget:self action:@selector(toggleCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonToggleCamera;
}


-(IQBottomContainerView *)bottomContainerView
{
    if (_bottomContainerView == nil)
    {
        _bottomContainerView = [[IQBottomContainerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-90, CGRectGetWidth(self.view.bounds), 90)];
        _bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        [_bottomContainerView setTopContentView:self.partitionBar];
        [_bottomContainerView setLeftContentView:self.buttonCancel];
        [_bottomContainerView setMiddleContentView:self.buttonCapture];
        [_bottomContainerView setRightContentView:self.buttonToggleMedia];
    }
    return _bottomContainerView;
}

-(IQPartitionBar *)partitionBar
{
    if (_partitionBar == nil)
    {
        _partitionBar = [[IQPartitionBar alloc] init];
        _partitionBar.delegate = self;
        _partitionBar.backgroundColor = [UIColor clearColor];
    }
    
    return _partitionBar;
}

-(UIImageView *)imageViewProcessing
{
    if (_imageViewProcessing == nil)
    {
        _imageViewProcessing = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IQ_hourglass"]];
        _imageViewProcessing.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewProcessing;
}

-(UIButton *)buttonCancel
{
    if (_buttonCancel == nil)
    {
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCancel.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [_buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_buttonCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonCancel;
}

-(UIButton *)buttonCapture
{
    if (_buttonCapture == nil)
    {
        _buttonCapture = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCapture setImage:[UIImage imageNamed:@"IQ_neutral_mode"] forState:UIControlStateNormal];
        [_buttonCapture addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonCapture;
}

-(UIButton *)buttonToggleMedia
{
    if (_buttonToggleMedia == nil)
    {
        _buttonToggleMedia = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonToggleMedia setImage:[UIImage imageNamed:@"IQ_camera"] forState:UIControlStateNormal];
        [_buttonToggleMedia addTarget:self action:@selector(toggleCaptureMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonToggleMedia;
}

-(UIButton *)buttonSelect
{
    if (_buttonSelect == nil)
    {
        _buttonSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonSelect.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        [_buttonSelect setTitle:@"Select" forState:UIControlStateNormal];
        [_buttonSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonSelect addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonSelect;
}

-(UIButton *)buttonDelete
{
    if (_buttonDelete == nil)
    {
        _buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonDelete setImage:[UIImage imageNamed:@"IQ_delete"] forState:UIControlStateNormal];
        [_buttonDelete addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonDelete;
}

#pragma mark - Temporary path
+(NSString*)temporaryVideoStoragePath
{
    NSString *videoPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"/IQVideo/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return videoPath;
}

+(NSString*)temporaryAudioStoragePath
{
    NSString *audioPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"/IQAudio/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return audioPath;
}

+(NSString*)temporaryImageStoragePath
{
    NSString *audioPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"/IQImage/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return audioPath;
}


@end
