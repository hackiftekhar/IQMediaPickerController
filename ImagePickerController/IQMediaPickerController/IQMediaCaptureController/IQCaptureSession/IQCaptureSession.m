//
//  IQCaptureSession.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQCaptureSession.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "IQFileManager.h"

// info dictionary keys
extern NSString *const IQCaptureMediaType;      // an NSString (UTI, i.e. kUTTypeImage)
extern NSString *const IQCaptureImage;          // a UIImage
extern NSString *const IQCaptureMediaURL;       // an NSURL
extern NSString *const IQCaptureMediaURLs;       // an NSArray of NSURL
extern NSString *const IQCaptureMediaMetadata;  // an NSDictionary containing metadata from a captured photo

extern NSString *const IQCaptureMediaTypeVideo;
extern NSString *const IQCaptureMediaTypeAudio;
extern NSString *const IQCaptureMediaTypeImage;


@interface IQCaptureSession ()<AVCaptureFileOutputRecordingDelegate>

//Input
@property(nonatomic, strong, readonly) AVCaptureDeviceInput *videoCaptureDeviceInput;
@property(nonatomic, strong, readonly) AVCaptureDeviceInput *audioCaptureDeviceInput;

//Output
@property(nonatomic, strong, readonly) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong, readonly) AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic, strong, readonly) AVCaptureAudioDataOutput *audioFileOutput;

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

+(AVCaptureDevice*)defaultAudioDevice
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    return device;
}

+(NSURL*)defaultRecordingURL
{
    return [NSURL fileURLWithPath:[[[self class] storagePath] stringByAppendingString:@"video.mov"]];
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
        NSLog(@"Can't add inputs: %@",newInputs);

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
        NSLog(@"Can't add outputs: %@",newOutputs);
        
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

-(BOOL)setCaptureMode:(IQCameraCaptureMode)captureMode
{
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
        //Not implemented yet.
        return NO;
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
    else if (_audioFileOutput != nil)
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
            NSLog(@"Can't set flash mode:%@",error);

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
            NSLog(@"Can't set torch mode:%@",error);
            
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
            NSLog(@"Can't set focus mode:%@",error);
            
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
        NSLog(@"Exposure Mode not supported: %ld",(long)exposureMode);
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
        NSLog(@"White Balance not supported: %ld",(long)whiteBalanceMode);
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
        NSLog(@"Focus adjustment not supported");
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
        NSLog(@"Exposure adjustment not supported");
        return NO;
    }
}

-(BOOL)isSessionRunning
{
    return [_captureSession isRunning];
}

-(void)startRunning
{
    [_captureSession startRunning];
}

-(void)stopRunning
{
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
    else
    {
        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if ( imageDataSampleBuffer != NULL )
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:image,IQCaptureImage,IQCaptureMediaTypeImage,IQCaptureMediaType, nil];

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

#pragma mark - Video recording

//-(BOOL)recording
//{
//    return _movieFileOutput.isRecording;
//}

-(BOOL)isRecording
{
    return _movieFileOutput.isRecording;
}

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
        NSURL *fileURL = [[self class] defaultRecordingURL];
        
        [IQFileManager removeItemAtPath:fileURL.relativePath];

        [_movieFileOutput stopRecording];
        [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
    }
}

-(void)stopVideoRecording
{
    [_movieFileOutput stopRecording];
}

- (CGFloat)recordingDuration
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
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:outputFileURL,IQCaptureMediaURL,IQCaptureMediaTypeVideo,IQCaptureMediaType, nil];
        
        if ([self.delegate respondsToSelector:@selector(captureSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate captureSession:self didFinishMediaWithInfo:dict error:nil];
        }
    }
}

+(NSString*)storagePath
{
    return [IQFileManager IQTemporaryDirectory];
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
}

@end
