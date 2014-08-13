
#import "IQAlbumsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQ_SGSStaggeredFlowLayout.h"

@interface IQAlbumsViewController ()

@property(nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation IQAlbumsViewController
{
    NSMutableArray *_assetGroups;
}

#pragma - mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.navigationItem setTitle:@"Loading..."];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
    _assetGroups = [[NSMutableArray alloc] init];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^{
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil) {
                               return;
                           }
                           NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                           NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                           if (self.pickerType == IQAssetsPickerControllerAssetTypePhoto)
                           {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                           }
                           else if (self.pickerType == IQAssetsPickerControllerAssetTypeVideo)
                           {
                               [group setAssetsFilter:[ALAssetsFilter allVideos]];
                           }
                           else
                           {

                           }
                           
                           if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                               [_assetGroups insertObject:group atIndex:0];
                           }
                           else {
                               if (group.numberOfAssets != 0) {
                                   [_assetGroups addObject:group];
                               }
                           }
                           [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                       };
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                           
                           if ([[error localizedDescription] isEqualToString:@"User denied access" ]) {
                               [self performSelector:@selector(dismissImagePicker) withObject:nil afterDelay:2];
                           }
                       };
        
                       [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                   usingBlock:assetGroupEnumerator
                                                 failureBlock:assetGroupEnumberatorFailure];
                   });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)reloadTableView
{
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Albums"];
}

- (void)dismissImagePicker
{
//    if ([((SNImagePickerNavigationController *)(self.navigationController)).imagePickerDelegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self dismissViewControllerAnimated:YES completion:^{
//                [((SNImagePickerNavigationController *)(self.navigationController)).imagePickerDelegate imagePickerDidCancel:((SNImagePickerNavigationController *)(self.navigationController))];
//            }];
//        });
//    }
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    ALAssetsGroup *group = (ALAssetsGroup*)[_assetGroups objectAtIndex:indexPath.row];
    if (self.pickerType == IQAssetsPickerControllerAssetTypePhoto)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
    if (self.pickerType == IQAssetsPickerControllerAssetTypeVideo)
    {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
    }

    NSInteger groupCount = [group numberOfAssets];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[group valueForProperty:ALAssetsGroupPropertyName], (long)groupCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[_assetGroups objectAtIndex:indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsPickerController *assetsVC = [[IQAssetsPickerController alloc] initWithCollectionViewLayout:[[IQ_SGSStaggeredFlowLayout alloc] init]];
    assetsVC.assetsGroup = [_assetGroups objectAtIndex:indexPath.row];

    [self.navigationController pushViewController:assetsVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}


@end
