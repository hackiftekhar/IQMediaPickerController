
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IQAssetsPickerControllerAssetType) {
    IQAssetsPickerControllerAssetTypePhoto,
    IQAssetsPickerControllerAssetTypeVideo,
};

@class ALAssetsGroup;

@interface IQAssetsPickerController : UICollectionViewController

@property (assign, nonatomic) ALAssetsGroup *assetsGroup;
@property (assign, nonatomic) IQAssetsPickerControllerAssetType pickerType;

@end
