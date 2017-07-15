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

#import "AudioTableViewCell.h"
#import "VideoTableViewCell.h"
#import "PhotoTableViewCell.h"

@interface ViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISwitch *multiPickerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *pickingSourceCamera;
@property (strong, nonatomic) IBOutlet UISwitch *photoPickerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *videoPickerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *audioPickerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *rearCaptureSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *flashOffSwitch;

@end


@implementation ViewController
{
    NSDictionary *mediaInfo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [controller setSourceType:self.pickingSourceCamera.on ? IQMediaPickerControllerSourceTypeCameraMicrophone : IQMediaPickerControllerSourceTypeLibrary];
    
    IQMediaPickerControllerMediaType mediaType = 0;
    
    if (self.photoPickerSwitch.on)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypePhoto;
    }
    
    if (self.videoPickerSwitch.on)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypeVideo;
    }
    
    if (self.audioPickerSwitch.on)
    {
        mediaType = mediaType | IQMediaPickerControllerMediaTypeAudio;
    }
    
    [controller setMediaType:mediaType];
    controller.captureDevice = self.rearCaptureSwitch.on ? IQMediaPickerControllerCameraDeviceRear : IQMediaPickerControllerCameraDeviceFront;
//    controller.flashMode = self.flashOffSwitch.on ? IQMediaPickerControllerCameraFlashModeOff : IQMediaPickerControllerCameraFlashModeOn;
    
    controller.allowsPickingMultipleItems = self.multiPickerSwitch.on;
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [mediaInfo count] + 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [super tableView:tableView titleForHeaderInSection:section];
    }
    else
    {
        return [[mediaInfo allKeys] objectAtIndex:section];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:section];
        return [[mediaInfo objectForKey:key] count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
        
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
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else
    {
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
        
        NSDictionary *dict = [[mediaInfo objectForKey:key] objectAtIndex:indexPath.row];
        
        if ([dict objectForKey:IQMediaItem])
        {
            MPMediaItem *item = [dict objectForKey:IQMediaItem];
            
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *image = [artwork imageWithSize:artwork.bounds.size];
            
            AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AudioTableViewCell class])];
            
            cell.imageViewAudio.image = image;
            cell.labelTitle.text = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            cell.labelSubtitle.text = [[item valueForProperty:MPMediaItemPropertyAssetURL] relativePath];
            
            return cell;
        }
        else if([dict objectForKey:IQMediaAssetURL])
        {
            VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VideoTableViewCell class])];
            cell.imageViewVideo.image = nil;
            NSURL *url = [dict objectForKey:IQMediaAssetURL];
            cell.labelTitle.text = [url relativePath];
            cell.labelSubtitle.text = nil;
            return cell;
        }
        else if ([dict objectForKey:IQMediaImage])
        {
            UIImage *image = [dict objectForKey:IQMediaImage];
            
            PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoTableViewCell class])];
            
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
            
            NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
            
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
        NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
        
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
            //        UIImage *image = [dict objectForKey:IQMediaImage];
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

