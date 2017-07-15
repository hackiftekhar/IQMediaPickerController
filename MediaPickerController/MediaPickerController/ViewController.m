//
//  ViewController.m
//  IQMediaPickerController
//
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//

#import "ViewController.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "IQImagePreviewViewController.h"

#import "AudioTableViewCell.h"
#import "VideoTableViewCell.h"
#import "PhotoTableViewCell.h"

@interface ViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@property (assign, nonatomic) BOOL multiPickerSwitch;
@property (assign, nonatomic) BOOL pickingSourceCamera;
@property (assign, nonatomic) BOOL photoPickerSwitch;
@property (assign, nonatomic) BOOL videoPickerSwitch;
@property (assign, nonatomic) BOOL audioPickerSwitch;
@property (assign, nonatomic) BOOL rearCaptureSwitch;
@property (assign, nonatomic) BOOL flashOffSwitch;


@end


@implementation ViewController
{
    NSDictionary *mediaInfo;
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
    
    IQMediaPickerControllerMediaType mediaType = 0;
    
    if (self.photoPickerSwitch)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypePhoto;
    }
    
    if (self.videoPickerSwitch)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypeVideo;
    }
    
    if (self.audioPickerSwitch)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypeAudio;
    }
    
    [controller setMediaType:mediaType];
    controller.captureDevice = self.rearCaptureSwitch ? IQMediaPickerControllerCameraDeviceRear : IQMediaPickerControllerCameraDeviceFront;
//    controller.flashMode = self.flashOffSwitch.on ? IQMediaPickerControllerCameraFlashModeOff : IQMediaPickerControllerCameraFlashModeOn;
//    controller.audioMaximumDuration = 10;
//    controller.videoMaximumDuration = 10;
    controller.allowsPickingMultipleItems = self.multiPickerSwitch;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    NSLog(@"Info: %@",info);

    mediaInfo = [info copy];
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
    return [mediaInfo count] + 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Picker Settings";
    }
    else
    {
        return [[mediaInfo allKeys] objectAtIndex:section-1];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 7;
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:section-1];
        return [[mediaInfo objectForKey:key] count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section-1];
        
        if ([key isEqualToString:IQMediaTypeImage])
        {
            return 80;
        }
        else
        {
            return tableView.rowHeight;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSString *identifier = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

        return cell;
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section-1];
        
        NSDictionary *dict = [[mediaInfo objectForKey:key] objectAtIndex:indexPath.row];
        
        if ([dict objectForKey:IQMediaItem])
        {
            MPMediaItem *item = [dict objectForKey:IQMediaItem];
            
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:artwork.bounds.size];
            
            AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AudioTableViewCell class]) forIndexPath:indexPath];
            
            cell.imageViewAudio.image = image;
            cell.labelTitle.text = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            cell.labelSubtitle.text = [[item valueForProperty:MPMediaItemPropertyAssetURL] relativePath];
            
            return cell;
        }
        else if([dict objectForKey:IQMediaAssetURL])
        {
            VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VideoTableViewCell class]) forIndexPath:indexPath];
            cell.imageViewVideo.image = nil;
            NSURL *url = [dict objectForKey:IQMediaAssetURL];
            cell.labelTitle.text = [url relativePath];
            cell.labelSubtitle.text = nil;
            return cell;
        }
        else if ([dict objectForKey:IQMediaImage])
        {
            UIImage *image = [dict objectForKey:IQMediaImage];
            
            PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoTableViewCell class]) forIndexPath:indexPath];
            
            cell.imageViewPhoto.image = image;
            
            return cell;
        }
        else if ([dict objectForKey:IQMediaURL])
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
            }
            
            NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section-1];
            
            NSURL *url = [[[mediaInfo objectForKey:key] objectAtIndex:indexPath.row] objectForKey:IQMediaURL];
            cell.textLabel.text = [[NSFileManager defaultManager] displayNameAtPath:url.relativePath];
            
            return cell;
        }
        else
        {
            return nil;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section-1];
        
        NSDictionary *dict = [[mediaInfo objectForKey:key] objectAtIndex:indexPath.row];
        
        if ([dict objectForKey:IQMediaItem])
        {
            MPMediaItem *item = [dict objectForKey:IQMediaItem];
            
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }
        else if([dict objectForKey:IQMediaAssetURL])
        {
            NSURL *url = [dict objectForKey:IQMediaAssetURL];
            
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }
        else if ([dict objectForKey:IQMediaImage])
        {
            PhotoTableViewCell *cell = (PhotoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            
            IQImagePreviewViewController *previewController = [[IQImagePreviewViewController alloc] init];
            previewController.liftedImageView = cell.imageViewPhoto;
            [previewController showOverController:self.navigationController];

        }
        else if ([dict objectForKey:IQMediaURL])
        {
            NSURL *url = [[[mediaInfo objectForKey:key] objectAtIndex:indexPath.row] objectForKey:IQMediaURL];
            
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

