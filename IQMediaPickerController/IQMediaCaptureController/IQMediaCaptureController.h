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


#import <UIKit/UIKit.h>
#import "IQMediaPickerControllerConstants.h"

typedef NS_ENUM(NSInteger, IQMediaCaptureControllerCaptureMode) {
    IQMediaCaptureControllerCaptureModePhoto,
    IQMediaCaptureControllerCaptureModeVideo,
    IQMediaCaptureControllerCaptureModeAudio,
};

@protocol IQMediaCaptureControllerDelegate;

@interface IQMediaCaptureController : UIViewController

@property(nullable, nonatomic, weak) id <IQMediaCaptureControllerDelegate> delegate;

@property(nonatomic) NSArray <NSNumber *> * _Nullable mediaTypes;
@property(nonatomic) IQMediaPickerControllerCameraDevice captureDevice;
@property(nonatomic) IQMediaPickerControllerCameraFlashMode flashMode;
@property(nonatomic) NSArray <NSNumber*> * _Nullable allowedVideoQualities;    //Array of IQMediaPickerControllerQualityType

@property(nonatomic, readonly) IQMediaCaptureControllerCaptureMode captureMode;

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

- (void)mediaCaptureController:(IQMediaCaptureController*_Nonnull)controller didFinishMediaWithInfo:(NSDictionary *_Nonnull)info;
- (void)mediaCaptureControllerDidCancel:(IQMediaCaptureController *_Nonnull)controller;

@end
