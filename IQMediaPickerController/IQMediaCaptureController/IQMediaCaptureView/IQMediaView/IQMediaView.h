//
//  IQMediaView.h
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


#import <UIKit/UIView.h>
#import <UIKit/UISwipeGestureRecognizer.h>
#import <AVFoundation/AVCaptureDevice.h>

#import "IQMediaCaptureController.h"

@class IQMediaView, AVCaptureSession, AVCaptureVideoPreviewLayer;

@protocol IQMediaViewDelegate <NSObject>

-(void)mediaView:(IQMediaView*_Nonnull)mediaView focusPointOfInterest:(CGPoint)focusPoint;
-(void)mediaView:(IQMediaView*_Nonnull)mediaView exposurePointOfInterest:(CGPoint)exposurePoint;
-(void)mediaView:(IQMediaView*_Nonnull)mediaView swipeDirection:(UISwipeGestureRecognizerDirection)direction;

@end

@interface IQMediaView : UIView

@property(nullable, weak) id<IQMediaViewDelegate> delegate;

@property(nonatomic, nullable, weak) AVCaptureSession *previewSession;

@property (nullable) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) UIEdgeInsets previewInset;

@property (nonatomic) CGFloat meteringLevel;

@property (nonatomic) AVCaptureFocusMode focusMode;
@property (nonatomic) AVCaptureExposureMode exposureMode;

@property (nonatomic) CGPoint focusPointOfInterest;
@property (nonatomic) CGPoint exposurePointOfInterest;

@property (nonatomic) PHAssetMediaType captureMode;

@property(nonatomic) BOOL recording;

-(void)setBlur:(BOOL)blur completion:(void (^_Nullable)(void))completion;

@end
