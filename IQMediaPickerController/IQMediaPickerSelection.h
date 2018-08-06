//
//  IQMediaPickerSelection.h
//  IQMediaPickerController
//
//  Created by Iftekhar on 26/07/18.
//

#import <Foundation/NSObject.h>

@class UIImage, PHAsset, MPMediaItem;

@interface IQMediaPickerSelection : NSObject

@property(readonly) NSArray<UIImage*> *selectedImages;

@property(readonly) NSArray<PHAsset*> *selectedAssets;

@property(readonly) NSArray<NSURL*> *selectedAssetsURL;

@property(readonly) NSArray<MPMediaItem*> *selectedAudios;

-(void)addImages:(NSArray<UIImage*>*)images;
-(void)addAssets:(NSArray<PHAsset*>*)assets;
-(void)addAssetsURL:(NSArray<NSURL*>*)urls;
-(void)addAudios:(NSArray<MPMediaItem*>*)audios;

@end
