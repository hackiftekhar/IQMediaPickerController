//
//  IQAudioPickerController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAudioPickerController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "IQSongsPlaylistViewController.h"
#import "IQSongsArtistListViewController.h"
#import "IQSongsListViewController.h"
#import "IQSongsAlbumListViewController.h"
#import "IQSongsGenreViewController.h"
#import "IQSongsComposersViewController.h"
#import "IQSongsCompilationsViewController.h"

@interface IQAudioPickerController ()<UITabBarControllerDelegate>

@end

@implementation IQAudioPickerController
{
    BOOL _previousNavigationBarHidden;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setTintColor:[UIColor purpleColor]];
    _selectedItems = [[NSMutableSet alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _previousNavigationBarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = YES;
    
    IQSongsPlaylistViewController *playlistController = [[IQSongsPlaylistViewController alloc] init];
    playlistController.audioPickerController = self;
    IQSongsArtistListViewController *artistController = [[IQSongsArtistListViewController alloc] init];
    artistController.audioPickerController = self;
    IQSongsListViewController *songsController = [[IQSongsListViewController alloc] init];
    songsController.audioPickerController = self;
    IQSongsAlbumListViewController *albumsController = [[IQSongsAlbumListViewController alloc] init];
    albumsController.audioPickerController = self;
    IQSongsGenreViewController *genreController = [[IQSongsGenreViewController alloc] init];
    genreController.audioPickerController = self;
    IQSongsCompilationsViewController *compilationsController = [[IQSongsCompilationsViewController alloc] init];
    compilationsController.audioPickerController = self;
    IQSongsComposersViewController *composersController = [[IQSongsComposersViewController alloc] init];
    composersController.audioPickerController = self;
    
    self.viewControllers = @[[[UINavigationController alloc] initWithRootViewController:playlistController],
                             [[UINavigationController alloc] initWithRootViewController:artistController],
                             [[UINavigationController alloc] initWithRootViewController:songsController],
                             [[UINavigationController alloc] initWithRootViewController:albumsController],
                             [[UINavigationController alloc] initWithRootViewController:genreController],
                             [[UINavigationController alloc] initWithRootViewController:compilationsController],
                             [[UINavigationController alloc] initWithRootViewController:composersController],
                             ];
    self.customizableViewControllers = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = _previousNavigationBarHidden;
}

@end
