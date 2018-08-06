//
//  ViewController.m
//  IQMediaPickerController
//
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//

@import AVFoundation;
@import AVKit;
@import MediaPlayer;
@import Photos;

#import "ViewController.h"
#import "IQMediaPickerController.h"
//#import "IQImagePreviewViewController.h"
#import "AudioTableViewCell.h"
#import "VideoTableViewCell.h"
#import "PhotoTableViewCell.h"

@interface ViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) BOOL multiPickerSwitch;
@property (nonatomic) BOOL pickingSourceCamera;
@property (nonatomic) BOOL photoPickerSwitch;
@property (nonatomic) BOOL videoPickerSwitch;
@property (nonatomic) BOOL audioPickerSwitch;
@property (nonatomic) BOOL rearCaptureSwitch;
@property (nonatomic) BOOL flashOffSwitch;

@end


@implementation ViewController
{
    IQMediaPickerSelection *selectedMedias;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _multiPickerSwitch = YES;
    _pickingSourceCamera = YES;
    _photoPickerSwitch = YES;
    _videoPickerSwitch = YES;
    _audioPickerSwitch = YES;
    _rearCaptureSwitch = YES;
    _flashOffSwitch = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)pickAction:(UIBarButtonItem *)sender
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setSourceType:self.pickingSourceCamera ? IQMediaPickerControllerSourceTypeCameraMicrophone : IQMediaPickerControllerSourceTypeLibrary];
    
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    
    if (self.audioPickerSwitch)
    {
        [mediaTypes addObject:@(PHAssetMediaTypeAudio)];
    }
    
    if (self.videoPickerSwitch)
    {
        [mediaTypes addObject:@(PHAssetMediaTypeVideo)];
    }
    
    if (self.photoPickerSwitch)
    {
        [mediaTypes addObject:@(PHAssetMediaTypeImage)];
    }
    
    [controller setMediaTypes:mediaTypes];
    controller.captureDevice = self.rearCaptureSwitch ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
//    controller.flashMode = self.flashOffSwitch.on ? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
//    controller.audioMaximumDuration = 10;
//    controller.videoMaximumDuration = 10;
    controller.allowsPickingMultipleItems = self.multiPickerSwitch;
//    controller.maximumItemCount = 5;
    controller.allowedVideoQualities = @[AVCaptureSessionPreset1920x1080,AVCaptureSessionPresetHigh];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)mediaPickerController:(IQMediaPickerController *)controller didFinishMedias:(IQMediaPickerSelection *)selection
{
    NSLog(@"Info: %@",selection);

    selectedMedias = selection;
    [self.tableView reloadData];
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
}

-(IBAction)multiPickerAction:(UISwitch*)aSwitch
{
    _multiPickerSwitch = aSwitch.on;
}

-(IBAction)pickingSourceCameraAction:(UISwitch*)aSwitch
{
    _pickingSourceCamera = aSwitch.on;
}

-(IBAction)photoPickerAction:(UISwitch*)aSwitch
{
    _photoPickerSwitch = aSwitch.on;
}

-(IBAction)videoPickerAction:(UISwitch*)aSwitch
{
    _videoPickerSwitch = aSwitch.on;
}

-(IBAction)audioPickerAction:(UISwitch*)aSwitch
{
    _audioPickerSwitch = aSwitch.on;
}

-(IBAction)rearCaptureAction:(UISwitch*)aSwitch
{
    _rearCaptureSwitch = aSwitch.on;
}

