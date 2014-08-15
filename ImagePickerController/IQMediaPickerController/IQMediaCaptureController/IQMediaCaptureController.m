//
//  IQVideoCaptureController.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQMediaCaptureController.h"
#import "IQMediaView.h"
#import "IQCaptureSession.h"
#import "IQFileManager.h"
#import "IQPartitionBar.h"
#import "IQBottomContainerView.h"

NSString *const IQMediaTypeVideo    =   @"IQMediaTypeVideo";      // an NSString (UTI, i.e. kUTTypeImage)
NSString *const IQMediaTypeImage    =   @"IQMediaTypeImage";      // an NSString (UTI, i.e. kUTTypeImage)

@interface IQMediaCaptureController ()<IQCaptureSessionDelegate,IQPartitionBarDelegate,IQMediaViewDelegate>
{
    IBOutlet IQMediaView *mediaView;
    
    IBOutlet IQBottomContainerView *bottomContainerView;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonCapture;
    IBOutlet UIButton *buttonToggleMedia;
    IBOutlet UIButton *buttonToggleCamera;
    UIButton *buttonSelect;
    UIButton *buttonDelete;
    UIImageView *imageProcessing;
    
    NSTimer *timerDuratioUpdate;
    NSTimer *timerScreenRefresh;
    
    IBOutlet UIView *settingsContainerView;
    IBOutlet UIButton *buttonSettings;
    IBOutlet UIButton *buttonFlash;
    IBOutlet UIButton *buttonTorch;
    IBOutlet UIButton *buttonFocus;
    IBOutlet UIButton *buttonExposure;
    
    IBOutlet IQPartitionBar *partitionBar;
    NSMutableArray *mediaURLs;
    NSUInteger counter;
    
    UIImage *capturedImage;
    
    BOOL _previousNavigationBarHidden;
    BOOL _previousStatusBarHidden;
}

@property(nonatomic, strong, readonly) IQCaptureSession *session;

@end

@implementation IQMediaCaptureController
@synthesize session = _session;

+(NSString*)storagePath
{
    return [IQFileManager IQDocumentDirectory];
}

-(void)dealloc
{
    [[self session] stopRunning];
    _session = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    buttonToggleMedia.hidden = YES;
    
    mediaURLs = [[NSMutableArray alloc] init];
    counter = 0;
    [settingsContainerView.layer setCornerRadius:CGRectGetHeight(settingsContainerView.bounds)/2.0];

    [IQFileManager removeItemsAtPath:[[self class] storagePath]];

    mediaView.previewSession = [self session].captureSession;
    
    [self showSettings:NO animated:NO];

    buttonSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSelect.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [buttonSelect setTitle:@"Select" forState:UIControlStateNormal];
    [buttonSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSelect addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonDelete.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [buttonDelete setImage:[UIImage imageNamed:@"appbar_delete"] forState:UIControlStateNormal];
    [buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonDelete addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    imageProcessing = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appbar_hourglass"]];
    imageProcessing.contentMode = UIViewContentModeScaleAspectFit;
    
    [self updateUI];
}

-(IQCaptureSession *)session
{
    if (_session == nil)
    {
        _session = [[IQCaptureSession alloc] init];
        [_session setExposureMode:AVCaptureExposureModeLocked];
        [_session setFocusMode:AVCaptureFocusModeLocked];
        _session.delegate = self;
    }
    return _session;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _previousNavigationBarHidden = self.navigationController.navigationBarHidden;
    _previousStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self session] stopRunning];
    [timerDuratioUpdate invalidate];
    
    self.navigationController.navigationBarHidden = _previousNavigationBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:_previousStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
}

-(void)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode
{
    [mediaView setBlur:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[self session] stopRunning];
        
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView transitionWithView:buttonToggleMedia duration:(success?0.5:0) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseOut animations:^{
                [[self session] startRunning];
                
                if ([self session].captureMode == IQCameraCaptureModePhoto)
                {
                    [bottomContainerView setTopContentView:nil];
                    [buttonToggleMedia setImage:[UIImage imageNamed:@"appbar_camera"] forState:UIControlStateNormal];
                }
                else if ([self session].captureMode == IQCameraCaptureModeVideo)
                {
                    [bottomContainerView setTopContentView:partitionBar];
                    [buttonToggleMedia setImage:[UIImage imageNamed:@"appbar_video"] forState:UIControlStateNormal];
                }
                else if ([self session].captureMode == IQCameraCaptureModeAudio)
                {
                    [bottomContainerView setTopContentView:nil];
                    [buttonToggleMedia setImage:[UIImage imageNamed:@"appbar_audio"] forState:UIControlStateNormal];
                }
                
            } completion:^(BOOL finished) {
                [mediaView setBlur:NO];
            }];
        });
    });
}

