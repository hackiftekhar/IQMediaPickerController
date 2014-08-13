//
//  IQImagePickerController.h
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IQMediaPickerControllerMediaType) {
    IQMediaPickerControllerMediaTypePhotoLibrary,
    IQMediaPickerControllerMediaTypeVideoLibrary,
    IQMediaPickerControllerMediaTypeAudioLibrary,
    IQMediaPickerControllerMediaTypePhoto,
    IQMediaPickerControllerMediaTypeVideo,
    IQMediaPickerControllerMediaTypeAudio,
};

@protocol IQMediaPickerControllerDelegate;

@interface IQMediaPickerController : UINavigationController

@property(nonatomic, assign) id<IQMediaPickerControllerDelegate,UINavigationControllerDelegate> delegate;
@property(nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end


@protocol IQMediaPickerControllerDelegate <NSObject>

- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;

@end


// info dictionary keys
extern NSString *const IQCaptureMediaType;      // an NSString (UTI, i.e. kUTTypeImage)
extern NSString *const IQCaptureImage;          // a UIImage
extern NSString *const IQCaptureMediaURL;       // an NSURL
extern NSString *const IQCaptureMediaURLs;       // an NSArray of NSURL
extern NSString *const IQCaptureMediaMetadata;  // an NSDictionary containing metadata from a captured photo

extern NSString *const IQCaptureMediaTypeVideo;
extern NSString *const IQCaptureMediaTypeAudio;
extern NSString *const IQCaptureMediaTypeImage;

