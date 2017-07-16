//
//  IQCaptureSession.m
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


#import "IQCaptureSession.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "IQFileManager.h"
#import "IQAudioSession.h"
#import "IQMediaPickerControllerConstants.h"
#import "IQNSArray+Remove.h"


@interface IQCaptureSession ()<AVCaptureFileOutputRecordingDelegate,IQAudioSessionDelegate>

@property IQMediaCaptureControllerCaptureMode internalCaptureMode;

//Input
@property(nonatomic, readonly) AVCaptureDeviceInput *videoFrontCaptureDeviceInput;
@property(nonatomic, readonly) AVCaptureDeviceInput *videoBackCaptureDeviceInput;
@property(nonatomic, readonly) AVCaptureDeviceInput *videoCaptureDeviceInput;

@property(nonatomic, readonly) AVCaptureDeviceInput *audioCaptureDeviceInput;

//Output
@property(nonatomic, readonly) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, readonly) AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic, readonly) IQAudioSession *audioSession;

@end

@implementation IQCaptureSession

@synthesize captureSession = _captureSession;
@synthesize internalCaptureMode = _internalCaptureMode;
@synthesize videoFrontCaptureDeviceInput = _videoFrontCaptureDeviceInput;
@synthesize videoBackCaptureDeviceInput = _videoBackCaptureDeviceInput;
@synthesize captureSessionPreset = _captureSessionPreset;

-(id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

#pragma mark - Override

-(AVCaptureSession *)captureSession
{
    if (_captureSession == nil)
    {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    
    return _captureSession;
}

-(IQCaptureSessionPreset)captureSessionPreset
{
    return _captureSessionPreset;
}

-(NSArray<NSNumber *> *)supportedSessionPreset
{
    NSMutableArray *supportedSessionPreset = [[NSMutableArray alloc] init];
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetPhoto)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetHigh)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetMedium)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetLow)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset352x288])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPreset352x288)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPreset640x480)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPreset1280x720)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPreset1920x1080)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPreset3840x2160)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame960x540])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetiFrame960x540)];
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720])
    {
        [supportedSessionPreset addObject:@(IQCaptureSessionPresetiFrame1280x720)];
    }
    
    return supportedSessionPreset;
}

-(void)setCaptureSessionPreset:(IQCaptureSessionPreset)captureSessionPreset
{
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];

    switch (captureSessionPreset)
    {
        case IQCaptureSessionPresetPhoto:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPresetHigh:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPresetMedium:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPresetLow:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPreset352x288:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset352x288])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPreset352x288;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPreset640x480:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPreset1280x720:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPreset1920x1080:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPreset3840x2160:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPresetiFrame960x540:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame960x540])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
        case IQCaptureSessionPresetiFrame1280x720:
            if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720])
            {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
                _captureSessionPreset = captureSessionPreset;
            }
            break;
    }
    [CATransaction commit];
    
    if ([self.delegate respondsToSelector:@selector(captureSessionDidUpdateSessionPreset:)])
    {
        [self.delegate captureSessionDidUpdateSessionPreset:self];
    }
}

-(CGSize)presetSize
{
    AVCaptureDeviceFormat *activeFormat = [[_videoCaptureDeviceInput device] activeFormat];
    
    CGSize presetSize = CGSizeMake(activeFormat.highResolutionStillImageDimensions.width, activeFormat.highResolutionStillImageDimensions.height);
    if (presetSize.width > presetSize.height)
    {
        presetSize = CGSizeMake(presetSize.height, presetSize.width);
    }
    
    return presetSize;
}

#pragma mark - Class methods

+(AVCaptureDevice*)captureDeviceForPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            return device;
        }
    }
    
    return nil;
}

+ (NSArray<AVCaptureDevice*>*)supportedVideoCaptureDevices
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
}

+(AVCaptureDevice*)defaultAudioDevice
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    return device;
}

+(NSURL*)defaultVideoRecordingURL
{
    return [NSURL fileURLWithPath:[[IQFileManager IQTemporaryDirectory] stringByAppendingString:@"video.mov"]];
}

+(NSURL*)defaultImageStorageURL
{
    return [NSURL fileURLWithPath:[[IQFileManager IQTemporaryDirectory] stringByAppendingString:@"image.jpg"]];
}

#pragma mark - Methods

