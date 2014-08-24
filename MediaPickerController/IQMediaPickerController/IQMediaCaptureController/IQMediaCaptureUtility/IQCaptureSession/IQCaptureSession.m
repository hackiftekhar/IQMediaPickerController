//
//  IQCaptureSession.m
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

#import "IQCaptureSession.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "IQFileManager.h"
#import "IQAudioSession.h"
#import "IQMediaPickerControllerConstants.h"



@interface IQCaptureSession ()<AVCaptureFileOutputRecordingDelegate,IQAudioSessionDelegate>

//Input
@property(nonatomic, strong, readonly) AVCaptureDeviceInput *videoCaptureDeviceInput;
@property(nonatomic, strong, readonly) AVCaptureDeviceInput *audioCaptureDeviceInput;

//Output
@property(nonatomic, strong, readonly) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong, readonly) AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic, strong, readonly) IQAudioSession *audioSession;

@end

@implementation IQCaptureSession

@synthesize captureSession = _captureSession;
//@synthesize captureSessionPreset = _captureSessionPreset;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        [self setCameraPosition:AVCaptureDevicePositionBack];
        [self setCaptureMode:IQCameraCaptureModePhoto];
    }
    
    return self;
}

#pragma mark - Override

-(AVCaptureSession *)captureSession
{
    if (_captureSession == nil)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
        {
            _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        }
    }
    
    return _captureSession;
}

//-(IQCaptureSessionPreset)captureSessionPreset
//{
//    return _captureSessionPreset;
//}
//
//-(void)setCaptureSessionPreset:(IQCaptureSessionPreset)captureSessionPreset
//{
//    _captureSessionPreset = captureSessionPreset;
//}


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

+ (NSArray*)supportedVideoCaptureDevices
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

    BOOL success = NO;
    
    //Begin configuration
    [session beginConfiguration];

    //Remove all old inputs
    NSArray *oldInputs = [session inputs];
    for (AVCaptureInput *input in oldInputs)
    {
        [session removeInput:input];
    }

    for (AVCaptureInput *input in newInputs)
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

-(BOOL)addNewOutputs:(NSArray*)newOutputs
{
    AVCaptureSession *session = self.captureSession;
    
    BOOL success = NO;

    //Begin configuration
    [session beginConfiguration];

    //Remove all old outputs
    NSArray *oldOutputs = [session outputs];
    for (AVCaptureOutput *output in oldOutputs)
    {
        [session removeOutput:output];

    }

    for (AVCaptureOutput *output in newOutputs)
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
//        NSLog(@"Can't add outputs: %@",newOutputs);
        
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

-(IQCameraCaptureMode)captureMode
{
    if (_stillImageOutput != nil)
    {
        return IQCameraCaptureModePhoto;
    }
    else if (_movieFileOutput != nil)
    {
        return IQCameraCaptureModeVideo;
    }
    else if (_audioSession != nil)
    {
        return IQCameraCaptureModeAudio;
    }
    else
    {
        return IQCameraCaptureModeUnspecified;
    }
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

-(BOOL)setCaptureMode:(IQCameraCaptureMode)captureMode
{
    BOOL isSessionRunning = [self isSessionRunning];

    if (captureMode == IQCameraCaptureModePhoto)
    {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        //        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
        //                                       AVVideoCodecH264, AVVideoCodecKey,
        //                                       [NSNumber numberWithInt:320], AVVideoWidthKey,
        //                                       [NSNumber numberWithInt:480], AVVideoHeightKey,
        //                                       AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
        //                                       nil];
        
        //        [_stillImageOutput setOutputSettings:videoSettings];
        
        BOOL success = [self addNewOutputs:[NSArray arrayWithObject:_stillImageOutput]];
        
        if (success)
        {
            if (isSessionRunning)
            {
                [_audioSession stopRunning];
                [_captureSession startRunning];
            }
            
            _audioSession = nil;
            _movieFileOutput = nil;
        }
        else
        {
            _stillImageOutput = nil;
        }
        
        return success;
    }
    else if (captureMode == IQCameraCaptureModeVideo)
    {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        BOOL success = [self addNewOutputs:[NSArray arrayWithObjects:_movieFileOutput,nil]];
        
        if (success)
        {
            if (isSessionRunning)
            {
                [_audioSession stopRunning];
                [_captureSession startRunning];
            }

            _audioSession = nil;
            _stillImageOutput = nil;
        }
        else
        {
            _movieFileOutput = nil;
        }
        
        return success;
    }
    else if (captureMode == IQCameraCaptureModeAudio)
    {
        _audioSession = [[IQAudioSession alloc] init];
        _audioSession.delegate = self;

        {
            _stillImageOutput = nil;
            _movieFileOutput = nil;
        }

        if (isSessionRunning)
        {
            [_captureSession stopRunning];
            [_audioSession startRunning];
        }

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
        AVCaptureDevice *captureDevice = [[self class] captureDeviceForPosition:cameraPosition];
        
        NSError *error;
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        
        AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[[self class] defaultAudioDevice] error:&error];
        
        BOOL success = [self addNewInputs:[NSArray arrayWithObjects:videoInput,audioInput, nil]];
        
        if (success)
        {
            _videoCaptureDeviceInput = videoInput;
            _audioCaptureDeviceInput = audioInput;
        }
        
        return success;
    }
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
    if (self.captureMode == IQCameraCaptureModeAudio)
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
    if (self.captureMode == IQCameraCaptureModeAudio)
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
//    if (self.captureMode == IQCameraCaptureModeAudio)
//    {
        [_audioSession stopRunning];
//    }
//    else
//    {
        [_captureSession stopRunning];
//    }
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
    else
    {
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
    if (self.captureMode == IQCameraCaptureModeVideo)
    {
        return _movieFileOutput.isRecording;
    }
    else if (self.captureMode == IQCameraCaptureModeAudio)
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
    if (self.captureMode == IQCameraCaptureModeVideo)
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
    else if (self.captureMode == IQCameraCaptureModeAudio)
    {
        return [_audioSession recordingDuration];
    }
    else
    {
        return 0;
    }
}

#pragma mark - Video recording

-(void)startVideoRecording
{
    AVCaptureConnection *connection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

    if (connection == nil)
    {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:[NSDictionary dictionaryWithObject:@"Can't take picture" forKey:NSLocalizedDescriptionKey]];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
    else
    {
        NSURL *fileURL = [[self class] defaultVideoRecordingURL];
        
        [IQFileManager removeItemAtPath:fileURL.relativePath];

        [_movieFileOutput stopRecording];
        [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
    }
}

-(void)stopVideoRecording
{
    [_movieFileOutput stopRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
//    NSLog(@"%@",fileURL);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
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

- (void)startAudioRecording
{
    [_audioSession startAudioRecording];
}

- (void)stopAudioRecording
{
    [_audioSession stopAudioRecording];
}

- (void)audioSession:(IQAudioSession*)audioSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError *)error
{
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
