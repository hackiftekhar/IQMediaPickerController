//
//  IQImagePickerController.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQMediaPickerController.h"
#import "IQMediaCaptureController.h"
#import "IQAlbumsViewController.h"
#import "IQAudioPickerController.h"

@interface IQMediaPickerController ()

@end

@implementation IQMediaPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)setMediaType:(IQMediaPickerControllerMediaType)mediaType
{
    _mediaType = mediaType;
    
    switch (mediaType)
    {
        case IQMediaPickerControllerMediaTypeVideo:
        {
            IQMediaCaptureController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaCaptureController class])];
            controller.captureMode = IQMediaCaptureControllerCaptureModeVideo;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypePhoto:
        {
            IQMediaCaptureController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaCaptureController class])];
            controller.captureMode = IQMediaCaptureControllerCaptureModePhoto;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeAudio:
        {
            IQMediaCaptureController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaCaptureController class])];
            controller.captureMode = IQMediaCaptureControllerCaptureModeAudio;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypePhotoLibrary:
        {
            IQAlbumsViewController *controller = [[IQAlbumsViewController alloc] init];
            controller.pickerType = IQAssetsPickerControllerAssetTypePhoto;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeVideoLibrary:
        {
            IQAlbumsViewController *controller = [[IQAlbumsViewController alloc] init];
            controller.pickerType = IQAssetsPickerControllerAssetTypeVideo;
            self.viewControllers = @[controller];
        }
            break;
        case IQMediaPickerControllerMediaTypeAudioLibrary:
        {
            IQAudioPickerController *controller = [[IQAudioPickerController alloc] init];
            self.viewControllers = @[controller];
        }
            break;
        default:
            break;
    }
}

@end




NSString *const IQCaptureMediaType      =   @"IQCaptureMediaType";      // an NSString (UTI, i.e. kUTTypeImage)
NSString *const IQCaptureImage          =   @"IQCaptureImage";          // a UIImage
NSString *const IQCaptureMediaURL       =   @"IQCaptureMediaURL";       // an NSURL
NSString *const IQCaptureMediaURLs      =   @"IQCaptureMediaURLs";       // an NSArray of NSURL
NSString *const IQCaptureMediaMetadata  =   @"IQCaptureMediaMetadata";  // an NSDictionary containing metadata from a captured photo


NSString *const IQCaptureMediaTypeVideo =   @"IQCaptureMediaTypeVideo";      // an NSString (UTI, i.e. kUTTypeImage)
//NSString *const IQCaptureMediaTypeAudio =   @"IQCaptureMediaTypeAudio";      // an NSString (UTI, i.e. kUTTypeImage)
NSString *const IQCaptureMediaTypeImage =   @"IQCaptureMediaTypeImage";      // an NSString (UTI, i.e. kUTTypeImage)

