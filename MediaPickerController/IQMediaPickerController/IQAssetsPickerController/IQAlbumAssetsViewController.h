
#import <UIKit/UIKit.h>

@protocol IQAssetsPickerControllerDelegate;
@class IQAssetsPickerController;

typedef NS_ENUM(NSInteger, IQAssetsPickerControllerAssetType) {
    IQAssetsPickerControllerAssetTypePhoto,
    IQAssetsPickerControllerAssetTypeVideo,
};

@class ALAssetsGroup;

@interface IQAlbumAssetsViewController : UICollectionViewController

@property (assign, nonatomic) ALAssetsGroup *assetsGroup;
@property(nonatomic, assign) IQAssetsPickerController *assetController;
@property (assign, nonatomic) IQAssetsPickerControllerAssetType pickerType;

@end
