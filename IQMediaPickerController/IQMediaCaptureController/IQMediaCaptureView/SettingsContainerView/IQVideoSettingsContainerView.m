//
//  IQVideoSettingsContainerView.m
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


#import <UIKit/UIButton.h>

#import "IQVideoSettingsContainerView.h"
#import "IQAKPickerView.h"
#import "NSString+IQTimeIntervalFormatter.h"
#import "UIImage+IQMediaPickerController.h"

typedef NS_ENUM(NSUInteger, IQVideoSettingsType) {
    IQVideoSettingsTypeDefault,
    IQVideoSettingsTypeFlash,
    IQVideoSettingsTypeQuality,
};

@interface IQVideoSettingsContainerView ()<IQAKPickerViewDelegate,IQAKPickerViewDataSource>

@property IQVideoSettingsType settingsShowType;
@property (nonatomic) IQAKPickerView *qualityPickerView;
@property(nonatomic) UILabel *labelFileSize;
@property(nonatomic) UILabel *labelDuration;

@property(nonatomic, readonly) UIButton *buttonCamera;

@property(nonatomic, readonly) UIButton *buttonFlash;
@property(nonatomic) UIButton *buttonFlashAuto;
@property(nonatomic) UIButton *buttonFlashOn;
@property(nonatomic) UIButton *buttonFlashOff;

@property(nonatomic, readonly) UIButton *buttonVideoQuality;
@property(nonatomic, readonly) NSArray <NSDictionary*>* qualities;

@end

@implementation IQVideoSettingsContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //Flash
        {
            _buttonFlash = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlash addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlash.tintColor = [UIColor whiteColor];
            _buttonFlash.frame = CGRectMake(0, 0, 40, 40);
            [self addSubview:_buttonFlash];
            
            _buttonFlashAuto = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashAuto addTarget:self action:@selector(flashAutoAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashAuto.alpha = 0;
            _buttonFlashAuto.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashAuto.tintColor = [UIColor whiteColor];
            [_buttonFlashAuto setTitle:@"Auto" forState:UIControlStateNormal];
            _buttonFlashAuto.frame = _buttonFlash.frame;
            [_buttonFlashAuto sizeToFit];
            CGRect rect = _buttonFlashAuto.frame;
            rect.origin.y = 0;
            rect.size.height = frame.size.height;
            _buttonFlashAuto.frame = rect;
            [self addSubview:_buttonFlashAuto];
            
            _buttonFlashOn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashOn addTarget:self action:@selector(flashOnAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashOn.alpha = 0;
            _buttonFlashOn.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashOn.tintColor = [UIColor whiteColor];
            [_buttonFlashOn setTitle:@"On" forState:UIControlStateNormal];
            _buttonFlashOn.frame = _buttonFlash.frame;
            [_buttonFlashOn sizeToFit];
            rect = _buttonFlashOn.frame;
            rect.origin.y = 0;
            rect.size.height = frame.size.height;
            _buttonFlashOn.frame = rect;
            [self addSubview:_buttonFlashOn];
            
            _buttonFlashOff = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashOff addTarget:self action:@selector(flashOffAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashOff.alpha = 0;
            _buttonFlashOff.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashOff.tintColor = [UIColor whiteColor];
            [_buttonFlashOff setTitle:@"Off" forState:UIControlStateNormal];
            _buttonFlashOff.frame = _buttonFlash.frame;
            [_buttonFlashOff sizeToFit];
            rect = _buttonFlashOff.frame;
            rect.origin.y = 0;
            rect.size.height = frame.size.height;
            _buttonFlashOff.frame = rect;
            [self addSubview:_buttonFlashOff];
        }
        
        //Camera
        {
            _buttonCamera = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonCamera setImage:[UIImage imageInsideMediaPickerBundleNamed:@"IQ_camera_switch"] forState:UIControlStateNormal];
            [_buttonCamera addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonCamera.tintColor = [UIColor whiteColor];
            _buttonCamera.frame = CGRectMake(CGRectGetMaxX(self.bounds)-40-5, 0, 40, 40);
            [self addSubview:_buttonCamera];
        }
        
        //Quality
        {
            _buttonVideoQuality = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonVideoQuality setTitle:nil forState:UIControlStateNormal];
            _buttonVideoQuality.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [_buttonVideoQuality addTarget:self action:@selector(videoQualityAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonVideoQuality.tintColor = [UIColor yellowColor];
            _buttonVideoQuality.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame), 0, 60, 40);
            [self addSubview:_buttonVideoQuality];
            
            _qualityPickerView = [[IQAKPickerView alloc] initWithFrame:CGRectMake(60, 0, CGRectGetMaxX(self.bounds)-60, 40)];
            _qualityPickerView.delegate = self;
            _qualityPickerView.dataSource = self;
            _qualityPickerView.backgroundColor = [UIColor clearColor];
            _qualityPickerView.font = [UIFont systemFontOfSize:12];
            _qualityPickerView.highlightedFont = [UIFont systemFontOfSize:12];
            _qualityPickerView.textColor = [UIColor whiteColor];
            _qualityPickerView.highlightedTextColor = [UIColor yellowColor];
            _qualityPickerView.interitemSpacing = 30;
            _qualityPickerView.maskDisabled = NO;
            _qualityPickerView.alpha = 0;
            [self addSubview:_qualityPickerView];
        }
        
        {
            _labelFileSize = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 40)];
            _labelFileSize.textAlignment = NSTextAlignmentLeft;
            _labelFileSize.font = [UIFont systemFontOfSize:12];
            _labelFileSize.textColor = [UIColor whiteColor];
            _labelFileSize.alpha = 0;
            [self addSubview:_labelFileSize];
            
            _labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            _labelDuration.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            _labelDuration.textAlignment = NSTextAlignmentCenter;
            _labelDuration.font = [UIFont systemFontOfSize:18];
            _labelDuration.textColor = [UIColor whiteColor];
            [self addSubview:_labelDuration];
        }
        
        self.hasTorch = NO;
        self.duration = 0;
    }
    return self;
}

