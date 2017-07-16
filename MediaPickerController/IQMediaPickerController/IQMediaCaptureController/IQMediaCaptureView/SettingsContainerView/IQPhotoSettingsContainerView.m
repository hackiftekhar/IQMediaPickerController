//
//  PhotoSettingsContainerView.m
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


#import "IQPhotoSettingsContainerView.h"
#import "IQAKPickerView.h"

typedef NS_ENUM(NSUInteger, IQPhotoSettingsType) {
    IQPhotoSettingsTypeDefault,
    IQPhotoSettingsTypeFlash,
    IQPhotoSettingsTypeQuality,
};

@interface IQPhotoSettingsContainerView ()<IQAKPickerViewDelegate,IQAKPickerViewDataSource>

@property IQPhotoSettingsType settingsShowType;
@property (nonatomic) IQAKPickerView *qualityPickerView;

@property(nonatomic, readonly) UIButton *buttonCamera;
@property(nonatomic, readonly) UIButton *buttonFlash;

@property(nonatomic) UIButton *buttonFlashAuto;
@property(nonatomic) UIButton *buttonFlashOn;
@property(nonatomic) UIButton *buttonFlashOff;

@property(nonatomic, readonly) UIButton *buttonPhotoQuality;
@property(nonatomic, readonly) NSArray <NSDictionary*>* qualities;


@end

@implementation IQPhotoSettingsContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        {
            _buttonFlash = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlash addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlash.tintColor = [UIColor whiteColor];
            _buttonFlash.frame = CGRectMake(0, 0, 40, 40);
            [self addSubview:self.buttonFlash];
            
            _buttonFlashAuto = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashAuto addTarget:self action:@selector(flashAutoAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashAuto.alpha = 0;
            _buttonFlashAuto.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashAuto.tintColor = [UIColor whiteColor];
            [_buttonFlashAuto setTitle:@"Auto" forState:UIControlStateNormal];
            [_buttonFlashAuto sizeToFit];
            _buttonFlashAuto.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame)+40, 0, CGRectGetWidth(_buttonFlashAuto.frame), 40);
            [self addSubview:_buttonFlashAuto];
            
            _buttonFlashOn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashOn addTarget:self action:@selector(flashOnAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashOn.alpha = 0;
            _buttonFlashOn.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashOn.tintColor = [UIColor whiteColor];
            [_buttonFlashOn setTitle:@"On" forState:UIControlStateNormal];
            [_buttonFlashOn sizeToFit];
            _buttonFlashOn.frame = CGRectMake(CGRectGetMaxX(_buttonFlashAuto.frame)+40, 0, CGRectGetWidth(_buttonFlashOn.frame), 40);
            [self addSubview:_buttonFlashOn];
            
            _buttonFlashOff = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonFlashOff addTarget:self action:@selector(flashOffAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonFlashOff.alpha = 0;
            _buttonFlashOff.titleLabel.font = [UIFont systemFontOfSize:12];
            _buttonFlashOff.tintColor = [UIColor whiteColor];
            [_buttonFlashOff setTitle:@"Off" forState:UIControlStateNormal];
            [_buttonFlashOff sizeToFit];
            _buttonFlashOff.frame = CGRectMake(CGRectGetMaxX(_buttonFlashOn.frame)+40, 0, CGRectGetWidth(_buttonFlashOff.frame), 40);
            [self addSubview:_buttonFlashOff];
        }
        
        //Camera
        {
            _buttonCamera = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonCamera setImage:[UIImage imageNamed:@"IQ_camera_switch"] forState:UIControlStateNormal];
            [_buttonCamera addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonCamera.tintColor = [UIColor whiteColor];
            _buttonCamera.frame = CGRectMake(CGRectGetMaxX(self.bounds)-40-5, 0, 40, 40);
            [self addSubview:_buttonCamera];
        }
        
        //Quality
        {
            _buttonPhotoQuality = [UIButton buttonWithType:UIButtonTypeSystem];
            [_buttonPhotoQuality setTitle:nil forState:UIControlStateNormal];
            _buttonPhotoQuality.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [_buttonPhotoQuality addTarget:self action:@selector(photoQualityAction:) forControlEvents:UIControlEventTouchUpInside];
            _buttonPhotoQuality.tintColor = [UIColor yellowColor];
            _buttonPhotoQuality.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame), 0, 60, 40);
            [self addSubview:_buttonPhotoQuality];
            
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
        
        self.hasFlash = NO;
    }
    return self;
}

