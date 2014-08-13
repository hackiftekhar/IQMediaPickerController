
#import <UIKit/UIKit.h>
#import "IQAssetsPickerController.h"

@interface IQAlbumsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, assign) IQAssetsPickerControllerAssetType pickerType;

@end
