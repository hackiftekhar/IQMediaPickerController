//
//  IQMediaView.h
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class IQMediaView;

@protocol IQMediaViewDelegate <NSObject>

-(void)mediaView:(IQMediaView*)mediaView focusPointOfInterest:(CGPoint)focusPoint;
-(void)mediaView:(IQMediaView*)mediaView exposurePointOfInterest:(CGPoint)exposurePoint;

@end

@interface IQMediaView : UIView

@property(nonatomic, assign) IBOutlet id<IQMediaViewDelegate> delegate;

@property(nonatomic, weak) AVCaptureSession *previewSession;

@property(nonatomic, assign) BOOL blur;

@property(nonatomic, assign) AVCaptureFocusMode focusMode;
@property(nonatomic, assign) AVCaptureExposureMode exposureMode;

@property(nonatomic, assign) CGPoint focusPointOfInterest;
@property(nonatomic, assign) CGPoint exposurePointOfInterest;

@end
