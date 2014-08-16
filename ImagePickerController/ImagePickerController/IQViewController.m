//
//  IQViewController.m
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQViewController.h"
#import "IQMediaPickerController.h"
#import "IQMediaCaptureController.h"
#import "IQPartitionBar.h"
#import "IQFileManager.h"

#import <MediaPlayer/MediaPlayer.h>

@interface IQViewController ()<IQMediaCaptureControllerDelegate,IQPartitionBarDelegate>

@end


@implementation IQViewController
{
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *containerView;
    
    NSArray *mediaURLs;
    
    MPMoviePlayerController *moviePlayer;
    IBOutlet IQPartitionBar *partitionBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Initiate the movie player.....
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//    moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    moviePlayer.view.frame = CGRectInset(containerView.bounds, 10, 10);
    moviePlayer.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    moviePlayer.shouldAutoplay = YES;
    [containerView addSubview:moviePlayer.view];
    
    moviePlayer.view.hidden = YES;
    partitionBar.hidden = YES;

    imageView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [moviePlayer pause];
    [moviePlayer stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)playbackDidFinish:(NSNotification*)notification
{
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    [moviePlayer pause];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([IQMediaCaptureController class])])
    {
        IQMediaCaptureController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

- (void)mediaCaptureController:(IQMediaCaptureController*)controller didFinishMediaWithInfo:(NSDictionary *)info
{
//    if ([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeVideo])
//    {
//        mediaURLs = [info objectForKey:IQMediaURLs];
//        
//        moviePlayer.view.hidden = NO;
//        partitionBar.hidden = NO;
//
//        [partitionBar setPartitions:[IQFileManager durationsOfMediaURLs:mediaURLs] animated:YES];
//        [partitionBar setSelectedIndex:-1];
//        
//        imageView.hidden = YES;
//    }
//    else if (([[info objectForKey:IQMediaType] isEqualToString:IQMediaTypeImage]))
//    {
//        imageView.image = [info objectForKey:IQMediaImage];
//        
//        moviePlayer.view.hidden = YES;
//        partitionBar.hidden = YES;
//
//        imageView.hidden = NO;
//    }
}

- (void)mediaCaptureControllerDidCancel:(IQMediaCaptureController *)controller
{

}

-(void)partitionBar:(IQPartitionBar*)bar didSelectPartitionIndex:(NSUInteger)index
{
    [moviePlayer pause];
    [moviePlayer stop];
    
    if (bar.selectedIndex == -1)
    {
        moviePlayer.contentURL = nil;
    }
    else
    {
        moviePlayer.contentURL = [mediaURLs objectAtIndex:index];
    }
}

- (IBAction)photoCaptureAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypePhoto];
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)videoCaptureAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypeVideo];
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)audioCaptureAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypeAudio];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)photoLibraryAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)videoLibraryAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypeVideoLibrary];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)audioLibraryAction:(UIButton *)sender
{
    IQMediaPickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([IQMediaPickerController class])];
    [controller setMediaType:IQMediaPickerControllerMediaTypeAudioLibrary];
    [self presentViewController:controller animated:YES completion:nil];
}
@end