-(void)setPreferredPreset:(NSArray<AVCaptureSessionPreset> *)preferredPreset
{
    _preferredPreset = preferredPreset;
    
    NSMutableArray<NSDictionary*> *sessionSupportedPreset = [[NSMutableArray alloc] init];
    NSMutableArray <AVCaptureSessionPreset> *supportedPreset = [[NSMutableArray alloc] init];
    
    for (AVCaptureSessionPreset preset in _preferredPreset)
    {
        [supportedPreset addObject:preset];
        
        if (preset == AVCaptureSessionPresetHigh)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"HIGH"}];
        }
        else if (preset == AVCaptureSessionPresetMedium)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"MEDIUM"}];
        }
        else if (preset == AVCaptureSessionPresetLow)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"LOW"}];
        }
        else if (preset == AVCaptureSessionPreset352x288)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"288P"}];
        }
        else if (preset == AVCaptureSessionPreset640x480)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"480P"}];
        }
        else if (preset == AVCaptureSessionPreset1280x720)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"720P"}];
        }
        else if (preset == AVCaptureSessionPreset1920x1080)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"1080P"}];
        }
        else if (preset == AVCaptureSessionPreset3840x2160)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"2160P"}];
        }
        else if (preset == AVCaptureSessionPresetiFrame960x540)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"i540P"}];
        }
        else if (preset == AVCaptureSessionPresetiFrame1280x720)
        {
            [sessionSupportedPreset addObject:@{@"quality":preset,@"name":@"i720P"}];
        }
        else
        {
            [supportedPreset removeObject:preset];
        }
    }

    if (sessionSupportedPreset.count == 0)
    {
        [sessionSupportedPreset addObject:@{@"quality":AVCaptureSessionPresetHigh,@"name":@"HIGH"}];
        [supportedPreset addObject:AVCaptureSessionPresetHigh];
    }

    _qualities = [sessionSupportedPreset copy];
    _supportedPreset = [supportedPreset copy];
    
    [self.qualityPickerView reloadData];
    [self updateUI];
}

-(void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    _labelDuration.text = [NSString timeStringForTimeInterval:duration forceIncludeHours:YES];
}

-(void)setFileSize:(long long)fileSize
{
    _fileSize = fileSize;
    
    _labelFileSize.text = [NSByteCountFormatter stringFromByteCount:_fileSize countStyle:NSByteCountFormatterCountStyleBinary];
}