-(BOOL)addNewInputs:(NSArray*)newInputs
{
    AVCaptureSession *session = self.captureSession;

    NSArray *oldInputs = [session inputs];
    
    NSArray *inputsToRemove = [oldInputs iq_arrayByRemovingObjectsInArray:newInputs];
    NSArray *inputsToAdd = [newInputs iq_arrayByRemovingObjectsInArray:oldInputs];
    
    if (inputsToRemove.count || inputsToAdd.count)
    {
        BOOL success = NO;
        
        //Begin configuration
        [session beginConfiguration];
        
        //Remove all old inputs
        for (AVCaptureInput *input in inputsToRemove)
        {
            [session removeInput:input];
        }
        
        for (AVCaptureInput *input in inputsToAdd)
        {
            if ( [session canAddInput:input])
            {
                //Add new output
                [session addInput:input];
                
                if (success == NO)
                {
                    success = YES;
                }
            }
        }
        
        if (success == NO)
        {
            //        NSLog(@"Can't add inputs: %@",newInputs);
            
            //Restoring inputs
            for (AVCaptureInput *input in oldInputs)
            {
                [session addInput:input];
            }
        }
        
        //End configuration
        [session commitConfiguration];
        
        return success;
    }
    else
    {
        return YES;
    }
}

-(BOOL)addNewOutputs:(NSArray*)newOutputs
{
    AVCaptureSession *session = self.captureSession;
    
    NSArray<AVCaptureOutput*> *oldOutputs = [session outputs];

    NSArray *outputsToRemove = [oldOutputs iq_arrayByRemovingObjectsInArray:newOutputs];
    NSArray *outputsToAdd = [newOutputs iq_arrayByRemovingObjectsInArray:oldOutputs];
    
    if (outputsToRemove.count || outputsToAdd.count)
    {
        BOOL success = NO;
        
        //Begin configuration
        [session beginConfiguration];
        
        //Remove all old outputs
        for (AVCaptureOutput *output in outputsToRemove)
        {
            [session removeOutput:output];
        }
        
        for (AVCaptureOutput *output in outputsToAdd)
        {
            if ( [session canAddOutput:output])
            {
                //Add new output
                [session addOutput:output];
                
                if (success == NO)
                {
                    success = YES;
                }
            }
        }
        
        if ( success == NO)
        {
            //Restoring outputs
            for (AVCaptureOutput *output in oldOutputs)
            {
                [session addOutput:output];
            }
        }
        
        //End configuration
        [session commitConfiguration];
        
        return success;
    }
    else
    {
        return YES;
    }
}

- (BOOL) hasMultipleCameras
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

- (BOOL) hasFlash
{
    return _videoCaptureDeviceInput.device.hasFlash;
}

- (BOOL) hasTorch
{
    return _videoCaptureDeviceInput.device.hasTorch;
}