-(void)setCaptureDevice:(IQMediaCaptureControllerCameraDevice)captureDevice
{
    [mediaView setBlur:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[self session] stopRunning];
        
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:mediaView duration:(success?0.5:0) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    [[self session] startRunning];
                    [self updateUI];
                    
                } completion:^(BOOL finished) {
                    
                    [mediaView setBlur:NO];
                }];
            });
        }
    });
}

//-(void)setAllowsMultipleVideoRecording:(BOOL)allowsMultipleVideoRecording
//{
//    _allowsMultipleVideoRecording = allowsMultipleVideoRecording;
//}

#pragma mark - UI handling

- (IBAction)settingTriggerAction:(UIButton *)button
{
    [self showSettings:buttonSettings.selected animated:YES];
}

-(void)showSettings:(BOOL)show animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated)?0.3:0 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        [buttonSettings setSelected:!show];

        if (show)
        {
            [buttonSettings setTransform:CGAffineTransformIdentity];
            
            CGPoint center = buttonSettings.center;
            center.x += 44;
            buttonFlash.center = center;
            center.x += 44;
            buttonTorch.center = center;
            center.x += 44;
            buttonFocus.center = center;
            center.x += 44;
            buttonExposure.center = center;
            center.x += 44;
            buttonToggleCamera.center = center;
            
            buttonFlash.alpha = 1.0;
            buttonTorch.alpha = 1.0;
            buttonFocus.alpha = 1.0;
            buttonExposure.alpha = 1.0;
            buttonToggleCamera.alpha = 1.0;

            CGRect frame = settingsContainerView.frame;
            frame.size.width = center.x+33;
            settingsContainerView.frame = frame;
        }
        else
        {
            [buttonSettings setTransform:CGAffineTransformMakeRotation(-M_PI_2)];

            CGRect frame = settingsContainerView.frame;
            frame.size.width = frame.size.height;
            settingsContainerView.frame = frame;

            [buttonFlash setCenter:buttonSettings.center];
            [buttonTorch setCenter:buttonSettings.center];
            [buttonFocus setCenter:buttonSettings.center];
            [buttonExposure setCenter:buttonSettings.center];
            [buttonToggleCamera setCenter:buttonSettings.center];
            
            buttonFlash.alpha = 0.0;
            buttonTorch.alpha = 0.0;
            buttonFocus.alpha = 0.0;
            buttonExposure.alpha = 0.0;
            buttonToggleCamera.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

-(void)updateUI
{
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        
        //Flash
        if ([[self session] hasFlash])
        {
            if ([self session].flashMode == AVCaptureFlashModeOn)
                [buttonFlash setImage:[UIImage imageNamed:@"appbar_camera_flash"] forState:UIControlStateNormal];
            else if ([self session].flashMode == AVCaptureFlashModeOff)
                [buttonFlash setImage:[UIImage imageNamed:@"appbar_camera_flash_off"] forState:UIControlStateNormal];
            else if ([self session].flashMode == AVCaptureFlashModeAuto)
                [buttonFlash setImage:[UIImage imageNamed:@"appbar_camera_flash_auto"] forState:UIControlStateNormal];
            
            buttonFlash.enabled = YES;
        }
        else
        {
            [buttonFlash setImage:[UIImage imageNamed:@"appbar_camera_flash_off"] forState:UIControlStateNormal];
            buttonFlash.enabled = NO;
        }
        
        //Torch
        if ([[self session] hasTorch])
        {
            if ([self session].torchMode == AVCaptureTorchModeOn)
                [buttonTorch setImage:[UIImage imageNamed:@"appbar_torch_on"] forState:UIControlStateNormal];
            else if ([self session].torchMode == AVCaptureTorchModeOff)
                [buttonTorch setImage:[UIImage imageNamed:@"appbar_torch_off"] forState:UIControlStateNormal];
            else if ([self session].torchMode == AVCaptureTorchModeAuto)
                [buttonTorch setImage:[UIImage imageNamed:@"appbar_torch_auto"] forState:UIControlStateNormal];
            
            buttonTorch.enabled = YES;
        }
        else
        {
            [buttonTorch setImage:[UIImage imageNamed:@"appbar_torch_off"] forState:UIControlStateNormal];
            buttonTorch.enabled = NO;
        }
        
        //Focus
        {
            [mediaView setFocusMode:[self session].focusMode];
            [mediaView setFocusPointOfInterest:[self session].focusPoint];
            
            if ([[self session] hasFocus])
            {
                if ([self session].focusMode == AVCaptureFocusModeLocked)
                    [buttonFocus setImage:[UIImage imageNamed:@"appbar_focus_off"] forState:UIControlStateNormal];
                else if ([self session].focusMode == AVCaptureFocusModeAutoFocus)
                    [buttonFocus setImage:[UIImage imageNamed:@"appbar_focus_on"] forState:UIControlStateNormal];
                else if ([self session].focusMode == AVCaptureFocusModeContinuousAutoFocus)
                    [buttonFocus setImage:[UIImage imageNamed:@"appbar_focus_auto"] forState:UIControlStateNormal];
                
                buttonFocus.enabled = YES;
            }
            else
            {
                [buttonFocus setImage:[UIImage imageNamed:@"appbar_focus_off"] forState:UIControlStateNormal];
                buttonFocus.enabled = NO;
            }
        }

        //Exposure
        {
            [mediaView setExposureMode:[self session].exposureMode];
            [mediaView setExposurePointOfInterest:[self session].exposurePoint];
            
            if ([[self session] hasExposure])
            {
                if ([self session].exposureMode == AVCaptureExposureModeLocked)
                    [buttonExposure setImage:[UIImage imageNamed:@"appbar_exposure_off"] forState:UIControlStateNormal];
                else if ([self session].exposureMode == AVCaptureExposureModeAutoExpose)
                    [buttonExposure setImage:[UIImage imageNamed:@"appbar_exposure_on"] forState:UIControlStateNormal];
                else if ([self session].exposureMode == AVCaptureExposureModeContinuousAutoExposure)
                    [buttonExposure setImage:[UIImage imageNamed:@"appbar_exposure_auto"] forState:UIControlStateNormal];
                
                buttonExposure.enabled = YES;
            }
            else
            {
                [buttonExposure setImage:[UIImage imageNamed:@"appbar_exposure_off"] forState:UIControlStateNormal];
                buttonExposure.enabled = NO;
            }
        }
    } completion:^(BOOL finished) {
    }];
}

