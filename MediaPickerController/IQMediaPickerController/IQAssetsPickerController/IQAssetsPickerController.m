//
//  IQAssetsPickerController.m
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


#import "IQAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQAssetsAlbumViewCell.h"

@interface IQAssetsPickerController ()

@property(nonatomic, strong) ALAssetsLibrary *assetLibrary;

@property UIBarButtonItem *cancelBarButton;
@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@end

@implementation IQAssetsPickerController
{
    NSMutableArray *_assetGroups;
}

#pragma - mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectedItems = [[NSMutableArray alloc] init];

    [self.navigationItem setTitle:@"Albums"];
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    self.cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:self.cancelBarButton];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.selectedMediaCountItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedMediaCountItem.possibleTitles = [NSSet setWithObject:@"999 media selected"];
    self.selectedMediaCountItem.enabled = NO;
    
    self.toolbarItems = @[flexItem,self.selectedMediaCountItem,flexItem];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[IQAssetsAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class])];
    
    _assetGroups = [[NSMutableArray alloc] init];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^{
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (group == nil)
            {
                return;
            }
            
            NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
            NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            
            if ((self.pickerType & IQMediaPickerControllerMediaTypePhoto) && (self.pickerType & IQMediaPickerControllerMediaTypeVideo))
            {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
            }
            else if (self.pickerType & IQMediaPickerControllerMediaTypePhoto)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }
            else if (self.pickerType & IQMediaPickerControllerMediaTypeVideo)
            {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
            }
            
            if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                [_assetGroups insertObject:group atIndex:0];
            }
            else {
                [_assetGroups addObject:group];
            }
            
            [self.tableView reloadData];
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        };
        
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    [self updateSelectedCount];
}

-(void)updateSelectedCount
{
    if ([self.selectedItems count])
    {
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];

        [self.navigationController setToolbarHidden:NO animated:YES];
        self.selectedMediaCountItem.title = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.selectedItems count]];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        self.selectedMediaCountItem.title = nil;
    }
}

-(void)sendFinalSelectedAssets
{
    NSMutableArray *selectedVideo = [[NSMutableArray alloc] init];
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    
    for (ALAsset *result in self.selectedItems)
    {
        if (result)
        {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
            {
                CGImageRef imageRef = [[result defaultRepresentation] fullResolutionImage];
                
                UIImageOrientation orienatation;
                
                switch (result.defaultRepresentation.orientation)
                {
                    case ALAssetOrientationUp:              orienatation = UIImageOrientationUp;            break;
                    case ALAssetOrientationDown:            orienatation = UIImageOrientationDown;          break;
                    case ALAssetOrientationLeft:            orienatation = UIImageOrientationLeft;          break;
                    case ALAssetOrientationRight:           orienatation = UIImageOrientationRight;         break;
                    case ALAssetOrientationUpMirrored:      orienatation = UIImageOrientationUpMirrored;    break;
                    case ALAssetOrientationDownMirrored:    orienatation = UIImageOrientationDownMirrored;  break;
                    case ALAssetOrientationLeftMirrored:    orienatation = UIImageOrientationLeftMirrored;  break;
                    case ALAssetOrientationRightMirrored:   orienatation = UIImageOrientationRightMirrored; break;
                }
                
                UIImage *image = [UIImage imageWithCGImage:imageRef scale:result.defaultRepresentation.scale orientation:orienatation];
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:image,IQMediaImage, nil];
                
                [selectedImages addObject:dict];
            }
            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
            {
                ALAssetRepresentation *representation = [result defaultRepresentation];
                NSURL *url = [representation url];
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,IQMediaAssetURL, nil];
                
                [selectedVideo addObject:dict];
            }
        }
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([selectedImages count]) [dict setObject:selectedImages forKey:IQMediaTypeImage];
    if ([selectedVideo count])  [dict setObject:selectedVideo forKey:IQMediaTypeVideo];
    
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishMediaWithInfo:)])
    {
        [self.delegate assetsPickerController:self didFinishMediaWithInfo:dict];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    [self sendFinalSelectedAssets];
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
    {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class]) forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    ALAssetsGroup *group = (ALAssetsGroup*)[_assetGroups objectAtIndex:indexPath.row];

    [cell.imageViewAlbum setImage:[UIImage imageWithCGImage:[group posterImage]]];
    cell.labelTitle.text = [group valueForProperty:ALAssetsGroupPropertyName];

    NSUInteger photos = 0;
    NSUInteger videos = 0;
    
    
    if ((self.pickerType & IQMediaPickerControllerMediaTypePhoto) && (self.pickerType & IQMediaPickerControllerMediaTypeVideo))
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        photos = [group numberOfAssets];

        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        videos = [group numberOfAssets];

        [group setAssetsFilter:[ALAssetsFilter allAssets]];

        NSMutableArray *stringsArray = [[NSMutableArray alloc] init];
        
        if (photos > 0)
        {
            [stringsArray addObject:[NSString stringWithFormat:@"%lu %@",(unsigned long)photos, photos>1?@"Photos":@"Photo"]];
        }
        else
        {
            [stringsArray addObject:@"No photos"];
        }

        if (videos > 0)
        {
            [stringsArray addObject:[NSString stringWithFormat:@"%lu %@",(unsigned long)videos, videos>1?@"Videos":@"Video"]];
        }
        else
        {
            [stringsArray addObject:@"No videos"];
        }
        
        cell.labelSubTitle.text = [stringsArray componentsJoinedByString:@", "];
    }
    else if (self.pickerType & IQMediaPickerControllerMediaTypePhoto)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        photos = [group numberOfAssets];

        if (photos > 0)
        {
            cell.labelSubTitle.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)photos, photos>1?@"Photos":@"Photo"];
        }
        else
        {
            cell.labelSubTitle.text = @"No photos";
        }
    }
    else if (self.pickerType & IQMediaPickerControllerMediaTypeVideo)
    {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        videos = [group numberOfAssets];

        if (videos > 0)
        {
            cell.labelSubTitle.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)videos, videos>1?@"Videos":@"Video"];
        }
        else
        {
            cell.labelSubTitle.text = @"No videos";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAlbumAssetsViewController *assetsVC = [[IQAlbumAssetsViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    assetsVC.pickerType = self.pickerType;
    assetsVC.assetsGroup = [_assetGroups objectAtIndex:indexPath.row];
    assetsVC.assetController = self;
    [self.navigationController pushViewController:assetsVC animated:YES];
}

@end
