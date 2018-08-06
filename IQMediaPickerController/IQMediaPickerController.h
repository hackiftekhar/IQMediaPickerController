//
//  IQMediaPickerController.h
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

#import <UIKit/UINavigationController.h>
#import <Photos/PhotosTypes.h>
#import <AVFoundation/AVCaptureDevice.h>

//! Project version number for IQMediaPickerController.
FOUNDATION_EXPORT double IQMediaPickerControllerVersionNumber;

//! Project version string for IQMediaPickerController.
FOUNDATION_EXPORT const unsigned char IQMediaPickerControllerVersionString[];

#import "IQMediaPickerSelection.h"

typedef NS_ENUM(NSUInteger, IQMediaPickerControllerSourceType) {
    IQMediaPickerControllerSourceTypeLibrary,
    IQMediaPickerControllerSourceTypeCameraMicrophone,
};

@protocol IQMediaPickerControllerDelegate;

@interface IQMediaPickerController : UINavigationController

+ (BOOL)isSourceTypeAvailable:(IQMediaPickerControllerSourceType)sourceType;

+ (NSArray <NSNumber* > * _Nonnull)availableMediaTypesForSourceType:(IQMediaPickerControllerSourceType)sourceType;    //Return array of PHAssetMediaType

+ (BOOL)isCameraDeviceAvailable:(AVCaptureDevicePosition)cameraDevice;

+ (BOOL)isFlashAvailableForCameraDevice:(AVCaptureDevicePosition)cameraDevice;


@property(nonatomic, weak, nullable) id<IQMediaPickerControllerDelegate,UINavigationControllerDelegate> delegate;
@property BOOL allowsPickingMultipleItems; // default is NO.
@property NSUInteger maximumItemCount;

@property(nonatomic) IQMediaPickerControllerSourceType sourceType;
@property(nonatomic, nullable) NSArray <NSNumber * > * mediaTypes;    //Should be array of PHAssetMediaType. You can combine multiple media types to be picked or captured. If you are capturing the media then any combinations are accepted but if you would like to pick media from library then only photo + video combinations are accepted. Combining audio picking with photo and or video isn't supported and no future plans to do it.
@property(nonatomic) AVCaptureDevicePosition captureDevice;
//@property(nonatomic) AVCaptureFlashMode flashMode;

@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) NSTimeInterval audioMaximumDuration;

/**
 AVCaptureSessionPresetPhoto            //High quality photo, full resolution
 AVCaptureSessionPresetHigh             //High quality video/audio
 AVCaptureSessionPresetMedium           //Medium quality output, suitable for sharing over Wi-Fi
 AVCaptureSessionPresetLow              //Low quality output, suitable for sharing over 3G
 AVCaptureSessionPreset352x288          //CIF quality
 AVCaptureSessionPreset640x480          //VGA quality
 AVCaptureSessionPreset1280x720         //720P
 AVCaptureSessionPreset1920x1080        //1080P
 AVCaptureSessionPreset3840x2160        //UHD 4K
 AVCaptureSessionPresetiFrame960x540    //iFrame H264 ~30 Mbits/sec, AAC audio
 AVCaptureSessionPresetiFrame1280x720   //iFrame H264 ~40 Mbits/sec, AAC audio
 */
@property(nonatomic, nullable) NSArray <AVCaptureSessionPreset> * allowedVideoQualities;

- (void)takePicture;

- (BOOL)startVideoCapture;
- (void)stopVideoCapture;

- (BOOL)startAudioCapture;
- (void)stopAudioCapture;

@end

@protocol IQMediaPickerControllerDelegate <NSObject>

- (void)mediaPickerController:(IQMediaPickerController*_Nonnull)controller didFinishMedias:(IQMediaPickerSelection *_Nonnull)selection;
- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *_Nonnull)controller;

@end
