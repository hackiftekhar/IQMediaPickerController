//
//  IQSettingsContainerView.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2017 Iftekhar Qurashi.
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


#import "IQSettingsContainerView.h"

@implementation IQSettingsContainerView

-(void)dealloc
{
    _photoSettingsView = nil;
    _videoSettingsView = nil;
    _audioSettingsView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoSettingsView = [[IQPhotoSettingsContainerView alloc] initWithFrame:self.bounds];
        self.photoSettingsView.alpha = 0;
        [self addSubview:self.photoSettingsView];
        
        self.videoSettingsView = [[IQVideoSettingsContainerView alloc] initWithFrame:self.bounds];
        self.videoSettingsView.alpha = 0;
        [self addSubview:self.videoSettingsView];
        
        self.audioSettingsView = [[IQAudioSettingsContainerView alloc] initWithFrame:self.bounds];
        self.audioSettingsView.alpha = 0;
        [self addSubview:self.audioSettingsView];
        
        //Constraints
        {
            self.photoSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
            self.videoSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
            self.audioSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSDictionary *views = @{@"photoSettingsView":self.photoSettingsView,@"videoSettingsView":self.videoSettingsView,@"audioSettingsView":self.audioSettingsView};
            
            NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray alloc] init];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[photoSettingsView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[photoSettingsView(==40)]|" options:0 metrics:nil views:views]];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoSettingsView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[videoSettingsView]|" options:0 metrics:nil views:views]];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[audioSettingsView]|" options:0 metrics:nil views:views]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[audioSettingsView]|" options:0 metrics:nil views:views]];
            
            [self addConstraints:constraints];
        }
    }
    return self;
}

-(void)setCaptureMode:(PHAssetMediaType)captureMode
{
    _captureMode = captureMode;
    [self.photoSettingsView resetUI];
    [self.videoSettingsView resetUI];
    [self.audioSettingsView resetUI];
    
    self.photoSettingsView.alpha = (captureMode == PHAssetMediaTypeImage);
    self.videoSettingsView.alpha = (captureMode == PHAssetMediaTypeVideo);
    self.audioSettingsView.alpha = (captureMode == PHAssetMediaTypeAudio);
}

@end
