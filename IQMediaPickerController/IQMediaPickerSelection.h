//
//  IQMediaPickerSelection.h
//  IQMediaPickerController
//
//  Created by Iftekhar on 26/07/18.
//

#import <Foundation/NSObject.h>

@class UIImage, PHAsset, MPMediaItem;

@interface IQMediaPickerSelection : NSObject

@property(nonnull, readonly) NSArray<UIImage*> *selectedImages;

@property(nonnull, readonly) NSArray<PHAsset*> *selectedAssets;

@property(nonnull, readonly) NSArray<NSURL*> *selectedAssetsURL;

@property(nonnull, readonly) NSArray<MPMediaItem*> *selectedAudios;

-(void)addImages:(NSArray<UIImage*>* _Nonnull)images;
-(void)addAssets:(NSArray<PHAsset*> * _Nonnull)assets;
-(void)addAssetsURL:(NSArray<NSURL*>* _Nonnull)urls;
-(void)addAudios:(NSArray<MPMediaItem*>* _Nonnull)audios;

@end
