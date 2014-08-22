//
//  IQViewController.m
//  ImagePickerController
//
//  Created by Iftekhar on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQViewController.h"
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface IQViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@end


@implementation IQViewController
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Media Picker Controller Media Types" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Capture Photo", @"Capture Video", @"Capture Audio", @"Photo Library", @"Video Library", @"Audio Library", nil];
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
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 4:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 5:
        {
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
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
    mediaInfo = [info copy];
    [tableViewMedia reloadData];
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[mediaInfo allKeys] objectAtIndex:indexPath.section];
    
    NSURL *url = [[[mediaInfo objectForKey:key] objectAtIndex:indexPath.row] objectForKey:IQMediaURL];

    if ([key isEqualToString:IQMediaTypeVideo])
    {
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:controller];
    }
    else if ([key isEqualToString:IQMediaTypeAudio])
    {
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:controller];
    }
    else if ([key isEqualToString:IQMediaTypeImage])
    {
    
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