-(void)updateDuration
{
    if ([[self session] isRecording])
    {
        NSMutableArray *durations = [[IQFileManager durationsOfFilesAtPath:[[self class] storagePath]] mutableCopy];
        
        double duration = [[self session] recordingDuration];
        bool isInfinite = isinf(duration);
        if (isInfinite == false)
        {
            [durations addObject:[NSNumber numberWithDouble:duration]];
        }
        
        [partitionBar setPartitions:durations animated:NO];
        
        [buttonCapture setTransform:CGAffineTransformConcat(buttonCapture.transform, CGAffineTransformMakeRotation((1.0/90.0)*M_PI))];;
    }
    else
    {
        [buttonCapture setTransform:CGAffineTransformIdentity];;
        [timerDuratioUpdate invalidate];
    }
}

#pragma mark - Camera Session Settings

- (IBAction)toggleCameraAction:(UIButton *)sender
{
    if ([self session].cameraPosition == AVCaptureDevicePositionBack)
    {
        [self setCaptureDevice:IQMediaCaptureControllerCameraDeviceFront];
    }
    else
    {
        [self setCaptureDevice:IQMediaCaptureControllerCameraDeviceRear];
    }
}

- (IBAction)toggleCaptureMode:(UIButton *)sender
{
    if ([self session].captureMode == IQCameraCaptureModePhoto)
    {
        [self setCaptureMode:IQMediaCaptureControllerCaptureModeVideo];
    }
    else
    {
        [self setCaptureMode:IQMediaCaptureControllerCaptureModePhoto];
    }
}

- (IBAction)toggleFlash:(UIButton *)sender
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

- (IBAction)toggleTorch:(UIButton *)sender
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

- (IBAction)toggleFocus:(UIButton *)sender
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


- (IBAction)toggleExposure:(UIButton *)sender
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

- (IBAction)whiteBalance:(UIButton *)sender
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

