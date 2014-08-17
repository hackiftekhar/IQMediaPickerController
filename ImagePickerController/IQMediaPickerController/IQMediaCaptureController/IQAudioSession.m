//
//  IQAudioSession.m
//  ImagePickerController
//
//  Created by Iftekhar on 16/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAudioSession.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>


@interface IQAudioSession ()<AVAudioRecorderDelegate>

@end

@implementation IQAudioSession
{
    NSURL *outputURL;
    AVAudioRecorder *audioRecorder;
}
@synthesize recording = _recording;
@synthesize isRunning = _isRunning;

+(NSString*)storagePath
{
    return [IQFileManager IQTemporaryDirectory];
}

+(NSURL*)defaultRecordingURL
{
    return [NSURL fileURLWithPath:[[[self class] storagePath] stringByAppendingString:@"audio.m4a"]];
}

-(void)dealloc
{
    audioRecorder.delegate = nil;
    [audioRecorder stop];
    audioRecorder = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURL *fileURL = [[self class] defaultRecordingURL];
        _isRunning = NO;
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:recordSetting error:nil];
        audioRecorder.delegate = self;
        audioRecorder.meteringEnabled = YES;
    }
    return self;
}

-(BOOL)isRunning
{
    return _isRunning;
}

-(void)startRunning
{
    _isRunning = YES;
}

-(void)stopRunning
{
    [audioRecorder stop];
    _isRunning = NO;
}

-(BOOL)isRecording
{
    return audioRecorder.isRecording;
}

- (void)startAudioRecording
{
    if (audioRecorder.recording == NO)
    {
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        
        [audioRecorder prepareToRecord];
        // Start recording
        [audioRecorder record];
    }
}

- (void)stopAudioRecording
{
    [audioRecorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (CGFloat)recordingDuration
{
    return audioRecorder.currentTime;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)successful
{
    if (successful)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:recorder.url,IQMediaURL,IQMediaTypeAudio,IQMediaType, nil];

        if ([self.delegate respondsToSelector:@selector(audioSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate audioSession:self didFinishMediaWithInfo:dict error:nil];
        }
    }
    else
    {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:1 userInfo:nil];
        
        if ([self.delegate respondsToSelector:@selector(audioSession:didFinishMediaWithInfo:error:)])
        {
            [self.delegate audioSession:self didFinishMediaWithInfo:nil error:error];
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(audioSession:didFinishMediaWithInfo:error:)])
    {
        [self.delegate audioSession:self didFinishMediaWithInfo:nil error:error];
    }
}



@end
