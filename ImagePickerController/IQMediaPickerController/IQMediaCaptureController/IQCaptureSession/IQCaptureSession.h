//
//  IQCaptureSession.h
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "IQMediaCaptureController.h"


typedef NS_ENUM(NSInteger, IQCameraCaptureMode) {
    IQCameraCaptureModePhoto,
    IQCameraCaptureModeVideo,
    IQCameraCaptureModeAudio,
    IQCameraCaptureModeUnspecified,
};

@protocol IQCaptureSessionDelegate;


@interface IQCaptureSession : NSObject

@property(nonatomic, weak) id<IQCaptureSessionDelegate> delegate;

/*****Session*****/
@property(nonatomic, strong, readonly) AVCaptureSession *captureSession; //An instance of AVCaptureSession to coordinate the data flow from the input to the output
//@property(nonatomic, assign) IQCaptureSessionPreset captureSessionPreset;

@property(nonatomic, assign, readonly) BOOL isSessionRunning;

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

- (IQCameraCaptureMode)captureMode;
- (AVCaptureDevicePosition)cameraPosition;
- (AVCaptureFlashMode)flashMode;
- (AVCaptureTorchMode)torchMode;
- (AVCaptureFocusMode)focusMode;
- (AVCaptureExposureMode)exposureMode;
- (AVCaptureWhiteBalanceMode)whiteBalanceMode;
- (CGPoint)focusPoint;
- (CGPoint)exposurePoint;

- (BOOL)setCaptureMode:(IQCameraCaptureMode)captureMode;
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
@property(nonatomic, readonly, getter=isRecording) BOOL recording;
- (void)startVideoRecording;
- (void)stopVideoRecording;
- (CGFloat)recordingDuration;

+(NSString*)storagePath;

@end


@protocol IQCaptureSessionDelegate <NSObject>

@optional
- (void)captureSession:(IQCaptureSession*)captureSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError *)error;

@end


extern NSString *const IQMediaType;      // an NSString (UTI, i.e. kUTTypeImage)
extern NSString *const IQMediaImage;          // a UIImage
extern NSString *const IQMediaURL;       // an NSURL

extern NSString *const IQMediaTypeVideo;
extern NSString *const IQMediaTypeImage;