- (IBAction)captureAction:(UIButton *)sender
{
    if ([[self session] isSessionRunning] == NO)
    {
        [buttonCapture setImage:[UIImage imageNamed:@"appbar_location_circle"] forState:UIControlStateNormal];
        [[self session] startRunning];
        [bottomContainerView setRightContentView:buttonToggleMedia];
    }
    else
    {
        if ([self session].captureMode == IQCameraCaptureModePhoto)
        {
            [[self session] takePicture];
            
            [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                [buttonCapture setImage:[UIImage imageNamed:@"appbar_marvel_ironman"] forState:UIControlStateNormal];
                settingsContainerView.alpha = 0.0;
            } completion:NULL];

            [bottomContainerView setLeftContentView:nil];
            [bottomContainerView setRightContentView:nil];
            [bottomContainerView setMiddleContentView:imageProcessing];
        }
        else if ([self session].captureMode == IQCameraCaptureModeVideo)
        {
            if ([self session].isRecording == NO)
            {
                [[self session] startVideoRecording];
                
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [buttonCapture setImage:[UIImage imageNamed:@"appbar_marvel_ironman"] forState:UIControlStateNormal];
                    [partitionBar setSelectedIndex:-1];
                    settingsContainerView.alpha = 0.0;
                } completion:NULL];
                
                [partitionBar setUserInteractionEnabled:NO];
                [bottomContainerView setLeftContentView:nil];
                [bottomContainerView setRightContentView:nil];
                timerDuratioUpdate = [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timerDuratioUpdate forMode:NSDefaultRunLoopMode];
            }
            else
            {
                [[self session] stopVideoRecording];
                [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
                    [buttonCapture setImage:[UIImage imageNamed:@"appbar_location_circle"] forState:UIControlStateNormal];
                    [timerDuratioUpdate invalidate];
                    [buttonCapture setTransform:CGAffineTransformIdentity];;
                } completion:NULL];

                [bottomContainerView setLeftContentView:nil];
                [bottomContainerView setRightContentView:nil];
                [bottomContainerView setMiddleContentView:imageProcessing];

                [partitionBar setUserInteractionEnabled:YES];
            }
        }
    }
}

#pragma mark - Other Actions

- (IBAction)cancelAction:(UIButton *)sender
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
        
        if (capturedImage)
        {
            NSDictionary *imageInfo = [NSDictionary dictionaryWithObject:capturedImage forKey:IQMediaImage];
            [info setObject:[NSArray arrayWithObject:imageInfo] forKey:IQMediaTypeImage];
        }
        
        if ([mediaURLs count])
        {
            NSMutableArray *videoMedias = [[NSMutableArray alloc] init];
            
            for (NSURL *videoURL in mediaURLs)
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:videoURL forKey:IQMediaURL];
                [videoMedias addObject:dict];
            }
            
            [info setObject:videoMedias forKey:IQMediaTypeVideo];
        }
        
        [self.delegate mediaCaptureController:self didFinishMediaWithInfo:info];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteAction:(UIButton *)sender
{
    NSURL *mediaURL = [mediaURLs objectAtIndex:partitionBar.selectedIndex];
    
    [mediaURLs removeObject:mediaURL];
    [IQFileManager removeItemAtPath:mediaURL.relativePath];
    
    [partitionBar removeSelectedPartition];
    
    if (partitionBar.partitions.count > 0)
    {
        [bottomContainerView setLeftContentView:buttonDelete];
    }
    else
    {
        [bottomContainerView setLeftContentView:buttonCancel];
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

-(void)captureSession:(IQCaptureSession*)captureSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError*)error
{
    [[self session] stopRunning];

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut) animations:^{
        settingsContainerView.alpha = 1.0;
    } completion:NULL];

    [bottomContainerView setLeftContentView:buttonCancel];
    [bottomContainerView setMiddleContentView:buttonCapture];
    [bottomContainerView setRightContentView:buttonSelect];
    
    if (error == nil)
    {
        if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeVideo])
        {
            NSURL *mediaURL = [info objectForKey:IQMediaURL];

            NSString *nextMediaPath = [[[self class] storagePath] stringByAppendingFormat:@"/%lu.mov",(unsigned long)counter++];

            [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
            
            [mediaURLs addObject:[IQFileManager URLForFilePath:nextMediaPath]];

            NSArray *durations = [IQFileManager durationsOfFilesAtPath:[[self class] storagePath]];
            
            [partitionBar setPartitions:durations animated:NO];
        }
        else if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeImage])
        {
            capturedImage = [info objectForKey:IQMediaImage];
        }
//        else if ([[info objectForKey:IQCaptureMediaType] isEqualToString:IQCaptureMediaTypeAudio])
//        {
//            
//        }
    }
    else
    {
    }
}

#pragma mark - IQPartitionBar Delegate
-(void)partitionBar:(IQPartitionBar*)bar didSelectPartitionIndex:(NSUInteger)index
{
    if (index != -1 && bar.partitions.count >0)
    {
        [bottomContainerView setLeftContentView:buttonDelete];
    }
    else
    {
        [bottomContainerView setLeftContentView:buttonCancel];
    }
}


@end