-(void)setPreferredPreset:(NSArray<NSNumber *> *)preferredPreset
{
    _preferredPreset = preferredPreset;
    
    NSMutableArray<NSDictionary*> *sessionSupportedPreset = [[NSMutableArray alloc] init];
    NSMutableArray <NSNumber *> *supportedPreset = [[NSMutableArray alloc] init];
    
    for (NSNumber *preset in _preferredPreset)
    {
        switch ([preset integerValue])
        {
            case IQCaptureSessionPresetPhoto:
            case IQCaptureSessionPresetHigh:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetPhoto),@"name":@"HIGH"}];
                [supportedPreset addObject:@(IQCaptureSessionPresetPhoto)];
                break;
            case IQCaptureSessionPresetMedium:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetMedium),@"name":@"MEDIUM"}];
                [supportedPreset addObject:@(IQCaptureSessionPresetMedium)];
                break;
            case IQCaptureSessionPresetLow:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetLow),@"name":@"LOW"}];
                [supportedPreset addObject:@(IQCaptureSessionPresetLow)];
                break;
            case IQCaptureSessionPreset352x288:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPreset352x288),@"name":@"288P"}];
                [supportedPreset addObject:@(IQCaptureSessionPreset352x288)];
                break;
            case IQCaptureSessionPreset640x480:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPreset640x480),@"name":@"480P"}];
                [supportedPreset addObject:@(IQCaptureSessionPreset640x480)];
                break;
            case IQCaptureSessionPreset1280x720:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPreset1280x720),@"name":@"720P"}];
                [supportedPreset addObject:@(IQCaptureSessionPreset1280x720)];
                break;
            case IQCaptureSessionPreset1920x1080:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPreset1920x1080),@"name":@"1080P"}];
                [supportedPreset addObject:@(IQCaptureSessionPreset1920x1080)];
                break;
            case IQCaptureSessionPreset3840x2160:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPreset3840x2160),@"name":@"2160P"}];
                [supportedPreset addObject:@(IQCaptureSessionPreset3840x2160)];
                break;
            case IQCaptureSessionPresetiFrame960x540:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetiFrame960x540),@"name":@"i540P"}];
                [supportedPreset addObject:@(IQCaptureSessionPresetiFrame960x540)];
                break;
            case IQCaptureSessionPresetiFrame1280x720:
                [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetiFrame1280x720),@"name":@"i720P"}];
                [supportedPreset addObject:@(IQCaptureSessionPresetiFrame1280x720)];
                break;
        }
    }
    
    if (sessionSupportedPreset.count == 0)
    {
        [sessionSupportedPreset addObject:@{@"quality":@(IQCaptureSessionPresetPhoto),@"name":@"HIGH"}];
        [supportedPreset addObject:@(IQCaptureSessionPresetPhoto)];
    }
    
    _qualities = [sessionSupportedPreset copy];
    _supportedPreset = [supportedPreset copy];
    
    [self.qualityPickerView reloadData];
    [self updateUI];
}

-(void)setHasFlash:(BOOL)hasFlash
{
    _hasFlash = hasFlash;

    [self updateUI];
}

-(void)setHasCamera:(BOOL)hasCamera
{
    _hasCamera = hasCamera;
    
    [self updateUI];
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    _flashMode = flashMode;
    
    [self updateUI];
}

-(void)setPhotoPreset:(IQCaptureSessionPreset)photoPreset
{
    if (photoPreset == IQCaptureSessionPresetHigh)
    {
        photoPreset = IQCaptureSessionPresetPhoto;
    }
    
    _photoPreset = photoPreset;
    
    [self updateUI];
}

-(void)updateUI
{
    self.buttonCamera.alpha = _hasCamera && (_settingsShowType == IQPhotoSettingsTypeDefault);
    self.buttonFlash.alpha = _hasFlash && ((_settingsShowType == IQPhotoSettingsTypeDefault) || (_settingsShowType == IQPhotoSettingsTypeFlash));
    self.buttonPhotoQuality.alpha = (_settingsShowType == IQPhotoSettingsTypeDefault) || (_settingsShowType == IQPhotoSettingsTypeQuality);
    self.qualityPickerView.alpha = (_settingsShowType == IQPhotoSettingsTypeQuality);

    switch (self.flashMode) {
        case AVCaptureFlashModeOn:
        {
            [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash"] forState:UIControlStateNormal];
            self.buttonFlash.tintColor = self.buttonFlashOn.tintColor = [UIColor yellowColor];
            self.buttonFlashAuto.tintColor = self.buttonFlashOff.tintColor = [UIColor whiteColor];
        }
            break;
        case AVCaptureFlashModeOff:
        {
            [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash_off"] forState:UIControlStateNormal];
            self.buttonFlashOff.tintColor = [UIColor yellowColor];
            self.buttonFlash.tintColor = self.buttonFlashAuto.tintColor = self.buttonFlashOn.tintColor = [UIColor whiteColor];
        }
            break;
        case AVCaptureFlashModeAuto:
        {
            [self.buttonFlash setImage:[UIImage imageNamed:@"IQ_camera_flash"] forState:UIControlStateNormal];
            self.buttonFlashAuto.tintColor = [UIColor yellowColor];
            self.buttonFlash.tintColor = self.buttonFlashOn.tintColor = self.buttonFlashOff.tintColor = [UIColor whiteColor];
        }
            break;
    }
    
    //Quality
    if (_qualities)
    {
        _buttonPhotoQuality.userInteractionEnabled = (_qualities.count > 1);
        
        NSDictionary *selectedQuality = nil;
        for (NSDictionary *quality in _qualities)
        {
            IQCaptureSessionPreset preset = [quality[@"quality"] integerValue];
            
            if (preset == self.photoPreset)
            {
                selectedQuality = quality;
                break;
            }
        }
        
        if (selectedQuality == nil)
        {
            selectedQuality = [_qualities firstObject];
        }
        
        [_buttonPhotoQuality setTitle:selectedQuality[@"name"] forState:UIControlStateNormal];
        if (_settingsShowType == IQPhotoSettingsTypeQuality)
        {
            _buttonPhotoQuality.frame = CGRectMake(0, 0, 60, 40);
        }
        else
        {
            _buttonPhotoQuality.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame), 0, 60, 40);
        }
        [_qualityPickerView selectItem:[_qualities indexOfObject:selectedQuality] animated:YES notifySelection:NO];
    }
}


