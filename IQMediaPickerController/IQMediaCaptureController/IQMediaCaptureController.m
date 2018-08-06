//
//  IQMediaCaptureController.m
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


#import "IQMediaCaptureController.h"
#import "IQMediaView.h"
#import "IQCaptureSession.h"
#import "IQFileManager.h"
#import "IQAKPickerView.h"
#import "IQBottomContainerView.h"
#import "DBCameraButton.h"
#import "IQSettingsContainerView.h"
#import "IQSelectedMediaViewController.h"

@interface IQMediaCaptureController ()<IQCaptureSessionDelegate,IQAKPickerViewDelegate,IQAKPickerViewDataSource,IQMediaViewDelegate,IQVideoSettingsContainerViewDelegate,IQPhotoSettingsContainerViewDelegate,IQAudioSettingsContainerViewDelegate>
{
    
    CADisplayLink *displayDuratioUpdate;
    
    NSMutableArray<NSURL*> *videoURLs;
    NSMutableArray<NSURL*> *audioURLs;
    NSMutableArray<UIImage*> *arrayImages;
    
    BOOL isFirstTimeAppearing;
    BOOL _wasIdleTimerDisabled;
}

@property(nonatomic, readonly) NSArray<NSNumber*> *supportedCaptureModeForSession;
@property(nonatomic, readonly) NSArray<AVCaptureSessionPreset> *allowedQualityForSession;

@property(nonatomic, readonly) IQMediaView *mediaView;

@property(nonatomic, readonly) IQSettingsContainerView *settingsContainerView;

@property(nonatomic, readonly) IQBottomContainerView *bottomContainerView;

@property(nonatomic, readonly) IQAKPickerView *mediaTypePickerView;

@property(nonatomic, readonly) UIButton *buttonCancel, *buttonSelect;
@property(nonatomic, readonly) DBCameraButton *buttonCapture;

@property(nonatomic, readonly) IQCaptureSession *session;

@end

@implementation IQMediaCaptureController
@synthesize session = _session;
@synthesize mediaView = _mediaView;

@synthesize settingsContainerView = _settingsContainerView;
@synthesize mediaTypePickerView = _mediaTypePickerView, buttonCancel = _buttonCancel, buttonCapture = _buttonCapture;

@synthesize bottomContainerView = _bottomContainerView;
@synthesize buttonSelect = _buttonSelect;

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
    if ([[self session] isSessionRunning])
    {
        [[self session] stopRunning];
    }
    _session = nil;
    _mediaView = nil;
    _mediaTypePickerView = nil;
    _settingsContainerView = nil;

    _bottomContainerView = nil;
    _mediaTypePickerView = nil;
    _buttonCancel = nil;
    _buttonSelect = nil;
    _buttonCapture = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        videoURLs = [[NSMutableArray alloc] init];
        audioURLs = [[NSMutableArray alloc] init];
        arrayImages = [[NSMutableArray alloc] init];
        self.buttonSelect.hidden = YES;
    }
    return self;
}

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstTimeAppearing = YES;
    
    [self.view addSubview:self.mediaView];
    [self.view addSubview:self.settingsContainerView];

    [self.view addSubview:self.bottomContainerView];
    [self.bottomContainerView setTopContentView:self.mediaTypePickerView];
    [self.bottomContainerView setLeftContentView:self.buttonCancel];
    [self.bottomContainerView setMiddleContentView:self.buttonCapture];
    [self.bottomContainerView setRightContentView:self.buttonSelect];

    //Constraints
    {
        self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
        self.settingsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *views = @{@"bottomContainerView":self.bottomContainerView,@"mediaView":self.mediaView,@"settingsContainerView":self.settingsContainerView};
        
        NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[settingsContainerView]|" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[settingsContainerView]" options:0 metrics:nil views:views]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mediaView]|" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mediaView]|" options:0 metrics:nil views:views]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomContainerView]|" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomContainerView]|" options:0 metrics:nil views:views]];

        [self.view addConstraints:constraints];
    }
    
    [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
    [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];

    self.settingsContainerView.photoSettingsView.photoPreset = AVCaptureSessionPresetPhoto;
    self.settingsContainerView.videoSettingsView.videoPreset = AVCaptureSessionPreset1280x720;

    _supportedCaptureModeForSession = [self.mediaTypes copy];
    _allowedQualityForSession = [self.allowedVideoQualities copy];

    _captureMode = [[self.supportedCaptureModeForSession firstObject] integerValue];

    switch (_captureMode)
    {
        case PHAssetMediaTypeImage:
        {
            [self session].captureSessionPreset = self.settingsContainerView.photoSettingsView.photoPreset;
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            [self session].captureSessionPreset = self.settingsContainerView.videoSettingsView.videoPreset;
        }
            break;
        default:
            break;
    }

    [self updateUI];
}

