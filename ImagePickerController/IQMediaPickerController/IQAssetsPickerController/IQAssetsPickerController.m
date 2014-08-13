
#import "IQAssetsPickerController.h"
#import "IQCustomCell.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "IQ_SGSStaggeredFlowLayout.h"

@interface IQAssetsPickerController () <UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    BOOL _isPlayerPlaying;
    UIImage *_selectedImageToShare;
}

@property(nonatomic, strong) NSMutableArray *info;
@property(nonatomic, strong) NSMutableArray *checkedAssetsNumbers;

@end

@implementation IQAssetsPickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    IQ_SGSStaggeredFlowLayout *_flowLayout = (IQ_SGSStaggeredFlowLayout*)self.collectionViewLayout;
    _flowLayout.layoutMode = IQ_SGSStaggeredFlowLayoutMode_Even;
    _flowLayout.minimumLineSpacing = 7.0f;
    _flowLayout.minimumInteritemSpacing = 7.0f;
    _flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    _flowLayout.itemSize = CGSizeMake(75.0f, 75.0f);

    [self.collectionView registerClass:[IQCustomCell class] forCellWithReuseIdentifier:@"cell"];

//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
//    [self.collectionView addGestureRecognizer:longPressGesture];
//    longPressGesture.delegate = self;
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    _checkedAssetsNumbers = [NSMutableArray arrayWithCapacity:[[self assetsGroup] numberOfAssets]];
    for (int i = 0; i < [[self assetsGroup] numberOfAssets]; i++)
    {
        [_checkedAssetsNumbers addObject:[NSNull null]];
    }
    
    if (_pickerType == IQAssetsPickerControllerAssetTypeVideo)
    {
//        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
//        [self.collectionView addGestureRecognizer:longPressGesture];
//        longPressGesture.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
//    self.collectionView.userInteractionEnabled = NO;
//    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
//    
//    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
//    if (indexPath == nil)
//        NSLog(@"Long press on collection view but not on a row");
//    else{
//        NSLog(@"long press on collection view at row %ld", (long)indexPath.row);
//        
//        [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
//         {
//             if (result)
//             {
//                 [self playAlAsset:result];
//             }
//         }];
//    }
}

- (void)doneBtnClicked:(UIButton *)sender
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        BOOL isUserCheckAssets = NO;
        for (int i = 0; i < [[self assetsGroup] numberOfAssets]; i++)
        {
            if (![strongSelf.checkedAssetsNumbers[i] isEqual:[NSNull null]]) {
                isUserCheckAssets = YES;
            }
        }
        if (isUserCheckAssets) {
            strongSelf.info = [NSMutableArray array];
            for (int i = 0; i < [[self assetsGroup] numberOfAssets]; i++)
            {
                if (strongSelf.checkedAssetsNumbers[i] != [NSNull null])
                {
                    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        [strongSelf.info addObject:[[result valueForProperty:ALAssetPropertyURLs] valueForKey:[[[result valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]]];
                    }];
                }
            }
//            if ([(strongSelf.navigationController)).imagePickerDelegate respondsToSelector:@selector(imagePicker:didFinishPickingWithMediaInfo:)]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self dismissViewControllerAnimated:YES completion:^{
//                        [((SNImagePickerNavigationController *)(strongSelf.navigationController)).imagePickerDelegate imagePicker:((SNImagePickerNavigationController *)(strongSelf.navigationController)) didFinishPickingWithMediaInfo:strongSelf.info];
//                    }];
//                });
//            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{  }];
            });
        }
    });
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block CGSize thumbnailSize = CGSizeMake(150, 150);
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (result)
         {
             thumbnailSize = [[result defaultRepresentation] dimensions];
             CGFloat deviceCellSizeConstant = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.height;
             thumbnailSize = CGSizeMake((thumbnailSize.width*deviceCellSizeConstant)/thumbnailSize.height, deviceCellSizeConstant);
         }
         else
         {
             *stop = YES;
         }
     }];

    return thumbnailSize;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    IQCustomCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self.assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (result)
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                 CGImageRef thumbnail = [result aspectRatioThumbnail];
                 UIImage *imageThumbnail = [UIImage imageWithCGImage:thumbnail];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     cell.imageView.image = imageThumbnail;
                 });
             });
             
             if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo && ([result valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty))
             {
                 NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
                 
                 cell.duration.text = [self timeFormatted:[duration doubleValue]];
                 cell.duration.hidden = NO;
             }
             else if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto)
             {
                 cell.duration.hidden = YES;
             }
         }
     }];
    
    return cell;
}

- (NSString *)timeFormatted:(NSTimeInterval)totalSeconds
{
    int minutes = ((NSUInteger)totalSeconds / 60);
    int seconds = minutes % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IQCustomCell *cell = (IQCustomCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.check.hidden)
    {
        [self.checkedAssetsNumbers replaceObjectAtIndex:indexPath.row withObject:@1];
        cell.check.hidden = NO;
    }
    else
    {
        [self.checkedAssetsNumbers replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
        cell.check.hidden = YES;
    }
}

#pragma mark - Play Movie

-(void)playAlAsset:(ALAsset *)asset
{
    if (!_isPlayerPlaying)
    {
        _isPlayerPlaying = YES;
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        [[NSNotificationCenter defaultCenter] removeObserver:controller
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:controller.moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:controller.moviePlayer];
        
       controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:controller animated:YES completion:^{
            NSLog(@"done present player");
        }];
        
        [controller.moviePlayer setFullscreen:NO];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];
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
