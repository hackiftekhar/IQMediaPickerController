//
//  IQMediaPickerSelection.m
//  IQMediaPickerController
//
//  Created by Iftekhar on 26/07/18.
//

#import "IQMediaPickerSelection.h"
#import <Photos/PHAsset.h>
#import <MediaPlayer/MPMediaItem.h>

@interface IQMediaPickerSelection()

@property(readonly) NSMutableArray<UIImage*> *internalSelectedImages;

@property(readonly) NSMutableArray<PHAsset*> *internalSelectedAssets;

@property(readonly) NSMutableArray<NSURL*> *internalSelectedAssetsURL;

@property(readonly) NSMutableArray<MPMediaItem*> *internalSelectedAudios;

@end

@implementation IQMediaPickerSelection

- (instancetype)init
{
    self = [super init];
    if (self) {
        _internalSelectedImages = [[NSMutableArray alloc] init];
        _internalSelectedAssets = [[NSMutableArray alloc] init];
        _internalSelectedAssetsURL = [[NSMutableArray alloc] init];
        _internalSelectedAudios = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addImages:(NSArray<UIImage*>*)images
{
    [_internalSelectedImages addObjectsFromArray:images];
}

-(void)addAssets:(NSArray<PHAsset*>*)assets
{
    [_internalSelectedAssets addObjectsFromArray:assets];
}

-(void)addAssetsURL:(NSArray<NSURL*>*)urls
{
    [_internalSelectedAssetsURL addObjectsFromArray:urls];
}

-(void)addAudios:(NSArray<MPMediaItem*>*)audios
{
    [_internalSelectedAudios addObjectsFromArray:audios];
}

-(NSArray<UIImage *> *)selectedImages
{
    return _internalSelectedImages;
}

-(NSArray<PHAsset *> *)selectedAssets
{
    return _internalSelectedAssets;
}

-(NSArray<NSURL *> *)selectedAssetsURL
{
    return _internalSelectedAssetsURL;
}

-(NSArray<MPMediaItem *> *)selectedAudios
{
    return _internalSelectedAudios;
}

@end
