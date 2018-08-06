//
//  IQCaptureSession.h
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

#import <Foundation/NSObject.h>
#import <AVFoundation/AVCaptureDevice.h>

#import "IQMediaCaptureController.h"


extern NSString *const IQMediaURL;          // an NSURL
extern NSString *const IQMediaImage;        // a UIImage
extern NSString *const IQMediaType;      // an NSString (UTI, i.e. kUTTypeImage)

extern NSString *const IQMediaTypeAudio;
extern NSString *const IQMediaTypeVideo;
extern NSString *const IQMediaTypeImage;

@protocol IQCaptureSessionDelegate;

@class AVCaptureSession;

@interface IQCaptureSession : NSObject

@property (nullable, weak) id<IQCaptureSessionDelegate> delegate;

/*****Session*****/
@property (nonnull, readonly) AVCaptureSession *captureSession; //An instance of AVCaptureSession to coordinate the data flow from the input to the output
@property (nonnull, readonly) NSArray <AVCaptureSessionPreset> * supportedSessionPreset;
@property AVCaptureSessionPreset captureSessionPreset;
@property (readonly) CGSize presetSize;

@property (readonly) BOOL isSessionRunning;

- (void)startRunning;
- (void)stopRunning;
/**********/

/*****Settings*****/
- (BOOL)hasMultipleCameras;
- (BOOL)hasFlash;
- (BOOL)hasTorch;
- (BOOL)hasFocus;
- (BOOL)hasExposure;
- (BOOL)hasWhiteBalance;
- (BOOL)isFocusPointSupported;
- (BOOL)isExposurePointSupported;

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode;
- (BOOL)isTorchModeSupported:(AVCaptureTorchMode)torchMode;
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)focusMode;
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)exposureMode;
- (BOOL)isWhiteBalanceModeSupported:(AVCaptureWhiteBalanceMode)whiteBalanceMode;

- (PHAssetMediaType)captureMode;
+ (NSArray<AVCaptureDevice*>*_Nonnull)supportedVideoCaptureDevices;
- (AVCaptureDevicePosition)cameraPosition;
- (AVCaptureFlashMode)flashMode;
- (AVCaptureTorchMode)torchMode;
- (AVCaptureFocusMode)focusMode;
- (AVCaptureExposureMode)exposureMode;
- (AVCaptureWhiteBalanceMode)whiteBalanceMode;
- (CGPoint)focusPoint;
- (CGPoint)exposurePoint;

- (BOOL)setCaptureMode:(PHAssetMediaType)captureMode;
- (BOOL)setCameraPosition:(AVCaptureDevicePosition)cameraPosition;
- (BOOL)setFlashMode:(AVCaptureFlashMode)flashMode;
- (BOOL)setTorchMode:(AVCaptureTorchMode)torchMode;
- (BOOL)setFocusMode:(AVCaptureFocusMode)focusMode;
- (BOOL)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (BOOL)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode;
- (BOOL)setFocusPoint:(CGPoint)focusPoint;
- (BOOL)setExposurePoint:(CGPoint)exposurePoint;
/**********/

//IQCameraCaptureModePhoto
- (void)takePicture;

//IQCameraCaptureModeVideo
- (void)startVideoRecordingWithMaximumDuration:(NSTimeInterval)videoMaximumDuration;
- (void)stopVideoRecording;

//IQCameraCaptureModeAudio
- (void)startAudioRecordingWithMaximumDuration:(NSTimeInterval)audioMaximumDuration;
- (void)stopAudioRecording;

@property(readonly, getter=isRecording) BOOL recording;
- (CGFloat)recordingDuration;
- (long long)recordingSize;

@end


@protocol IQCaptureSessionDelegate <NSObject>

@optional

//Common
- (void)captureSession:(IQCaptureSession*_Nonnull)captureSession didFinishMediaWithInfo:(NSDictionary *_Nullable)info error:(NSError *_Nullable)error;

- (void)captureSessionDidStartRecording:(IQCaptureSession*_Nonnull)captureSession;
- (void)captureSessionDidPauseRecording:(IQCaptureSession*_Nonnull)captureSession;

- (void)captureSessionDidUpdateSessionPreset:(IQCaptureSession*_Nonnull)captureSession;

//IQCameraCaptureModeAudio
- (void)captureSession:(IQCaptureSession*_Nonnull)audioSession didUpdateMeterLevel:(CGFloat)meterLevel;

@end
