//
//  IQAudioSession.h
//  ImagePickerController
//
//  Created by Iftekhar on 16/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQAudioSessionDelegate;

@class AVAudioRecorder;

@interface IQAudioSession : NSObject

@property(nonatomic, assign) id<IQAudioSessionDelegate> delegate;

@property(nonatomic, assign, readonly) BOOL isRunning;

- (void)startRunning;
- (void)stopRunning;

@property(nonatomic, readonly, getter=isRecording) BOOL recording;

- (void)startAudioRecording;
- (void)stopAudioRecording;
- (CGFloat)recordingDuration;

@end


@protocol IQAudioSessionDelegate <NSObject>

@optional
- (void)audioSession:(IQAudioSession*)audioSession didFinishMediaWithInfo:(NSDictionary *)info error:(NSError *)error;
- (void)audioSession:(IQAudioSession *)audioSession didUpdateMeterLevel:(CGFloat)meterLevel;
@end