-(IBAction)flashOffAction:(UISwitch*)aSwitch
{
    _flashOffSwitch = aSwitch.on;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4 + 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Picker Settings";
            break;
        case 1:
            return @"Images";
            break;
        case 2:
            return @"Assets";
            break;
        case 3:
            return @"URL Assets";
            break;
        case 4:
            return @"Audios";
            break;
            
        default:
            return nil;
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 7;
            break;
        case 1:
            return selectedMedias.selectedImages.count;
            break;
        case 2:
            return selectedMedias.selectedAssets.count;
            break;
        case 3:
            return selectedMedias.selectedAssetsURL.count;
            break;
        case 4:
            return selectedMedias.selectedAudios.count;
            break;

        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            NSString *identifier = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            
            return cell;
        }
            break;
        case 1:
        {
            UIImage *image = selectedMedias.selectedImages[indexPath.row];
            
            PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoTableViewCell class]) forIndexPath:indexPath];
            
            cell.imageViewPhoto.image = image;
            
            return cell;
        }
            break;
        case 2:
        {
            PHAsset *result = selectedMedias.selectedAssets[indexPath.row];
            
            if (result.mediaType == PHAssetMediaTypeImage)
            {
                PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoTableViewCell class]) forIndexPath:indexPath];
                
                PHImageRequestOptions * options = [PHImageRequestOptions new];
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.synchronous = NO;
                
                [[PHImageManager defaultManager] requestImageForAsset:result targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    if (result)
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            cell.imageViewPhoto.image = result;
                        }];
                    }
                }];
                
                return cell;
            }
            else if (result.mediaType == PHAssetMediaTypeVideo)
            {
                VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VideoTableViewCell class]) forIndexPath:indexPath];
                cell.imageViewVideo.image = nil;
                cell.labelSubtitle.text = nil;
                
                PHVideoRequestOptions * options = [PHVideoRequestOptions new];
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:result options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    if ([asset isKindOfClass:[AVURLAsset class]])
                    {
                        AVURLAsset *urlAsset = (AVURLAsset*)asset;
                        NSURL *url = urlAsset.URL;
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            cell.labelTitle.text = [url relativePath];
                        }];
                    }
                }];
                
                return cell;
            }
            else
            {
                return nil;
            }
        }
            break;
        case 3:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
            }
            
            NSURL* url = selectedMedias.selectedAssetsURL[indexPath.row];
            
            cell.textLabel.text = [[NSFileManager defaultManager] displayNameAtPath:url.relativePath];
            
            return cell;
        }
            break;
        case 4:
        {
            MPMediaItem *item = selectedMedias.selectedAudios[indexPath.row];
            
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:artwork.bounds.size];
            
            AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AudioTableViewCell class]) forIndexPath:indexPath];
            
            cell.imageViewAudio.image = image;
            cell.labelTitle.text = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            cell.labelSubtitle.text = [[item valueForProperty:MPMediaItemPropertyAssetURL] relativePath];
            
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
        {
//            PhotoTableViewCell *cell = (PhotoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//
//            IQImagePreviewViewController *previewController = [[IQImagePreviewViewController alloc] init];
//            previewController.liftedImageView = cell.imageViewPhoto;
//            [previewController showOverController:self.navigationController];
        }
            break;
        case 2:
        {
            PHAsset *result = selectedMedias.selectedAssets[indexPath.row];
            
            if (result.mediaType == PHAssetMediaTypeImage)
            {
                PHImageRequestOptions * options = [PHImageRequestOptions new];
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.synchronous = NO;
                
                [[PHImageManager defaultManager] requestImageForAsset:result targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    if (result)
                    {
                        //                        cell.imageViewPhoto.image = result;
                    }
                }];
            }
            else if (result.mediaType == PHAssetMediaTypeVideo)
            {
                PHVideoRequestOptions * options = [PHVideoRequestOptions new];
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:result options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    if ([asset isKindOfClass:[AVURLAsset class]])
                    {
                        AVURLAsset *urlAsset = (AVURLAsset*)asset;
                        NSURL *url = urlAsset.URL;
                        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
                        controller.player = [AVPlayer playerWithURL:url];
                        [self presentViewController:controller animated:YES completion:nil];
                    }
                }];
            }
        }
            break;
        case 3:
        {
            NSURL* url = selectedMedias.selectedAssetsURL[indexPath.row];
            
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            controller.player = [AVPlayer playerWithURL:url];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 4:
        {
            MPMediaItem *item = selectedMedias.selectedAudios[indexPath.row];
            
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            controller.player = [AVPlayer playerWithURL:url];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
            
        default:
            return;
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

