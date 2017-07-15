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


#import <UIKit/UIKit.h>
#import "IQMediaPickerControllerConstants.h"

@protocol IQMediaPickerControllerDelegate;

@interface IQMediaPickerController : UINavigationController

+ (BOOL)isSourceTypeAvailable:(IQMediaPickerControllerSourceType)sourceType;

+ (IQMediaPickerControllerMediaType)availableMediaTypesForSourceType:(IQMediaPickerControllerSourceType)sourceType;

+ (BOOL)isCameraDeviceAvailable:(IQMediaPickerControllerCameraDevice)cameraDevice;

+ (BOOL)isFlashAvailableForCameraDevice:(IQMediaPickerControllerCameraDevice)cameraDevice;


@property(nonatomic, weak, nullable) id<IQMediaPickerControllerDelegate,UINavigationControllerDelegate> delegate;
@property BOOL allowsPickingMultipleItems; // default is NO.

@property(nonatomic, assign) IQMediaPickerControllerSourceType sourceType;
@property(nonatomic, assign) IQMediaPickerControllerMediaType mediaType;    //You can combine multiple media types to be picked or captured. If you are capturing the media then any combinations are accepted but if you would like to pick media from library then only photo + video combinations are accepted. Combining audio picking with photo and or video isn't supported and no future plans to do it.
@property(nonatomic, assign) IQMediaPickerControllerCameraDevice captureDevice;
//@property(nonatomic, assign) IQMediaPickerControllerCameraFlashMode flashMode;

@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) NSTimeInterval audioMaximumDuration;

//@property(nonatomic) UIImagePickerControllerQualityType videoQuality;

- (void)takePicture;

- (BOOL)startVideoCapture;
- (void)stopVideoCapture;

- (BOOL)startAudioCapture;
- (void)stopAudioCapture;

//@property(nonatomic) UIImagePickerControllerCameraFlashMode   cameraFlashMode   NS_AVAILABLE_IOS(4_0); // default is UIImagePickerControllerCameraFlashModeAuto.

@end

@protocol IQMediaPickerControllerDelegate <NSObject>

- (void)mediaPickerController:(IQMediaPickerController*_Nonnull)controller didFinishMediaWithInfo:(NSDictionary *_Nonnull)info;
- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *_Nonnull)controller;

@end
