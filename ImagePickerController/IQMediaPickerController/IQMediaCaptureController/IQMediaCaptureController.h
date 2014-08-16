//
//  IQVideoCaptureController.h
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IQMediaCaptureControllerCaptureMode) {
    IQMediaCaptureControllerCaptureModePhoto,
    IQMediaCaptureControllerCaptureModeVideo,
    IQMediaCaptureControllerCaptureModeAudio,
};

typedef NS_ENUM(NSInteger, IQMediaCaptureControllerCameraDevice) {
    IQMediaCaptureControllerCameraDeviceRear,
    IQMediaCaptureControllerCameraDeviceFront,
};

@protocol IQMediaCaptureControllerDelegate;

@interface IQMediaCaptureController : UIViewController

@property(nonatomic, assign) id<IQMediaCaptureControllerDelegate> delegate;

@property(nonatomic, assign) IQMediaCaptureControllerCaptureMode captureMode;
@property(nonatomic, assign) IQMediaCaptureControllerCameraDevice captureDevice;

//@property(nonatomic, assign) BOOL allowsMultipleVideoRecording; //Default to NO.

@end


@protocol IQMediaCaptureControllerDelegate <NSObject>

- (void)mediaCaptureController:(IQMediaCaptureController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
- (void)mediaCaptureControllerDidCancel:(IQMediaCaptureController *)controller;

@end

extern NSString *const IQMediaTypeVideo;
extern NSString *const IQMediaTypeAudio;
extern NSString *const IQMediaTypeImage;