- (BOOL) hasFocus
{
    return
    [self isFocusModeSupported:AVCaptureFocusModeLocked] ||
    [self isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
    [self isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (BOOL) hasExposure
{
    return
    [self isExposureModeSupported:AVCaptureExposureModeLocked] ||
    [self isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
    [self isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (BOOL) hasWhiteBalance
{
    return
    [self isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
    [self isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance] ||
    [self isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
}

- (BOOL) isFocusPointSupported
{
    return [_videoCaptureDeviceInput.device isFocusPointOfInterestSupported];
}

- (BOOL) isExposurePointSupported
{
    return [_videoCaptureDeviceInput.device isExposurePointOfInterestSupported];
}

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode
{
    return [_videoCaptureDeviceInput.device isFlashModeSupported:flashMode];
}

- (BOOL)isTorchModeSupported:(AVCaptureTorchMode)torchMode;
{
    return [_videoCaptureDeviceInput.device isTorchModeSupported:torchMode];
}

- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)focusMode
{
    return [_videoCaptureDeviceInput.device isFocusModeSupported:focusMode];
}

-(BOOL)isExposureModeSupported:(AVCaptureExposureMode)exposureMode
{
    return [_videoCaptureDeviceInput.device isExposureModeSupported:exposureMode];
}

- (BOOL)isWhiteBalanceModeSupported:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    return [_videoCaptureDeviceInput.device isWhiteBalanceModeSupported:whiteBalanceMode];
}

-(IQMediaCaptureControllerCaptureMode)captureMode
{
    return _internalCaptureMode;
}

-(AVCaptureDevicePosition)cameraPosition
{
    return [_videoCaptureDeviceInput.device position];
}

-(AVCaptureFlashMode)flashMode
{
    return _videoCaptureDeviceInput.device.flashMode;
}

-(AVCaptureTorchMode)torchMode;
{
    return _videoCaptureDeviceInput.device.torchMode;
}

-(AVCaptureFocusMode)focusMode;
{
    return _videoCaptureDeviceInput.device.focusMode;
}

-(AVCaptureExposureMode)exposureMode;
{
    return _videoCaptureDeviceInput.device.exposureMode;
}

-(AVCaptureWhiteBalanceMode)whiteBalanceMode;
{
    return _videoCaptureDeviceInput.device.whiteBalanceMode;
}

-(CGPoint)focusPoint
{
    return _videoCaptureDeviceInput.device.focusPointOfInterest;
}

-(CGPoint)exposurePoint
{
    return _videoCaptureDeviceInput.device.exposurePointOfInterest;
}

-(BOOL)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode
{
    BOOL isSessionRunning = [self isSessionRunning];

    if (captureMode == IQMediaCaptureControllerCaptureModePhoto)
    {
        if (_stillImageOutput == nil)
        {
            _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];

            //        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
            //                                       AVVideoCodecH264, AVVideoCodecKey,
            //                                       [NSNumber numberWithInt:320], AVVideoWidthKey,
            //                                       [NSNumber numberWithInt:480], AVVideoHeightKey,
            //                                       AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
            //                                       nil];
            
            //        [_stillImageOutput setOutputSettings:videoSettings];
        }
        
        NSMutableArray *outputs = [[NSMutableArray alloc] init];
        if (_movieFileOutput)   [outputs addObject:_movieFileOutput];
        if (_stillImageOutput)  [outputs addObject:_stillImageOutput];
        
        BOOL success = [self addNewOutputs:outputs];
        
        if (success)
        {
            if (_audioSession.isRunning)
            {
                [_audioSession stopRunning];
            }

            if (isSessionRunning &&_captureSession.isRunning == NO)
            {
                [_captureSession startRunning];
            }

            _internalCaptureMode = captureMode;
        }
        
        return success;
    }
    else if (captureMode == IQMediaCaptureControllerCaptureModeVideo)
    {
        if (_movieFileOutput == nil)
        {
            _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        }
        
        NSMutableArray *outputs = [[NSMutableArray alloc] init];
        if (_movieFileOutput)   [outputs addObject:_movieFileOutput];
        if (_stillImageOutput)  [outputs addObject:_stillImageOutput];
        
        BOOL success = [self addNewOutputs:outputs];
        
        if (success)
        {
            if (_audioSession.isRunning)
            {
                [_audioSession stopRunning];
            }

            if (isSessionRunning &&_captureSession.isRunning == NO)
            {
                [_captureSession startRunning];
            }

            _internalCaptureMode = captureMode;
        }
        
        return success;
    }
    else if (captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        _audioSession = [[IQAudioSession alloc] init];
        _audioSession.delegate = self;

        [self addNewOutputs:@[]];

        if (isSessionRunning)
        {
            [_captureSession stopRunning];
            [_audioSession startRunning];
        }

        _internalCaptureMode = captureMode;
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    //Add new input
    {
        AVCaptureDeviceInput *videoInput = nil;
        
        switch (cameraPosition) {
            case AVCaptureDevicePositionFront:
            {
                videoInput = [self videoFrontCaptureDeviceInput];
            }
                break;
            case AVCaptureDevicePositionBack:
            case AVCaptureDevicePositionUnspecified:
            default:
            {
                videoInput = [self videoBackCaptureDeviceInput];
            }
                break;
        }

        _videoCaptureDeviceInput = videoInput;
        
        NSError *error;
        
        AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[[self class] defaultAudioDevice] error:&error];
        
        [self setCaptureSessionPreset:IQCaptureSessionPresetHigh];
        BOOL success = [self addNewInputs:[NSArray arrayWithObjects:videoInput,audioInput, nil]];
        
        if (success)
        {
            _videoCaptureDeviceInput = videoInput;
            _audioCaptureDeviceInput = audioInput;
        }
        
        return success;
    }
}

-(AVCaptureDeviceInput *)videoFrontCaptureDeviceInput
{
    if (_videoFrontCaptureDeviceInput == nil)
    {
        NSError *error;
        AVCaptureDevice *captureDevice = [[self class] captureDeviceForPosition:AVCaptureDevicePositionFront];
        _videoFrontCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    }
    
    return _videoFrontCaptureDeviceInput;
}

-(AVCaptureDeviceInput *)videoBackCaptureDeviceInput
{
    if (_videoBackCaptureDeviceInput == nil)
    {
        NSError *error;
        AVCaptureDevice *captureDevice = [[self class] captureDeviceForPosition:AVCaptureDevicePositionBack];
        _videoBackCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    }
    
    return _videoBackCaptureDeviceInput;
}

-(BOOL)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if ( [device isFlashModeSupported:flashMode])
    {
        NSError *error;
        if (device.flashMode != flashMode && [device lockForConfiguration:&error])
        {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
//            NSLog(@"Can't set flash mode:%@",error);

            return NO;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;

    if ( [device isTorchModeSupported:torchMode])
    {
        NSError *error;
        if (device.torchMode != torchMode && [device lockForConfiguration:&error] )
        {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
//            NSLog(@"Can't set torch mode:%@",error);
            
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if ( [device isFocusModeSupported:focusMode])
    {
        NSError *error;
        if (device.focusMode != focusMode && [device lockForConfiguration:&error] )
        {
            device.focusMode = focusMode;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
//            NSLog(@"Can't set focus mode:%@",error);
            
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if (device.exposureMode != exposureMode && [device isExposureModeSupported:exposureMode])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            device.exposureMode = exposureMode;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
//        NSLog(@"Exposure Mode not supported: %ld",(long)exposureMode);
        return NO;
    }
}

-(BOOL)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if ([device isWhiteBalanceModeSupported:whiteBalanceMode])
    {
        NSError *error;
        if ([device lockForConfiguration:&error] )
        {
            device.whiteBalanceMode = whiteBalanceMode;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
           return NO;
        }
    }
    else
    {
//        NSLog(@"White Balance not supported: %ld",(long)whiteBalanceMode);
        return NO;
    }
}

- (BOOL)setFocusPoint:(CGPoint)focusPoint
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if ([device isFocusPointOfInterestSupported])
    {
        NSError *error;
        if (device.focusMode == AVCaptureFocusModeAutoFocus && [device lockForConfiguration:&error] )
        {
            device.focusPointOfInterest = focusPoint;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
//        NSLog(@"Focus adjustment not supported");
        return NO;
    }
}

- (BOOL)setExposurePoint:(CGPoint)exposurePoint
{
    AVCaptureDevice *device = _videoCaptureDeviceInput.device;
    
    if ( device.isExposurePointOfInterestSupported)
    {
        NSError *error;
        if (device.exposureMode == AVCaptureExposureModeContinuousAutoExposure && [device lockForConfiguration:&error] )
        {
            device.exposurePointOfInterest = exposurePoint;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
//        NSLog(@"Exposure adjustment not supported");
        return NO;
    }
}

-(BOOL)isSessionRunning
{
    if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        return [_audioSession isRunning];
    }
    else
    {
        return [_captureSession isRunning];
    }
}

-(void)startRunning
{
    if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        [_audioSession startRunning];
    }
    else
    {
        [_captureSession startRunning];
    }
}

-(void)stopRunning
{
    [_audioSession stopRunning];
    [_captureSession stopRunning];
}

#pragma mark - Photo Capture
- (void)takePicture
{
    AVCaptureConnection *connection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection == nil)
    {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:[NSDictionary dictionaryWithObject:@"Can't take picture" forKey:NSLocalizedDescriptionKey]];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
    else if (_stillImageOutput.capturingStillImage)
    {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:[NSDictionary dictionaryWithObject:@"Taking picture is in progress" forKey:NSLocalizedDescriptionKey]];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
    else
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        switch (orientation)
        {
            case UIDeviceOrientationLandscapeLeft:
                connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }

        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if ( imageDataSampleBuffer != NULL )
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                NSURL *outputImageURL = [[self class] defaultImageStorageURL];
                
                [imageData writeToURL:outputImageURL.filePathURL atomically:YES];
                
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:outputImageURL,IQMediaURL,image,IQMediaImage,IQMediaTypeImage,IQMediaType, nil];

                if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
                {
                    [self.delegate captureSession:self didFinishMediaWithInfo:dict error:nil];
                }
                
                //            CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                //            NSDictionary *meta = (__bridge NSDictionary *)(metadata);
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
                {
                    [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
                }
            }
        }];
    }
}

#pragma mark - Recording

-(BOOL)isRecording
{
    if (self.captureMode == IQMediaCaptureControllerCaptureModeVideo)
    {
        return _movieFileOutput.isRecording;
    }
    else if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        return _audioSession.isRecording;
    }
    else
    {
        return NO;
    }
}

- (CGFloat)recordingDuration
{
    if (self.captureMode == IQMediaCaptureControllerCaptureModeVideo)
    {
        CMTime time = [_movieFileOutput recordedDuration];
        
        if (CMTIME_IS_INVALID(time))
        {
            return 0;
        }
        else
        {
            return CMTimeGetSeconds([_movieFileOutput recordedDuration]);
        }
    }
    else if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        return [_audioSession recordingDuration];
    }
    else
    {
        return 0;
    }
}

