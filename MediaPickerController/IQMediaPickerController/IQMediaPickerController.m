//
//  IQMediaPickerController.m
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

#import "IQMediaPickerController.h"
#import "IQMediaCaptureController.h"
#import "IQAssetsPickerController.h"
#import "IQAudioPickerController.h"
#import "IQMediaPickerControllerConstants.h"

@interface IQMediaPickerController ()<IQMediaCaptureControllerDelegate,IQAssetsPickerControllerDelegate,IQAudioPickerControllerDelegate,UITabBarControllerDelegate>

@end

@implementation IQMediaPickerController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setMediaType:IQMediaPickerControllerMediaTypePhoto];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.mediaType)
    {
        case IQMediaPickerControllerMediaTypeVideo:
        {
            IQMediaCaptureController *controller = [[IQMediaCaptureController alloc] init];
            controller.allowsCapturingMultipleItems = self.allowsPickingMultipleItems;
            controller.delegate = self;
            controller.captureMode = IQMediaCaptureControllerCaptureModeVideo;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypePhoto:
        {
            IQMediaCaptureController *controller = [[IQMediaCaptureController alloc] init];
            controller.allowsCapturingMultipleItems = self.allowsPickingMultipleItems;
            controller.captureMode = IQMediaCaptureControllerCaptureModePhoto;
            controller.delegate = self;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeAudio:
        {
            IQMediaCaptureController *controller = [[IQMediaCaptureController alloc] init];
            controller.allowsCapturingMultipleItems = self.allowsPickingMultipleItems;
            controller.delegate = self;
            controller.captureMode = IQMediaCaptureControllerCaptureModeAudio;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypePhotoLibrary:
        {
            IQAssetsPickerController *controller = [[IQAssetsPickerController alloc] init];
            controller.allowsPickingMultipleItems = self.allowsPickingMultipleItems;
            controller.delegate = self;
            controller.pickerType = IQAssetsPickerControllerAssetTypePhoto;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeVideoLibrary:
        {
            IQAssetsPickerController *controller = [[IQAssetsPickerController alloc] init];
            controller.allowsPickingMultipleItems = self.allowsPickingMultipleItems;
            controller.delegate = self;
            controller.pickerType = IQAssetsPickerControllerAssetTypeVideo;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeAudioLibrary:
        {
            IQAudioPickerController *controller = [[IQAudioPickerController alloc] init];
            controller.allowsPickingMultipleItems = self.allowsPickingMultipleItems;
            controller.delegate = self;
            self.viewControllers = @[controller];
        }
            break;
        default:
            break;
    }
}

-(void)setMediaType:(IQMediaPickerControllerMediaType)mediaType
{
    _mediaType = mediaType;
}

#pragma mark - IQMediaCaptureControllerDelegate
- (void)mediaCaptureController:(IQMediaCaptureController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerController:didFinishMediaWithInfo:)])
    {
        [self.delegate mediaPickerController:self didFinishMediaWithInfo:info];
    }
}

- (void)mediaCaptureControllerDidCancel:(IQMediaCaptureController *)controller
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerControllerDidCancel:)])
    {
        [self.delegate mediaPickerControllerDidCancel:self];
    }
}

#pragma mark - IQAssetsPickerControllerDelegate
- (void)assetsPickerController:(IQAssetsPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerController:didFinishMediaWithInfo:)])
    {
        [self.delegate mediaPickerController:self didFinishMediaWithInfo:info];
    }
}

- (void)assetsPickerControllerDidCancel:(IQAssetsPickerController *)controller
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerControllerDidCancel:)])
    {
        [self.delegate mediaPickerControllerDidCancel:self];
    }
}

#pragma mark - IQAudioPickerControllerDelegate
- (void)audioPickerController:(IQAudioPickerController *)mediaPicker didPickMediaItems:(NSArray*)mediaItems
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerController:didFinishMediaWithInfo:)])
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:mediaItems forKey:IQMediaTypeAudio];
        
        [self.delegate mediaPickerController:self didFinishMediaWithInfo:info];
    }
}

- (void)audioPickerControllerDidCancel:(IQAudioPickerController *)mediaPicker
{
    if ([self.delegate respondsToSelector:@selector(mediaPickerControllerDidCancel:)])
    {
        [self.delegate mediaPickerControllerDidCancel:self];
    }
}

@end

