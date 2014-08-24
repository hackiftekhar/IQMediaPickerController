//
//  IQAlbumAssetsViewController.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-14 Iftekhar Qurashi.
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


#import "IQAlbumAssetsViewController.h"
#import "IQAssetsCell.h"
#import "IQAssetsPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQMediaPickerControllerConstants.h"

@interface IQAlbumAssetsViewController () <UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    UIBarButtonItem *doneBarButton;
    
    BOOL _isPlayerPlaying;
    UIImage *_selectedImageToShare;
}

@property(nonatomic, strong) NSMutableIndexSet *selectedAssets;

@end

@implementation IQAlbumAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.assetController.allowsPickingMultipleItems == YES)
    {
        doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
        self.navigationItem.rightBarButtonItem = doneBarButton;
        doneBarButton.enabled = NO;
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *_flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    _flowLayout.minimumLineSpacing = 5.0f;
    _flowLayout.minimumInteritemSpacing = 5.0f;
    _flowLayout.sectionInset = UIEdgeInsetsMake(5.0f, 2.0f, 5.0f, 2.0f);
    _flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);

    [self.collectionView registerClass:[IQAssetsCell class] forCellWithReuseIdentifier:@"cell"];

    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    _selectedAssets = [[NSMutableIndexSet alloc] init];
    
    if (_pickerType == IQAssetsPickerControllerAssetTypeVideo)
    {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizer:)];
        [self.collectionView addGestureRecognizer:longPressGesture];
        longPressGesture.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        
        if (indexPath)
        {
            [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
             {
                 if (result)
                 {
                     NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
                     
                     if (url)
                     {
                         MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                         [self presentMoviePlayerViewControllerAnimated:controller];
                     }
                 }
             }];
        }
    }
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    NSMutableArray *selectedVideo = [[NSMutableArray alloc] init];
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    
    [self.assetsGroup enumerateAssetsAtIndexes:self.selectedAssets options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result)
        {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
            {
                CGImageRef imageRef = [[result defaultRepresentation] fullResolutionImage];
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                
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
    }];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([selectedImages count]) [dict setObject:selectedImages forKey:IQMediaTypeImage];
    if ([selectedVideo count])  [dict setObject:selectedVideo forKey:IQMediaTypeVideo];
    
    if ([self.assetController.delegate respondsToSelector:@selector(assetsPickerController:didFinishMediaWithInfo:)])
    {
        [self.assetController.delegate assetsPickerController:self.assetController didFinishMediaWithInfo:dict];
    }
    
    [self.assetController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    __block CGSize thumbnailSize = CGSizeMake(80, 80);

//    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
//     {
//         if (result)
//         {
//             thumbnailSize = [[result defaultRepresentation] dimensions];
//             CGFloat deviceCellSizeConstant = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.height;
//             thumbnailSize = CGSizeMake((thumbnailSize.width*deviceCellSizeConstant)/thumbnailSize.height, deviceCellSizeConstant);
//         }
//         else
//         {
//             *stop = YES;
//         }
//     }];

//    return thumbnailSize;
//}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    IQAssetsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (result)
         {
             CGImageRef thumbnail = [result aspectRatioThumbnail];
             UIImage *imageThumbnail = [UIImage imageWithCGImage:thumbnail];
             cell.imageViewAsset.image = imageThumbnail;
             
             if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo && ([result valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty))
             {
                 NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
                 NSUInteger seconds = [duration doubleValue];

                 {
                     NSUInteger totalMinutes = seconds/60;
                     NSUInteger totalSeconds = ((NSUInteger)seconds)%60;
                     
                     CGFloat reminder = seconds-(totalMinutes*60)-totalSeconds;
                     
                     totalSeconds+=roundf(reminder);
                     
                     if (totalSeconds>= 60)
                     {
                         totalMinutes++;
                         totalSeconds = 0;
                     }
                     
                     cell.labelDuration.text = [NSString stringWithFormat:@"%ld:%02ld",(long)totalMinutes,(unsigned long)totalSeconds];
                     cell.labelDuration.hidden = NO;
                 }
             }
             else if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto)
             {
                 cell.labelDuration.hidden = YES;
             }
         }
     }];
    
    BOOL selected = [self.selectedAssets containsIndex:indexPath.row];

    cell.checkmarkView.alpha = selected?1.0:0.0;

    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsCell *cell = (IQAssetsCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL previouslyContainsIndex = [self.selectedAssets containsIndex:indexPath.row];
    
    if (previouslyContainsIndex)
    {
        [self.selectedAssets removeIndex:indexPath.row];
    }
    else
    {
        [self.selectedAssets addIndex:indexPath.row];
    }
    
    
    if (self.assetController.allowsPickingMultipleItems == NO)
    {
        NSMutableArray *selectedVideo = [[NSMutableArray alloc] init];
        NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
        
        [self.assetsGroup enumerateAssetsAtIndexes:self.selectedAssets options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result)
            {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                {
                    CGImageRef imageRef = [[result defaultRepresentation] fullResolutionImage];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    
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
        }];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        if ([selectedImages count]) [dict setObject:selectedImages forKey:IQMediaTypeImage];
        if ([selectedVideo count])  [dict setObject:selectedVideo forKey:IQMediaTypeVideo];
        
        if ([self.assetController.delegate respondsToSelector:@selector(assetsPickerController:didFinishMediaWithInfo:)])
        {
            [self.assetController.delegate assetsPickerController:self.assetController didFinishMediaWithInfo:dict];
        }
        
        [self.assetController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            if ([self.selectedAssets count])
            {
                doneBarButton.enabled = YES;
                
                if (_pickerType == IQAssetsPickerControllerAssetTypePhoto)
                {
                    self.title = [NSString stringWithFormat:@"%lu %@ selected",(unsigned long)[self.selectedAssets count],self.selectedAssets.count>1?@"Photos":@"Photo"];
                }
                else if (_pickerType == IQAssetsPickerControllerAssetTypeVideo)
                {
                    self.title = [NSString stringWithFormat:@"%lu %@ selected",(unsigned long)[self.selectedAssets count],self.selectedAssets.count>1?@"Videos":@"Video"];
                }
                else
                {
                    self.title = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.selectedAssets count]];
                }
            }
            else
            {
                doneBarButton.enabled = NO;
                self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
            }
            
            
            cell.checkmarkView.alpha = previouslyContainsIndex?0.0:1.0;
            
        } completion:NULL];
    }
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    if ([aNotification.name isEqualToString: MPMoviePlayerPlaybackDidFinishNotification]) {
        NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
        {
            MPMoviePlayerController *moviePlayer = [aNotification object];
            
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackDidFinishNotification
                                                          object:moviePlayer];
            [self dismissViewControllerAnimated:YES completion:^{  }];
        }
//        self.collectionView.userInteractionEnabled = YES;
        _isPlayerPlaying = NO;
    }
}


@end
