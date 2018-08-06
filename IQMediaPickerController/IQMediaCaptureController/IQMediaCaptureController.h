//
//  IQMediaCaptureController.h
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-147Iftekhar Qurashi.
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


#import <UIKit/UIViewController.h>
#import <Photos/PhotosTypes.h>
#import <AVFoundation/AVCaptureDevice.h>

@protocol IQMediaCaptureControllerDelegate;

@class IQMediaPickerSelection;

@interface IQMediaCaptureController : UIViewController

@property(nullable, nonatomic, weak) id <IQMediaCaptureControllerDelegate> delegate;

@property(nonatomic) NSArray <NSNumber *> * _Nullable mediaTypes;
@property(nonatomic) AVCaptureDevicePosition captureDevice;
@property(nonatomic) AVCaptureFlashMode flashMode;
@property(nonatomic) NSArray <AVCaptureSessionPreset> * _Nullable allowedVideoQualities;

@property(nonatomic, readonly) PHAssetMediaType captureMode;

@property (nonatomic) BOOL allowsCapturingMultipleItems; // default is NO.
@property NSUInteger maximumItemCount;

@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) NSTimeInterval audioMaximumDuration;

- (void)takePicture;

- (BOOL)startVideoCapture;
- (void)stopVideoCapture;

- (BOOL)startAudioCapture;
- (void)stopAudioCapture;

@end


@protocol IQMediaCaptureControllerDelegate <NSObject>

- (void)mediaCaptureController:(IQMediaCaptureController*_Nonnull)controller didFinishMedias:(IQMediaPickerSelection *_Nonnull)selection;
- (void)mediaCaptureControllerDidCancel:(IQMediaCaptureController *_Nonnull)controller;

@end