-(void)setHasTorch:(BOOL)hasTorch
{
    _hasTorch = hasTorch;
    
    [self updateUI];
}

-(void)setHasCamera:(BOOL)hasCamera
{
    _hasCamera = hasCamera;
    
    [self updateUI];
}

-(void)setRecording:(BOOL)recording
{
    _recording = recording;

    [self updateUI];
}

-(void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    _torchMode = torchMode;
    
    [self updateUI];
}

-(void)setVideoPreset:(AVCaptureSessionPreset)videoPreset
{
    if (videoPreset == AVCaptureSessionPresetPhoto)
    {
        videoPreset = AVCaptureSessionPresetHigh;
    }
    
    _videoPreset = videoPreset;

    [self updateUI];
}

-(void)updateUI
{
    if (_recording)
    {
        _buttonFlash.alpha = 0;
        _buttonFlashAuto.alpha = 0;
        _buttonFlashOn.alpha = 0;
        _buttonFlashOff.alpha = 0;
        
        _buttonVideoQuality.alpha = 0;
        _qualityPickerView.alpha = 0;

        _buttonCamera.alpha = 0;

        _labelFileSize.alpha = 1;
        _labelDuration.alpha = 1;
    }
    else
    {
        [self showHideSettings];

        _labelFileSize.alpha = 0;
    }
    
    switch (self.torchMode) {
        case AVCaptureTorchModeOn:
        {
            [self.buttonFlash setImage:[UIImage imageInsideMediaPickerBundleNamed:@"IQ_camera_flash"] forState:UIControlStateNormal];
            self.buttonFlash.tintColor = self.buttonFlashOn.tintColor = [UIColor yellowColor];
            self.buttonFlashAuto.tintColor = self.buttonFlashOff.tintColor = [UIColor whiteColor];
        }
            break;
        case AVCaptureTorchModeOff:
        {
            [self.buttonFlash setImage:[UIImage imageInsideMediaPickerBundleNamed:@"IQ_camera_flash_off"] forState:UIControlStateNormal];
            self.buttonFlashOff.tintColor = [UIColor yellowColor];
            self.buttonFlash.tintColor = self.buttonFlashAuto.tintColor = self.buttonFlashOn.tintColor = [UIColor whiteColor];
        }
            break;
        case AVCaptureTorchModeAuto:
        {
            [self.buttonFlash setImage:[UIImage imageInsideMediaPickerBundleNamed:@"IQ_camera_flash"] forState:UIControlStateNormal];
            self.buttonFlashAuto.tintColor = [UIColor yellowColor];
            self.buttonFlash.tintColor = self.buttonFlashOn.tintColor = self.buttonFlashOff.tintColor = [UIColor whiteColor];
        }
            break;
    }
    
    //Quality
    if (_qualities)
    {
        _buttonVideoQuality.userInteractionEnabled = (_qualities.count > 1);
        
        NSDictionary *selectedQuality = nil;
        for (NSDictionary *quality in _qualities)
        {
            AVCaptureSessionPreset preset = quality[@"quality"];
            
            if (preset == self.videoPreset)
            {
                selectedQuality = quality;
                break;
            }
        }
        
        if (selectedQuality == nil)
        {
            selectedQuality = [_qualities firstObject];
        }
        
        [_buttonVideoQuality setTitle:selectedQuality[@"name"] forState:UIControlStateNormal];
        if (_settingsShowType == IQVideoSettingsTypeQuality)
        {
            _buttonVideoQuality.frame = CGRectMake(0, 0, 60, 40);
        }
        else
        {
            _buttonVideoQuality.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame), 0, 60, 40);
        }
        [_qualityPickerView selectItem:[_qualities indexOfObject:selectedQuality] animated:YES notifySelection:NO];
    }
}

-(void)flashAction:(UIButton*)button
{
    _settingsShowType = (_settingsShowType == IQVideoSettingsTypeDefault)?IQVideoSettingsTypeFlash:IQVideoSettingsTypeDefault;
    
    [self showHideSettings];
}

