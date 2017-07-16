//
//  IQAlbumAssetsViewController.m
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


#import "IQAlbumAssetsViewController.h"
#import "IQAssetsCell.h"
#import "IQAssetsPickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQMediaPickerControllerConstants.h"

@interface IQAlbumAssetsViewController () <UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    
    BOOL _isPlayerPlaying;
    UIImage *_selectedImageToShare;
}

@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@end

@implementation IQAlbumAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = self.doneBarButton;
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.selectedMediaCountItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedMediaCountItem.possibleTitles = [NSSet setWithObject:@"999 media selected"];
    self.selectedMediaCountItem.enabled = NO;
    
    self.toolbarItems = @[flexItem,self.selectedMediaCountItem,flexItem];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;

    UICollectionViewFlowLayout *_flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    _flowLayout.minimumLineSpacing = _flowLayout.minimumInteritemSpacing = 1.0f;
    
    NSUInteger numberOfItemsPerRow = 3;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        numberOfItemsPerRow = 10;
    }
    
    CGFloat minWidth = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGFloat size = (minWidth - (_flowLayout.minimumLineSpacing * (numberOfItemsPerRow+1)))/numberOfItemsPerRow;
    _flowLayout.itemSize =  CGSizeMake(size, size);

    [self.collectionView registerClass:[IQAssetsCell class] forCellWithReuseIdentifier:@"cell"];

    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    [self.collectionView addGestureRecognizer:longPressGesture];
    longPressGesture.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSelectedCount];
    
    NSInteger section = [self.collectionView numberOfSections] - 1;
    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
    
    if (section >= 0 && item >= 0)
    {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];

        [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

-(void)updateSelectedCount
{
    if ([self.assetController.selectedItems count])
    {
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
        
        NSString *finalText = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.assetController.selectedItems count]];
        
        if (self.assetController.maximumItemCount > 0)
        {
            finalText = [finalText stringByAppendingFormat:@" (%lu maximum) ",self.assetController.maximumItemCount];
        }
        self.selectedMediaCountItem.title = finalText;
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        self.selectedMediaCountItem.title = nil;
    }
}

-(void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        
        if (indexPath)
        {
            [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
             {
                 if (result)
                 {
                     NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
                     
                     if (url)
                     {
                         void (^threadSafeBlock)() = ^{
                             
                             MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                             [self presentMoviePlayerViewControllerAnimated:controller];
                         };
                         
                         if ([NSThread isMainThread])
                         {
                             threadSafeBlock();
                         }
                         else
                         {
                             dispatch_sync(dispatch_get_main_queue(), ^{
                                 threadSafeBlock();
                             });
                         }
                     }
                 }
             }];
        }
    }
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    [self.assetController sendFinalSelectedAssets];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    IQAssetsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.checkmarkView.alpha = 0.0;
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (result)
         {
             BOOL selected = NO;
             NSString *durationText = nil;

             for (ALAsset *selectedAsset in self.assetController.selectedItems)
             {
                 if ([selectedAsset.defaultRepresentation.url isEqual:result.defaultRepresentation.url])
                 {
                     selected = YES;
                     break;
                 }
             }

             CGImageRef thumbnail = [result aspectRatioThumbnail];
             UIImage *imageThumbnail = [UIImage imageWithCGImage:thumbnail];
             
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
                     
                     durationText = [NSString stringWithFormat:@"%ld:%02ld",(long)totalMinutes,(unsigned long)totalSeconds];
                 }
             }
             
             void (^threadSafeBlock)() = ^{
                 
                 cell.imageViewAsset.image = imageThumbnail;
                 cell.checkmarkView.alpha = selected?1.0:0.0;
                 cell.labelDuration.text = durationText;
             };
             
             if ([NSThread isMainThread])
             {
                 threadSafeBlock();
             }
             else
             {
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     threadSafeBlock();
                 });
             }
         }
     }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsCell *cell = (IQAssetsCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         BOOL selected = NO;

         if (result)
         {
             for (ALAsset *selectedAsset in [self.assetController.selectedItems reverseObjectEnumerator])
             {
                 if ([selectedAsset.defaultRepresentation.url isEqual:result.defaultRepresentation.url])
                 {
                     selected = YES;
                     [self.assetController.selectedItems removeObject:selectedAsset];
                     break;
                 }
             }

             if (selected == NO)
             {
                 NSUInteger count = self.assetController.selectedItems.count;
                 
                 if (self.assetController.maximumItemCount == 0 || self.assetController.maximumItemCount > count)
                 {
                     [self.assetController.selectedItems addObject:result];
                 }
                 else
                 {
                     selected = YES;
                 }
             }
             
             if (self.assetController.allowsPickingMultipleItems == NO)
             {
                 [self.assetController sendFinalSelectedAssets];
             }

             void (^threadSafeBlock)() = ^{
                 
                 [self updateSelectedCount];
                 cell.checkmarkView.alpha = selected?0.0:1.0;
             };
             
             if ([NSThread isMainThread])
             {
                 threadSafeBlock();
             }
             else
             {
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     threadSafeBlock();
                 });
             }
         }
     }];
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

-(void)setMediaTypes:(NSArray<NSNumber *> *)mediaTypes
{
    _mediaTypes = [[NSMutableOrderedSet orderedSetWithArray:mediaTypes] array];
}

@end
