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


#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHAsset.h>
#import <Photos/PHCollection.h>
#import <Photos/PHImageManager.h>
#import <AVKit/AVPlayerViewController.h>
#import <AVFoundation/AVAsset.h>

#import "IQAlbumAssetsViewController.h"
#import "IQAssetsCell.h"
#import "IQAssetsPickerController.h"

@interface IQAlbumAssetsViewController () <UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    
    UIImage *_selectedImageToShare;
}

@property PHFetchResult * fetchResult;

@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@end

@implementation IQAlbumAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    
    NSMutableArray<NSPredicate*> *predicates = [[NSMutableArray alloc] init];
    
    for (NSNumber *mediaType in self.mediaTypes) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %@",mediaType];
        [predicates addObject:predicate];
    }
    
    NSCompoundPredicate *finalPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
    
    options.predicate = finalPredicate;
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:options];
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = self.doneBarButton;
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.selectedMediaCountItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedMediaCountItem.possibleTitles = [NSSet setWithObject:@"999 media selected"];
    self.selectedMediaCountItem.enabled = NO;
    
    self.toolbarItems = @[flexItem,self.selectedMediaCountItem,flexItem];
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;

    UICollectionViewFlowLayout *_flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    _flowLayout.minimumLineSpacing = _flowLayout.minimumInteritemSpacing = 1.0f;
    _flowLayout.headerReferenceSize = _flowLayout.footerReferenceSize = CGSizeMake(1, 1);
    
    NSUInteger numberOfItemsPerRow = 4;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        numberOfItemsPerRow = 10;
    }
    
    CGFloat minWidth = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGFloat size = (minWidth - (_flowLayout.minimumLineSpacing * (numberOfItemsPerRow+1)))/numberOfItemsPerRow;
    _flowLayout.itemSize = CGSizeMake(size, size);

    [self.collectionView registerClass:[IQAssetsCell class] forCellWithReuseIdentifier:@"cell"];

    self.navigationItem.title = self.collection.localizedTitle;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    [self.collectionView addGestureRecognizer:longPressGesture];
    longPressGesture.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSelectedCountAnimated:animated];
    
    NSInteger section = [self.collectionView numberOfSections] - 1;
    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
    
    if (section >= 0 && item >= 0)
    {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];

        [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

-(void)updateSelectedCountAnimated:(BOOL)animated
{
    if ([self.assetController.selectedItems count])
    {
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:animated];
        [self.navigationController setToolbarHidden:NO animated:animated];
        
        NSString *finalText = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.assetController.selectedItems count]];
        
        if (self.assetController.maximumItemCount > 0)
        {
            finalText = [finalText stringByAppendingFormat:@" (%lu maximum) ",(unsigned long)self.assetController.maximumItemCount];
        }
        self.selectedMediaCountItem.title = finalText;
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
        [self.navigationController setToolbarHidden:YES animated:animated];
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
            PHAsset *asset = self.fetchResult[indexPath.row];

            if (asset.mediaType == PHAssetMediaTypeVideo)
            {
                PHVideoRequestOptions * options = [PHVideoRequestOptions new];
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    if ([asset isKindOfClass:[AVURLAsset class]])
                    {
                        AVURLAsset *urlAsset = (AVURLAsset*)asset;
                        
                        void (^threadSafeBlock)(void) = ^{
                            
                            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
                            controller.player = [AVPlayer playerWithURL:urlAsset.URL];
                            [self presentViewController:controller animated:YES completion:nil];
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
        }
    }
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    [self.assetController sendFinalSelectedAssets];
}

#pragma mark - UICollectionViewDataSource methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.fetchResult.count == 0)
    {
        return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height-100);
    }
    else
    {
        return CGSizeZero;
    }
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if (kind == UICollectionElementKindSectionHeader) {
//        
//        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
//        view.backgroundColor = [UIColor clearColor];
//        if (self.fetchResult.count == 0)
//        {
//            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMidY(view.bounds)-20, view.frame.size.width-40, 40)];
//            label1.font = [UIFont boldSystemFontOfSize:25.0];
//            label1.numberOfLines = 0;
//            label1.textAlignment = NSTextAlignmentCenter;
//            label1.textColor = [UIColor darkGrayColor];
//            label1.text = @"No Photos";
//            [view addSubview:label1];
//        }
//        return view;
//    } else {
//        
//        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
//        return view;
//    }
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.fetchResult.count == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame)-20, 0)];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        
        NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0],NSForegroundColorAttributeName:[UIColor darkGrayColor]};
        NSDictionary *messageAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor grayColor]};
        
        if (self.mediaTypes.count == 1 && [self.mediaTypes containsObject:@(PHAssetMediaTypeImage)])
        {
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"No Photos" attributes:titleAttributes];
            NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:@"\nThis album contains no photos" attributes:messageAttributes];
            NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] init];
            [finalMessage appendAttributedString:attributedTitle];
            [finalMessage appendAttributedString:attributedMessage];
            label.attributedText = finalMessage;
        }
        else if (self.mediaTypes.count == 1 && [self.mediaTypes containsObject:@(PHAssetMediaTypeVideo)])
        {
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"No Videos" attributes:titleAttributes];
            NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:@"\nThis album contains no videos" attributes:messageAttributes];
            NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] init];
            [finalMessage appendAttributedString:attributedTitle];
            [finalMessage appendAttributedString:attributedMessage];
            label.attributedText = finalMessage;
        }
        else
        {
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"No Media" attributes:titleAttributes];
            NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:@"\nThis album contains no medias" attributes:messageAttributes];
            NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] init];
            [finalMessage appendAttributedString:attributedTitle];
            [finalMessage appendAttributedString:attributedMessage];
            label.attributedText = finalMessage;
        }
        
        CGSize labelNewSize = [label sizeThatFits:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)];
        
        label.frame = CGRectMake(0, 0, label.frame.size.width, labelNewSize.height);

        collectionView.backgroundView = label;
    }
    else
    {
        collectionView.backgroundView = nil;
    }
    
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    IQAssetsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.checkmarkView.alpha = 0.0;
    
    PHAsset *asset = self.fetchResult[indexPath.row];

    cell.asset = asset;
    cell.checkmarkView.alpha = ([self.assetController.selectedItems containsObject:asset])?1.0:0.0;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsCell *cell = (IQAssetsCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.row];
    
    if ([self.assetController.selectedItems containsObject:asset])
    {
        [self.assetController.selectedItems removeObject:asset];
        cell.checkmarkView.alpha = 0.0;
    }
    else
    {
        [self.assetController.selectedItems addObject:asset];
        cell.checkmarkView.alpha = 1.0;
    }
    
    if (self.assetController.allowsPickingMultipleItems == NO)
    {
        [self.assetController sendFinalSelectedAssets];
    }

    [self updateSelectedCountAnimated:YES];
}

//-(void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView
//{
//    NSInteger section = [self.collectionView numberOfSections] - 1;
//    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
//
//    if (section >= 0 && item >= 0)
//    {
//        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
//
//        [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    }
//}

-(void)setMediaTypes:(NSArray<NSNumber *> *)mediaTypes
{
    _mediaTypes = [[NSMutableOrderedSet orderedSetWithArray:mediaTypes] array];
}

@end