-(void)showHideSettings
{
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        
        //Flash
        {
            if (weakSelf.settingsShowType == IQVideoSettingsTypeFlash)
            {
                weakSelf.buttonFlashAuto.center = CGPointMake(CGRectGetMidX(weakSelf.buttonFlash.frame)+80, weakSelf.buttonFlash.center.y);
                weakSelf.buttonFlashOn.center = CGPointMake(CGRectGetMidX(weakSelf.buttonFlashAuto.frame)+80, weakSelf.buttonFlashAuto.center.y);
                weakSelf.buttonFlashOff.center = CGPointMake(CGRectGetMidX(weakSelf.buttonFlashOn.frame)+80, weakSelf.buttonFlashOn.center.y);
            }
            else
            {
                weakSelf.buttonFlashAuto.center = weakSelf.buttonFlashOn.center = weakSelf.buttonFlashOff.center = weakSelf.buttonFlash.center;
            }
            
            weakSelf.buttonFlashAuto.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeFlash);
            weakSelf.buttonFlashOn.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeFlash);
            weakSelf.buttonFlashOff.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeFlash);
        }
        
        //Quality
        {
            if (weakSelf.settingsShowType == IQVideoSettingsTypeQuality)
            {
                weakSelf.buttonVideoQuality.frame = CGRectMake(0, 0, 60, 40);
            }
            else
            {
                weakSelf.buttonVideoQuality.frame = CGRectMake(CGRectGetMaxX(weakSelf.buttonFlash.frame), 0, 60, 40);
            }
        }

        weakSelf.buttonCamera.alpha = weakSelf.hasCamera && (weakSelf.settingsShowType == IQVideoSettingsTypeDefault);
        weakSelf.buttonFlash.alpha = weakSelf.hasTorch && ((weakSelf.settingsShowType == IQVideoSettingsTypeDefault) || (weakSelf.settingsShowType == IQVideoSettingsTypeFlash));
        weakSelf.buttonVideoQuality.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeDefault) || (weakSelf.settingsShowType == IQVideoSettingsTypeQuality);
        weakSelf.labelDuration.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeDefault);
        weakSelf.qualityPickerView.alpha = (weakSelf.settingsShowType == IQVideoSettingsTypeQuality);
    }];
}

-(void)resetUI
{
    _settingsShowType = IQVideoSettingsTypeDefault;
    
    [self showHideSettings];
}

-(void)cameraAction:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(videoSettingsViewFlippedCamera:)])
    {
        [self.delegate videoSettingsViewFlippedCamera:self];
    }
}

-(void)flashAutoAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(videoSettingsView:didChangeTorchMode:)])
    {
        [self.delegate videoSettingsView:self didChangeTorchMode:AVCaptureTorchModeAuto];
    }
    
    [self resetUI];
}

-(void)flashOnAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(videoSettingsView:didChangeTorchMode:)])
    {
        [self.delegate videoSettingsView:self didChangeTorchMode:AVCaptureTorchModeOn];
    }
    
    [self resetUI];
}

-(void)flashOffAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(videoSettingsView:didChangeTorchMode:)])
    {
        [self.delegate videoSettingsView:self didChangeTorchMode:AVCaptureTorchModeOff];
    }
    
    [self resetUI];
}

-(void)videoQualityAction:(UIButton*)button
{
    if (_settingsShowType == IQVideoSettingsTypeDefault)
    {
        _settingsShowType = IQVideoSettingsTypeQuality;
        [self showHideSettings];
    }
    else if(_settingsShowType == IQVideoSettingsTypeQuality)
    {
        [self resetUI];
    }
}

-(NSString *)pickerView:(IQAKPickerView *)pickerView titleForItem:(NSInteger)item
{
    return _qualities[item][@"name"];
}

-(NSUInteger)numberOfItemsInPickerView:(IQAKPickerView *)pickerView
{
    return _qualities.count;
}

-(void)pickerView:(IQAKPickerView *)pickerView didSelectItem:(NSInteger)item
{
    AVCaptureSessionPreset preset = _qualities[self.qualityPickerView.selectedItem][@"quality"];
    if (preset != self.videoPreset)
    {
        if ([self.delegate respondsToSelector:@selector(videoSettingsView:didChangeVideoPreset:)])
        {
            [self.delegate videoSettingsView:self didChangeVideoPreset:preset];
        }
    }
}

@end