-(long long)recordingSize
{
    if (self.captureMode == IQMediaCaptureControllerCaptureModeVideo)
    {
        return [_movieFileOutput recordedFileSize];
    }
    else if (self.captureMode == IQMediaCaptureControllerCaptureModeAudio)
    {
        return [_audioSession recordingSize];
    }
    else
    {
        return 0;
    }
}

#pragma mark - Video recording

- (void)startVideoRecordingWithMaximumDuration:(NSTimeInterval)videoMaximumDuration
{
    AVCaptureConnection *connection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

    if (connection == nil)
    {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:[NSDictionary dictionaryWithObject:@"Can't record video" forKey:NSLocalizedDescriptionKey]];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
    else
    {
        NSURL *fileURL = [[self class] defaultVideoRecordingURL];
        
        [IQFileManager removeItemAtPath:fileURL.relativePath];

        {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            
            switch (orientation)
            {
                case UIDeviceOrientationLandscapeLeft:
                    connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    break;
                case UIDeviceOrientationLandscapeRight:
                    connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                    break;
                default:
                    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                    break;
            }
        }
        
        _movieFileOutput.maxRecordedDuration = (videoMaximumDuration > 0) ? CMTimeMake(videoMaximumDuration, 1) : kCMTimeInvalid;

        [_movieFileOutput stopRecording];
        [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
    }
}

-(void)stopVideoRecording
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidPauseRecording:)])
    {
        [self.delegate captureSessionDidPauseRecording:self];
    }

    [_movieFileOutput stopRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidStartRecording:)])
    {
        [self.delegate captureSessionDidStartRecording:self];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidPauseRecording:)])
    {
        [self.delegate captureSessionDidPauseRecording:self];
    }
    
    if (error.code == AVErrorMaximumDurationReached || error.code == AVErrorMaximumFileSizeReached)
    {
        error = nil;
    }

    if (error)
    {
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
    else
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:outputFileURL,IQMediaURL,IQMediaTypeVideo,IQMediaType, nil];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:dict error:nil];
        }
    }
}

