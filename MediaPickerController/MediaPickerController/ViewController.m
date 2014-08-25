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

@end


@implementation ViewController
{
    IBOutlet UITableView *tableViewMedia;
    NSDictionary *mediaInfo;
    
    IQMediaPickerControllerMediaType mediaType;
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
    
    [tableViewMedia reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)pickAction:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Media Picker Controller Media Types" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Video Library", @"Audio Library", @"Capture Photo", @"Capture Video", @"Capture Audio", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (actionSheet.tag == 1)
        {
            mediaType = buttonIndex;
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"allowsPickingMultipleItems" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
        else if (actionSheet.tag == 2)
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:mediaType];
            controller.allowsPickingMultipleItems = (buttonIndex == 0);
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    NSLog(@"Info: %@",info);

    mediaInfo = [info copy];
    [tableViewMedia reloadData];
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [mediaInfo count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[mediaInfo allKeys] objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[mediaInfo allKeys] objectAtIndex:section];
    return [[mediaInfo objectForKey:key] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
//
//    NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
//    
//    NSURL *url = [[[mediaInfo objectForKey:key] objectAtIndex:indexPath.row] objectForKey:IQMediaURL];
//    
//    if ([key isEqualToString:IQMediaTypeVideo])
//    {
//        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//        [self presentMoviePlayerViewControllerAnimated:controller];
//    }
//    else if ([key isEqualToString:IQMediaTypeAudio])
//    {
//        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//        [self presentMoviePlayerViewControllerAnimated:controller];
//    }
//    else if ([key isEqualToString:IQMediaTypeImage])
//    {
//        
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

