
#import <UIKit/UIKit.h>
#import "IQAlbumAssetsViewController.h"

@protocol IQAssetsPickerControllerDelegate;

@interface IQAssetsPickerController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) id<IQAssetsPickerControllerDelegate> delegate;
@property (nonatomic) BOOL allowsPickingMultipleItems; // default is NO
@property (nonatomic, assign) IQAssetsPickerControllerAssetType pickerType;

@end


@protocol IQAssetsPickerControllerDelegate <NSObject>

- (void)assetsPickerController:(IQAssetsPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
- (void)assetsPickerControllerDidCancel:(IQAssetsPickerController *)controller;

@end