#pragma mark - Audio recording

- (void)startAudioRecordingWithMaximumDuration:(NSTimeInterval)audioMaximumDuration
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidStartRecording:)])
    {
        [self.delegate captureSessionDidStartRecording:self];
    }

    [_audioSession startAudioRecordingWithMaximumDuration:audioMaximumDuration];
}

- (void)stopAudioRecording
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidPauseRecording:)])
    {
        [self.delegate captureSessionDidPauseRecording:self];
    }
    
    [_audioSession stopAudioRecording];
}

- (void)audioSession:(IQAudioSession*)audioSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(captureSessionDidPauseRecording:)])
    {
        [self.delegate captureSessionDidPauseRecording:self];
    }

    if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
    {
        [self.delegate captureSession:self didFinishMediaWithInfo:info error:error];
    }
}

-(void)audioSession:(IQAudioSession *)audioSession didUpdateMeterLevel:(CGFloat)meterLevel
{
    if ([self.delegate respondsToSelector:@selector(captureSession:didUpdateMeterLevel:)])
    {
        [self.delegate captureSession:self didUpdateMeterLevel:meterLevel];
    }
}

-(void)dealloc
{
    //Remove all inputs and outputs
    {
        //Begin configuration
        [_captureSession beginConfiguration];

        NSArray *outputs = [_captureSession outputs];
        for (AVCaptureOutput *output in outputs)
        {
            [_captureSession removeOutput:output];
        }

        NSArray *inputs = [_captureSession inputs];
        for (AVCaptureInput *input in inputs)
        {
            [_captureSession removeInput:input];
        }

        //End configuration
        [_captureSession commitConfiguration];
    }
    
    [self stopRunning];

    _captureSession = nil;
    _videoCaptureDeviceInput = nil;
    _audioCaptureDeviceInput = nil;
    _stillImageOutput = nil;
    _movieFileOutput = nil;
    _audioSession = nil;
}

@end