-(void)flashAction:(UIButton*)button
{
    _settingsShowType = (_settingsShowType == IQPhotoSettingsTypeDefault)?IQPhotoSettingsTypeFlash:IQPhotoSettingsTypeDefault;
    
    [self showHideSettings];
}

-(void)showHideSettings
{
    [UIView animateWithDuration:0.2 animations:^{
        
        //Flash
        {
            if (_settingsShowType == IQPhotoSettingsTypeFlash)
            {
                _buttonFlashAuto.center = CGPointMake(CGRectGetMidX(_buttonFlash.frame)+80, _buttonFlash.center.y);
                _buttonFlashOn.center = CGPointMake(CGRectGetMidX(_buttonFlashAuto.frame)+80, _buttonFlashAuto.center.y);
                _buttonFlashOff.center = CGPointMake(CGRectGetMidX(_buttonFlashOn.frame)+80, _buttonFlashOn.center.y);
            }
            else
            {
                _buttonFlashAuto.center = _buttonFlashOn.center = _buttonFlashOff.center = _buttonFlash.center;
            }
            
            self.buttonFlashAuto.alpha = (_settingsShowType == IQPhotoSettingsTypeFlash);
            self.buttonFlashOn.alpha = (_settingsShowType == IQPhotoSettingsTypeFlash);
            self.buttonFlashOff.alpha = (_settingsShowType == IQPhotoSettingsTypeFlash);
        }
        
        //Quality
        {
            if (_settingsShowType == IQPhotoSettingsTypeQuality)
            {
                _buttonPhotoQuality.frame = CGRectMake(0, 0, 60, 40);
            }
            else
            {
                _buttonPhotoQuality.frame = CGRectMake(CGRectGetMaxX(_buttonFlash.frame), 0, 60, 40);
            }
        }
        
        self.buttonCamera.alpha = _hasCamera && (_settingsShowType == IQPhotoSettingsTypeDefault);
        self.buttonFlash.alpha = _hasFlash && ((_settingsShowType == IQPhotoSettingsTypeDefault) || (_settingsShowType == IQPhotoSettingsTypeFlash));
        self.buttonPhotoQuality.alpha = (_settingsShowType == IQPhotoSettingsTypeDefault) || (_settingsShowType == IQPhotoSettingsTypeQuality);
        self.qualityPickerView.alpha = (_settingsShowType == IQPhotoSettingsTypeQuality);
    }];
}

-(void)resetUI
{
    _settingsShowType = IQPhotoSettingsTypeDefault;
    
    [self showHideSettings];
}

-(void)cameraAction:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(photoSettingsViewFlippedCamera:)])
    {
        [self.delegate photoSettingsViewFlippedCamera:self];
    }
}

-(void)flashAutoAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(photoSettingsView:didChangeFlashMode:)])
    {
        [self.delegate photoSettingsView:self didChangeFlashMode:AVCaptureFlashModeAuto];
    }
    
    [self resetUI];
}

-(void)flashOnAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(photoSettingsView:didChangeFlashMode:)])
    {
        [self.delegate photoSettingsView:self didChangeFlashMode:AVCaptureFlashModeOn];
    }
    
    [self resetUI];
}

-(void)flashOffAction:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(photoSettingsView:didChangeFlashMode:)])
    {
        [self.delegate photoSettingsView:self didChangeFlashMode:AVCaptureFlashModeOff];
    }
    
    [self resetUI];
}

-(void)photoQualityAction:(UIButton*)button
{
    if (_settingsShowType == IQPhotoSettingsTypeDefault)
    {
        _settingsShowType = IQPhotoSettingsTypeQuality;
        [self showHideSettings];
    }
    else if(_settingsShowType == IQPhotoSettingsTypeQuality)
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
    IQCaptureSessionPreset preset = [_qualities[self.qualityPickerView.selectedItem][@"quality"] integerValue];
    
    if (preset != self.photoPreset)
    {
        if ([self.delegate respondsToSelector:@selector(photoSettingsView:didChangePhotoPreset:)])
        {
            [self.delegate photoSettingsView:self didChangePhotoPreset:preset];
        }
    }
}

@end
