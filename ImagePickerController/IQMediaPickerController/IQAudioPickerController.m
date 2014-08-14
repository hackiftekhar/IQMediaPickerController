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

@implementation IQAudioPickerController
{
    BOOL _previousNavigationBarHidden;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    IQSongsPlaylistViewController *playlistController = [[IQSongsPlaylistViewController alloc] init];
    IQSongsArtistListViewController *artistController = [[IQSongsArtistListViewController alloc] init];
    IQSongsListViewController *songsController = [[IQSongsListViewController alloc] init];
    IQSongsAlbumListViewController *albumsController = [[IQSongsAlbumListViewController alloc] init];
    IQSongsGenreViewController *genreController = [[IQSongsGenreViewController alloc] init];
    IQSongsComposersViewController *composersController = [[IQSongsComposersViewController alloc] init];
    IQSongsCompilationsViewController *compilationsController = [[IQSongsCompilationsViewController alloc] init];

    self.viewControllers = @[[[UINavigationController alloc] initWithRootViewController:playlistController],
                             [[UINavigationController alloc] initWithRootViewController:artistController],
                             [[UINavigationController alloc] initWithRootViewController:songsController],
                             [[UINavigationController alloc] initWithRootViewController:albumsController],
                             [[UINavigationController alloc] initWithRootViewController:genreController],
                             [[UINavigationController alloc] initWithRootViewController:composersController],
                             [[UINavigationController alloc] initWithRootViewController:compilationsController],
                             ];
    
    self.customizableViewControllers = nil;

//    UIViewController *controller = [self.moreNavigationController.viewControllers firstObject];
//    self.navigationItem
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    _previousNavigationBarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = _previousNavigationBarHidden;
}

@end