-(void)setMediaTypes:(NSArray<NSNumber *> *)mediaTypes
{
    _mediaTypes = [[NSMutableOrderedSet orderedSetWithArray:mediaTypes] array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;
    self.buttonSelect.hidden = count == 0;
    if (count)
    {
        [self.buttonSelect setTitle:[NSString stringWithFormat:@"%ld Selected",(unsigned long)count] forState:UIControlStateNormal];
    }
    else
    {
        [self.buttonSelect setTitle:[NSString stringWithFormat:@"Select"] forState:UIControlStateNormal];
    }
    
    [self session].delegate = self;

    if (isFirstTimeAppearing)
    {
        isFirstTimeAppearing = NO;
        
        [self setCaptureMode:self.captureMode animated:NO];
        
        switch (self.captureMode)
        {
            case PHAssetMediaTypeImage:
            {
                [self setCaptureDevice:self.captureDevice animated:NO];

                if ([[self session] isFlashModeSupported:self.flashMode])
                {
                    AVCaptureTorchMode torchMode = AVCaptureTorchModeAuto;
                    
                    switch (self.flashMode) {
                        case AVCaptureFlashModeOff: torchMode = AVCaptureTorchModeOff;  break;
                        case AVCaptureFlashModeOn:  torchMode = AVCaptureTorchModeOn;   break;
                        case AVCaptureFlashModeAuto:torchMode = AVCaptureTorchModeAuto; break;
                    }
                    
                    [[self session] setFlashMode:self.flashMode];
                    self.settingsContainerView.photoSettingsView.flashMode = self.flashMode;
                    self.settingsContainerView.videoSettingsView.torchMode = torchMode;
                }
            }
                break;
            case PHAssetMediaTypeVideo:
            {
                [self setCaptureDevice:self.captureDevice animated:NO];
                
                AVCaptureTorchMode torchMode = AVCaptureTorchModeAuto;
                
                switch (self.flashMode) {
                    case AVCaptureFlashModeOff: torchMode = AVCaptureTorchModeOff;  break;
                    case AVCaptureFlashModeOn:  torchMode = AVCaptureTorchModeOn;   break;
                    case AVCaptureFlashModeAuto:torchMode = AVCaptureTorchModeAuto; break;
                }

                if ([[self session] isTorchModeSupported:torchMode])
                {
                    [[self session] setTorchMode:torchMode];
                    self.settingsContainerView.photoSettingsView.flashMode = self.flashMode;
                    self.settingsContainerView.videoSettingsView.torchMode = torchMode;
                }
            }
                break;
            case PHAssetMediaTypeAudio:
            {
                
            }
                break;
                
            default:
                break;
        }
        
        self.mediaView.previewSession = [self session].captureSession;
    }

    if ([[self session] isSessionRunning] == NO)
    {
        [[self session] startRunning];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _session.delegate = nil;
    
    if ([[self session] isSessionRunning])
    {
        [[self session] stopRunning];
    }
    
    [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [displayDuratioUpdate invalidate];
    displayDuratioUpdate = nil;
    self.settingsContainerView.audioSettingsView.duration = self.settingsContainerView.videoSettingsView.duration = 0;
    self.settingsContainerView.audioSettingsView.fileSize = self.settingsContainerView.videoSettingsView.fileSize = 0;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - UI handling

-(void)updateUI
{
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        switch (self.captureMode)
        {
            case PHAssetMediaTypeImage:
            {
                self.settingsContainerView.photoSettingsView.hasFlash = self.session.hasFlash;
                self.settingsContainerView.photoSettingsView.flashMode = self.session.flashMode;
                self.settingsContainerView.photoSettingsView.hasCamera = ([[IQCaptureSession supportedVideoCaptureDevices] count]>1);
                self.settingsContainerView.photoSettingsView.photoPreset = self.session.captureSessionPreset;
            }
                break;
            case PHAssetMediaTypeVideo:
            {
                self.settingsContainerView.videoSettingsView.hasTorch = self.session.hasTorch;
                self.settingsContainerView.videoSettingsView.torchMode = self.session.torchMode;
                self.settingsContainerView.videoSettingsView.hasCamera = ([[IQCaptureSession supportedVideoCaptureDevices] count]>1);
                self.settingsContainerView.videoSettingsView.videoPreset = self.session.captureSessionPreset;
            }
                break;
            default:
                break;
        }
        
        
        //Focus
        {
//            [self.mediaView setFocusMode:[self session].focusMode];
//            [self.mediaView setFocusPointOfInterest:[self session].focusPoint];
            [self.mediaView setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }

        //Exposure
        {
//            [self.mediaView setExposureMode:[self session].exposureMode];
//            [self.mediaView setExposurePointOfInterest:[self session].exposurePoint];
            [self.mediaView setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        {
            switch (self.captureMode)
            {
                default:
                case PHAssetMediaTypeImage:
                {
                    self.buttonCapture.circleColor = [UIColor whiteColor];
                    self.buttonCapture.squareColor = [UIColor whiteColor];
                }
                    break;
                case PHAssetMediaTypeVideo:
                {
                    self.buttonCapture.circleColor = [UIColor redColor];
                    self.buttonCapture.squareColor = [UIColor redColor];
                }
                    break;
                case PHAssetMediaTypeAudio:
                {
                    self.buttonCapture.circleColor = [UIColor cyanColor];
                    self.buttonCapture.squareColor = [UIColor cyanColor];
                }
                    break;
            }
            self.buttonCapture.enabled = YES;
            self.buttonCapture.isRecording = [[self session] isRecording];
        }
        
    } completion:^(BOOL finished) {
    }];
}

-(void)updateDuration
{
    if ([[self session] isRecording])
    {
        double duration = [[self session] recordingDuration];
        long long fileSize = [[self session] recordingSize];
        bool isInfinite = isinf(duration);
        if (isInfinite == false)
        {
            if (self.captureMode == PHAssetMediaTypeAudio)
            {
                self.settingsContainerView.audioSettingsView.duration = duration;
                self.settingsContainerView.audioSettingsView.fileSize = fileSize;
            }
            else if (self.captureMode == PHAssetMediaTypeVideo)
            {
                self.settingsContainerView.videoSettingsView.duration = duration;
                self.settingsContainerView.videoSettingsView.fileSize = fileSize;
            }
        }
    }
    else
    {
        [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [displayDuratioUpdate invalidate];
        displayDuratioUpdate = nil;
        self.settingsContainerView.audioSettingsView.duration = self.settingsContainerView.videoSettingsView.duration = 0;
        self.settingsContainerView.audioSettingsView.fileSize = self.settingsContainerView.videoSettingsView.fileSize = 0;
    }
}

#pragma mark - Camera Session Settings

-(void)setCaptureDevice:(AVCaptureDevicePosition)captureDevice
{
    [self setCaptureDevice:captureDevice animated:NO];
}

-(void)setCaptureMode:(PHAssetMediaType)captureMode animated:(BOOL)animated
{
    self.settingsContainerView.captureMode = captureMode;
    
    NSInteger index = [self.supportedCaptureModeForSession indexOfObject:@(captureMode)];
    
    if (index != NSNotFound)
    {
        [self.mediaTypePickerView selectItem:index animated:YES notifySelection:NO];
    }
    
    switch (self.captureMode)
    {
        default:
        case PHAssetMediaTypeImage:
        {
            self.buttonCapture.circleColor = [UIColor whiteColor];
            self.buttonCapture.squareColor = [UIColor whiteColor];
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            self.buttonCapture.circleColor = [UIColor redColor];
            self.buttonCapture.squareColor = [UIColor redColor];
        }
            break;
        case PHAssetMediaTypeAudio:
        {
            self.buttonCapture.circleColor = [UIColor cyanColor];
            self.buttonCapture.squareColor = [UIColor cyanColor];
        }
            break;
    }
    self.buttonCapture.enabled = YES;

    self.mediaTypePickerView.userInteractionEnabled = NO;
    
    __weak typeof(self) weakSelf = self;

    [self.mediaView setBlur:YES completion:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        BOOL success = [[strongSelf session] setCaptureMode:captureMode];
        
        if (success && strongSelf)
        {
            strongSelf->_captureMode = captureMode;
            [weakSelf.mediaView setCaptureMode:weakSelf.captureMode];
        }
        
        if (captureMode == PHAssetMediaTypeImage)
        {
            weakSelf.settingsContainerView.backgroundColor = [UIColor blackColor];
            weakSelf.bottomContainerView.backgroundColor = [UIColor blackColor];
        }
        else if (captureMode == PHAssetMediaTypeVideo)
        {
            weakSelf.settingsContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            weakSelf.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }
        else if (captureMode == PHAssetMediaTypeAudio)
        {
            weakSelf.settingsContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            weakSelf.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }
        
        [UIView animateWithDuration:((animated && success)?0.3:0) delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            weakSelf.settingsContainerView.captureMode = weakSelf.captureMode;
            
            PHAssetMediaType sessionCaptureMode = [weakSelf session].captureMode;
            
            NSInteger index = [weakSelf.supportedCaptureModeForSession indexOfObject:@(captureMode)];
            if (index != NSNotFound)
            {
                [weakSelf.mediaTypePickerView selectItem:index animated:YES notifySelection:NO];
            }
            
            if (sessionCaptureMode == PHAssetMediaTypeImage)
            {
                [weakSelf session].torchMode = AVCaptureTorchModeOff;
                [weakSelf session].flashMode = AVCaptureFlashModeOff;
                //                    [self session].flashMode = self.settingsContainerView.photoSettingsView.flashMode;
                [weakSelf session].captureSessionPreset = weakSelf.settingsContainerView.photoSettingsView.photoPreset;
            }
            else if (captureMode == PHAssetMediaTypeVideo)
            {
                [weakSelf session].torchMode = AVCaptureTorchModeOff;
                //                    [self session].torchMode = self.settingsContainerView.videoSettingsView.torchMode;
                [weakSelf session].flashMode = AVCaptureFlashModeOff;
                [weakSelf session].captureSessionPreset = weakSelf.settingsContainerView.videoSettingsView.videoPreset;
            }
            else if (captureMode == PHAssetMediaTypeAudio)
            {
                [weakSelf session].torchMode = AVCaptureTorchModeOff;
                [weakSelf session].flashMode = AVCaptureFlashModeOff;
            }
            
        } completion:^(BOOL finished) {
            [weakSelf updateUI];
            weakSelf.mediaTypePickerView.userInteractionEnabled = YES;
            [weakSelf.mediaView setBlur:NO completion:nil];
        }];
    }];
}

-(void)setCaptureMode:(PHAssetMediaType)captureMode
{
    [self setCaptureMode:captureMode animated:NO];
}

-(void)setCaptureDevice:(AVCaptureDevicePosition)captureDevice animated:(BOOL)animated
{
    if (_mediaView)
    {
        self.mediaTypePickerView.userInteractionEnabled = NO;
        
        __weak typeof(self) weakSelf = self;

        [self.mediaView setBlur:YES completion:^{
            
            __strong typeof(self) strongSelf = weakSelf;

            BOOL success = [[strongSelf session] setCameraPosition:captureDevice];

            if (success && strongSelf)
            {
                strongSelf->_captureDevice = captureDevice;
            }
            
            if (success)
            {
                NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] initWithArray:weakSelf.allowedQualityForSession];
                [set intersectSet:[NSSet setWithArray:[[weakSelf session] supportedSessionPreset]]];
                weakSelf.settingsContainerView.photoSettingsView.preferredPreset = weakSelf.settingsContainerView.videoSettingsView.preferredPreset = [set array];

                if (weakSelf.captureMode == PHAssetMediaTypeImage)
                {
                    [weakSelf session].captureSessionPreset = [weakSelf.settingsContainerView.photoSettingsView.supportedPreset firstObject];
                }
                else if (weakSelf.captureMode == PHAssetMediaTypeVideo)
                {
                    [weakSelf session].captureSessionPreset = [weakSelf.settingsContainerView.videoSettingsView.supportedPreset firstObject];
                }
                
                [UIView transitionWithView:weakSelf.mediaView duration:((animated && success)?0.5:0) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                    
                    [weakSelf updateUI];
                    
                } completion:^(BOOL finished) {
                    
                    [weakSelf.mediaView setBlur:NO completion:nil];
                    weakSelf.mediaTypePickerView.userInteractionEnabled = YES;
                }];
            }
            else
            {
                [weakSelf.mediaView setBlur:NO completion:nil];
            }
        }];
    }
    else
    {
        _captureDevice = captureDevice;
    }
}

- (void)toggleCameraAction:(UIButton *)sender
{
    [self flipCamera];
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

- (void)takePicture
{
    NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;
    
    if (self.maximumItemCount == 0 || self.maximumItemCount > count)
    {
        [self.bottomContainerView setLeftContentView:nil];
        [self.bottomContainerView setRightContentView:nil];
        
        [[self session] takePicture];
    }
}

- (BOOL)startVideoCapture
{
    if ([self session].isRecording == NO)
    {
        NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;

        if (self.maximumItemCount == 0 || self.maximumItemCount > count)
        {
            self.buttonCapture.isRecording = YES;
            [[self session] startVideoRecordingWithMaximumDuration:self.videoMaximumDuration];
            return YES;
        }
    }

    return NO;
}

- (void)stopVideoCapture
{
    if ([self session].isRecording == YES)
    {
        self.buttonCapture.isRecording = NO;
        [[self session] stopVideoRecording];
    }
}

- (BOOL)startAudioCapture
{
    if ([self session].isRecording == NO)
    {
        NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;
        
        if (self.maximumItemCount == 0 || self.maximumItemCount > count)
        {
            self.buttonCapture.isRecording = YES;
            [[self session] startAudioRecordingWithMaximumDuration:self.audioMaximumDuration];
            return YES;
        }
    }

    return NO;
}

- (void)stopAudioCapture
{
    if ([self session].isRecording == YES)
    {
        self.buttonCapture.isRecording = NO;
        [[self session] stopAudioRecording];
    }
}

- (void)captureAction:(UIButton *)sender
{
    if ([[self session] isSessionRunning] == NO)
    {
        switch (self.captureMode)
        {
            default:
            case PHAssetMediaTypeImage:
            {
                self.buttonCapture.circleColor = [UIColor whiteColor];
                self.buttonCapture.squareColor = [UIColor whiteColor];
            }
                break;
            case PHAssetMediaTypeVideo:
            {
                self.buttonCapture.circleColor = [UIColor redColor];
                self.buttonCapture.squareColor = [UIColor redColor];
            }
                break;
            case PHAssetMediaTypeAudio:
            {
                self.buttonCapture.circleColor = [UIColor cyanColor];
                self.buttonCapture.squareColor = [UIColor cyanColor];
            }
                break;
        }
        self.buttonCapture.enabled = YES;

        if ([[self session] isSessionRunning] == NO)
        {
            [[self session] startRunning];
        }
        
        //Resetting
        if (self.allowsCapturingMultipleItems == NO)
        {
            [videoURLs removeAllObjects];
            [audioURLs removeAllObjects];
            [arrayImages removeAllObjects];
            self.buttonSelect.hidden = YES;
            
            [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
            [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
            [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];
        }
    }
    else
    {
        if ([self session].captureMode == PHAssetMediaTypeImage)
        {
            [self takePicture];
        }
        else if ([self session].captureMode == PHAssetMediaTypeVideo)
        {
            if ([self session].isRecording == NO)
            {
                [self startVideoCapture];
            }
            else
            {
                [self stopVideoCapture];
            }
        }
        else if ([self session].captureMode == PHAssetMediaTypeAudio)
        {
            if ([self session].isRecording == NO)
            {
                [self startAudioCapture];
            }
            else
            {
                [self stopAudioCapture];
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
    IQSelectedMediaViewController *controller = [[IQSelectedMediaViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    controller.videoURLs = videoURLs;
    controller.audioURLs = audioURLs;
    controller.arrayImages = arrayImages;
    controller.mediaCaptureController = self;
    [self.navigationController pushViewController:controller animated:YES];
}

//- (void)deleteAction:(UIButton *)sender
//{
//    NSURL *mediaURL = [videoURLs objectAtIndex:self.partitionBar.selectedIndex];
//    
//    [videoURLs removeObject:mediaURL];
//    [IQFileManager removeItemAtPath:mediaURL.relativePath];
//    
//    [self.partitionBar removeSelectedPartition];
//    
//    if (self.partitionBar.partitions.count > 0)
//    {
//        [self.bottomContainerView setLeftContentView:self.buttonDelete];
//    }
//    else
//    {
//        [self.bottomContainerView setLeftContentView:self.buttonCancel];
//    }
//}

#pragma mark - IQMediaView Delegates

-(void)mediaView:(IQMediaView*)mediaView focusPointOfInterest:(CGPoint)focusPoint
{
    [[self session] setFocusPoint:focusPoint];
}

-(void)mediaView:(IQMediaView*)mediaView exposurePointOfInterest:(CGPoint)exposurePoint
{
    [[self session] setExposurePoint:exposurePoint];
}

-(void)mediaView:(IQMediaView *)mediaView swipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    NSInteger index = [self.supportedCaptureModeForSession indexOfObject:@(self.captureMode)];
    
    if (direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (index > 0)
        {
            [self setCaptureMode:[self.supportedCaptureModeForSession[index-1] integerValue] animated:YES];
        }
    }
    else if (direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if ((index+1) < self.supportedCaptureModeForSession.count)
        {
            [self setCaptureMode:[self.supportedCaptureModeForSession[index+1] integerValue] animated:YES];
        }
    }
}

#pragma mark - Settings Delegates

-(void)flipCamera
{
    if ([self session].cameraPosition == AVCaptureDevicePositionBack)
    {
        [self setCaptureDevice:AVCaptureDevicePositionFront animated:YES];
    }
    else
    {
        [self setCaptureDevice:AVCaptureDevicePositionBack animated:YES];
    }
}

-(void)photoSettingsViewFlippedCamera:(IQPhotoSettingsContainerView *)settingsView
{
    [self flipCamera];
}

-(void)videoSettingsViewFlippedCamera:(IQVideoSettingsContainerView *)settingsView
{
    [self flipCamera];
}

-(void)photoSettingsView:(IQPhotoSettingsContainerView *)settingsView didChangeFlashMode:(AVCaptureFlashMode)flashMode
{
    if ([[self session] isFlashModeSupported:flashMode])
        [[self session] setFlashMode:flashMode];
    
    [self updateUI];
}

-(void)videoSettingsView:(IQVideoSettingsContainerView *)settingsView didChangeTorchMode:(AVCaptureTorchMode)torchMode
{
    if ([[self session] isTorchModeSupported:torchMode])
        [[self session] setTorchMode:torchMode];
    
    [self updateUI];
}

-(void)videoSettingsView:(IQVideoSettingsContainerView *)settingsView didChangeVideoPreset:(AVCaptureSessionPreset)videoPreset
{
    __weak typeof(self) weakSelf = self;

    [self.mediaView setBlur:YES completion:^{

        [weakSelf session].captureSessionPreset = videoPreset;
        [weakSelf updateUI];
        [weakSelf.mediaView setBlur:NO completion:nil];

    }];
}

-(void)photoSettingsView:(IQVideoSettingsContainerView *)settingsView didChangePhotoPreset:(AVCaptureSessionPreset)photoPreset
{
    __weak typeof(self) weakSelf = self;

    [self.mediaView setBlur:YES completion:^{
        [weakSelf session].captureSessionPreset = photoPreset;
        
        [weakSelf updateUI];
        [weakSelf.mediaView setBlur:NO completion:nil];
    }];
}

#pragma mark - IQCaptureSession Delegates

-(void)captureSessionDidUpdateSessionPreset:(IQCaptureSession *)captureSession
{
    CGSize presetSize = captureSession.presetSize;
    
    if (presetSize.width != 0 && presetSize.height != 0)
    {
        CGSize sourceSize = presetSize;
        CGSize destSize = self.view.bounds.size;
        
        CGSize aspectFitSize = CGSizeMake(destSize.width, destSize.height);
        CGFloat mW = destSize.width / sourceSize.width;
        CGFloat mH = destSize.height / sourceSize.height;
        if( mH < mW )
            aspectFitSize.width = mH * sourceSize.width;
        else if( mW < mH )
            aspectFitSize.height = mW * sourceSize.height;

        aspectFitSize.width = floor(aspectFitSize.width);
        aspectFitSize.height = floor(aspectFitSize.height);
        
        CGFloat unusedHeight = destSize.height - aspectFitSize.height;

        if (unusedHeight > 0)
        {
            UIEdgeInsets previewInset = UIEdgeInsetsZero;
            if (unusedHeight >= 140)
            {
                previewInset.top = 40;
                previewInset.bottom = 100;
                unusedHeight -= 140;
                previewInset.top += unusedHeight/2;
                previewInset.bottom += unusedHeight/2;
            }
            else
            {
                previewInset.top = unusedHeight;
            }

            self.mediaView.previewInset = previewInset;
        }
        else
        {
            self.mediaView.previewInset = UIEdgeInsetsZero;
        }
    }
}

- (void)captureSession:(IQCaptureSession*)audioSession didUpdateMeterLevel:(CGFloat)meterLevel
{
    self.mediaView.meteringLevel = meterLevel;
}

-(void)captureSessionDidStartRecording:(IQCaptureSession *)captureSession
{
    _wasIdleTimerDisabled = [[UIApplication sharedApplication] isIdleTimerDisabled];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        switch (captureSession.captureMode)
        {
            case PHAssetMediaTypeVideo:
            {
                self.mediaView.recording = self.settingsContainerView.videoSettingsView.recording = YES;
            }
                break;
            case PHAssetMediaTypeAudio:
            {
                self.mediaView.recording = self.settingsContainerView.audioSettingsView.recording = YES;
            }
            default:
                break;
        }
    } completion:NULL];

    [self.bottomContainerView setLeftContentView:nil];
    [self.bottomContainerView setRightContentView:nil];
    [self.bottomContainerView setTopContentView:nil];
    
    self.bottomContainerView.backgroundColor = [UIColor clearColor];

    displayDuratioUpdate = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDuration)];
        [displayDuratioUpdate addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)captureSessionDidPauseRecording:(IQCaptureSession *)captureSession
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:_wasIdleTimerDisabled];

    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.buttonCapture.isRecording = NO;

        switch (captureSession.captureMode)
        {
            case PHAssetMediaTypeVideo:
            {
                self.mediaView.recording = self.settingsContainerView.videoSettingsView.recording = NO;
            }
                break;
            case PHAssetMediaTypeAudio:
            {
                self.mediaView.recording = self.settingsContainerView.audioSettingsView.recording = NO;
            }
            default:
                break;
        }

    } completion:NULL];

    [displayDuratioUpdate removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [displayDuratioUpdate invalidate];
    displayDuratioUpdate = nil;
    self.settingsContainerView.audioSettingsView.duration = self.settingsContainerView.videoSettingsView.duration = 0;
    self.settingsContainerView.audioSettingsView.fileSize = self.settingsContainerView.videoSettingsView.fileSize = 0;
}

-(void)captureSession:(IQCaptureSession*)captureSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError*)error
{
    //Resetting
    if (self.allowsCapturingMultipleItems == NO)
    {
        [videoURLs removeAllObjects];
        [audioURLs removeAllObjects];
        [arrayImages removeAllObjects];

        [IQFileManager removeItemsAtPath:[[self class] temporaryAudioStoragePath]];
        [IQFileManager removeItemsAtPath:[[self class] temporaryVideoStoragePath]];
        [IQFileManager removeItemsAtPath:[[self class] temporaryImageStoragePath]];
    }

    [self.bottomContainerView setLeftContentView:self.buttonCancel];
    [self.bottomContainerView setTopContentView:self.mediaTypePickerView];
    self.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.bottomContainerView setRightContentView:self.buttonSelect];
    
    NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;

    if (error == nil)
    {
        if (self.maximumItemCount == 0 || self.maximumItemCount > count)
        {
            if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeVideo])
            {
                NSURL *mediaURL = [info objectForKey:IQMediaURL];
                
                NSString *nextMediaPath = [[[self class] temporaryVideoStoragePath] stringByAppendingFormat:@"movie%lu.mov",(unsigned long)videoURLs.count];
                
                [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
                
                [videoURLs addObject:[IQFileManager URLForFilePath:nextMediaPath]];
            }
            else if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeImage])
            {
                UIImage *image = info[IQMediaImage];
                
                [arrayImages addObject:image];
            }
            else if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeAudio])
            {
                NSURL *mediaURL = [info objectForKey:IQMediaURL];
                
                NSString *nextMediaPath = [[[self class] temporaryAudioStoragePath] stringByAppendingFormat:@"audio%lu.m4a",(unsigned long)audioURLs.count];
                
                [IQFileManager copyItemAtPath:mediaURL.relativePath toPath:nextMediaPath];
                
                [audioURLs addObject:[IQFileManager URLForFilePath:nextMediaPath]];
            }
            
            if (self.allowsCapturingMultipleItems == NO)
            {
                IQSelectedMediaViewController *controller = [[IQSelectedMediaViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
                controller.videoURLs = videoURLs;
                controller.audioURLs = audioURLs;
                controller.arrayImages = arrayImages;
                controller.mediaCaptureController = self;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                NSUInteger count = videoURLs.count + audioURLs.count + arrayImages.count;
                self.buttonSelect.hidden = count == 0;
                if (count)
                {
                    [self.buttonSelect setTitle:[NSString stringWithFormat:@"%ld Selected",(unsigned long)count] forState:UIControlStateNormal];
                }
                else
                {
                    [self.buttonSelect setTitle:[NSString stringWithFormat:@"Select"] forState:UIControlStateNormal];
                }
            }
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - AKPickerViewDataSource

-(NSUInteger)numberOfItemsInPickerView:(IQAKPickerView *)pickerView
{
    return self.supportedCaptureModeForSession.count;
}

-(NSString *)pickerView:(IQAKPickerView *)pickerView titleForItem:(NSInteger)item
{
    PHAssetMediaType mode = [self.supportedCaptureModeForSession[item] integerValue];
    
    switch (mode)
    {
        case PHAssetMediaTypeImage:
        {
            return @"PHOTO";
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            return @"VIDEO";
        }
            break;
        case PHAssetMediaTypeAudio:
        {
            return @"AUDIO";
        }
            break;
            
        default:
            return @"";
            break;
    }
}

#pragma mark - AKPickerViewDelegate

- (void)pickerView:(IQAKPickerView *)pickerView didSelectItem:(NSInteger)item
{
    PHAssetMediaType selectedCaptureMode =  [self.supportedCaptureModeForSession[item] integerValue];
    
    if (self.captureMode != selectedCaptureMode)
    {
        [self setCaptureMode:selectedCaptureMode animated:YES];
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
        CGRect rect = self.view.bounds;
        _mediaView = [[IQMediaView alloc] initWithFrame:rect];
        _mediaView.delegate = self;
    }
    
    return _mediaView;
}

-(IQSettingsContainerView *)settingsContainerView
{
    if (_settingsContainerView == nil)
    {
        _settingsContainerView = [[IQSettingsContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _settingsContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _settingsContainerView.photoSettingsView.delegate = self;
        _settingsContainerView.videoSettingsView.delegate = self;
        _settingsContainerView.audioSettingsView.delegate = self;
    }
    
    return _settingsContainerView;
}

-(IQBottomContainerView *)bottomContainerView
{
    if (_bottomContainerView == nil)
    {
        CGFloat height = 100;
        _bottomContainerView = [[IQBottomContainerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-height, CGRectGetWidth(self.view.bounds), height)];
        _bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    }
    return _bottomContainerView;
}

-(IQAKPickerView *)mediaTypePickerView
{
    if (_mediaTypePickerView == nil)
    {
        _mediaTypePickerView = [[IQAKPickerView alloc] init];
        _mediaTypePickerView.delegate = self;
        _mediaTypePickerView.dataSource = self;
        _mediaTypePickerView.backgroundColor = [UIColor clearColor];
        _mediaTypePickerView.font = [UIFont boldSystemFontOfSize:12];
        _mediaTypePickerView.highlightedFont = [UIFont boldSystemFontOfSize:12];
        _mediaTypePickerView.textColor = [UIColor whiteColor];
        _mediaTypePickerView.highlightedTextColor = [UIColor yellowColor];
        _mediaTypePickerView.interitemSpacing = 30;
        _mediaTypePickerView.maskDisabled = NO;
    }
    
    return _mediaTypePickerView;
}

-(UIButton *)buttonCancel
{
    if (_buttonCancel == nil)
    {
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonCancel.tintColor = [UIColor whiteColor];
        [_buttonCancel.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
        [_buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_buttonCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonCancel;
}

-(DBCameraButton *)buttonCapture
{
    if (_buttonCapture == nil)
    {
        _buttonCapture = [[DBCameraButton alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        _buttonCapture.autoStateChange = NO;
        _buttonCapture.margin = 0;
        [_buttonCapture addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonCapture;
}

-(UIButton *)buttonSelect
{
    if (_buttonSelect == nil)
    {
        _buttonSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonSelect.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
        _buttonSelect.titleLabel.minimumScaleFactor = 0.5;
        _buttonSelect.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_buttonSelect setTitle:@"Select" forState:UIControlStateNormal];
        [_buttonSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonSelect addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _buttonSelect;
}

#pragma mark - Temporary path
+(NSString*)temporaryVideoStoragePath
{
    NSString *videoPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"IQVideo/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return videoPath;
}

+(NSString*)temporaryAudioStoragePath
{
    NSString *audioPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"IQAudio/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return audioPath;
}

+(NSString*)temporaryImageStoragePath
{
    NSString *audioPath = [[IQFileManager IQDocumentDirectory] stringByAppendingString:@"IQImage/"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioPath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:NO attributes:nil error:NULL];
    
    return audioPath;
}

#pragma mark - Orientation
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
