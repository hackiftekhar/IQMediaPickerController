
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Media Picker Controller Media Types" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Capture Photo", @"Capture Video", @"Capture Audio", @"Photo Library", @"Video Library", @"Audio Library",@"Photo Library Multiple Items", @"Video Library Multiple Items", @"Audio Library Multiple Items", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypePhoto];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 1:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypeVideo];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 2:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypeAudio];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 3:
        case 6:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            controller.allowsPickingMultipleItems = (buttonIndex == 6);
            [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 4:
        case 7:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            controller.allowsPickingMultipleItems = (buttonIndex == 7);
            [controller setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 5:
        case 8:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            controller.allowsPickingMultipleItems = (buttonIndex == 8);
            [controller setMediaType:IQMediaPickerControllerMediaTypeAudioLibrary];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        default:
            break;
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

