//
//  IQMediaPickerControllerConstants.h
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-17 Iftekhar Qurashi.
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


#import <Foundation/Foundation.h>

extern NSString *const IQMediaURL;          // an NSURL
extern NSString *const IQMediaAssetURL;          // an NSURL
extern NSString *const IQMediaItem;          // an MPMediaItem
extern NSString *const IQMediaImage;        // a UIImage

extern NSString *const IQMediaType;      // an NSString (UTI, i.e. kUTTypeImage)

extern NSString *const IQMediaTypeAudio;
extern NSString *const IQMediaTypeVideo;
extern NSString *const IQMediaTypeImage;

typedef NS_ENUM(NSInteger, IQMediaPickerControllerSourceType) {
    IQMediaPickerControllerSourceTypeLibrary,
    IQMediaPickerControllerSourceTypeCameraMicrophone,
};

typedef NS_ENUM(NSInteger, IQMediaPickerControllerMediaType) {
    IQMediaPickerControllerMediaTypePhoto,
    IQMediaPickerControllerMediaTypeVideo,
    IQMediaPickerControllerMediaTypeAudio,
};

typedef NS_ENUM(NSInteger, IQMediaPickerControllerCameraDevice) {
    IQMediaPickerControllerCameraDeviceRear,
    IQMediaPickerControllerCameraDeviceFront,
};

typedef NS_ENUM(NSInteger, IQMediaPickerControllerCameraFlashMode) {
    IQMediaPickerControllerCameraFlashModeOff,
    IQMediaPickerControllerCameraFlashModeOn,
    IQMediaPickerControllerCameraFlashModeAuto,
};

typedef NS_ENUM(NSInteger, IQMediaPickerControllerQualityType) {
    IQMediaPickerControllerQualityTypeHigh,   //High quality video and audio or photo with full resolution
    IQMediaPickerControllerQualityTypeMedium,   //Medium quality output, suitable for sharing over Wi-Fi
    IQMediaPickerControllerQualityTypeLow,   //Low quality output, suitable for sharing over 3G
    IQMediaPickerControllerQualityType352x288,   //CIF quality
    IQMediaPickerControllerQualityType640x480,   //VGA quality
    IQMediaPickerControllerQualityType1280x720,   //
    IQMediaPickerControllerQualityType1920x1080,   //
    IQMediaPickerControllerQualityType3840x2160,   //  UHD 4K
    IQMediaPickerControllerQualityTypeiFrame960x540,   //  iFrame H264 ~30 Mbits/sec, AAC audio
    IQMediaPickerControllerQualityTypeiFrame1280x720,   //  iFrame H264 ~40 Mbits/sec AAC audio
};
