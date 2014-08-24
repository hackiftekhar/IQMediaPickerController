//
//  IQMediaView.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IQMediaCaptureController.h"

@class IQMediaView;

@protocol IQMediaViewDelegate <NSObject>

-(void)mediaView:(IQMediaView*)mediaView focusPointOfInterest:(CGPoint)focusPoint;
-(void)mediaView:(IQMediaView*)mediaView exposurePointOfInterest:(CGPoint)exposurePoint;

@end

@interface IQMediaView : UIView

@property(nonatomic, assign) id<IQMediaViewDelegate> delegate;

@property(nonatomic, weak) AVCaptureSession *previewSession;

@property(nonatomic, assign) BOOL blur;
@property(nonatomic, assign) CGFloat meteringLevel;

@property(nonatomic, assign) AVCaptureFocusMode focusMode;
@property(nonatomic, assign) AVCaptureExposureMode exposureMode;

@property(nonatomic, assign) CGPoint focusPointOfInterest;
@property(nonatomic, assign) CGPoint exposurePointOfInterest;

@property(nonatomic, assign) IQMediaCaptureControllerCaptureMode captureMode;

@end
