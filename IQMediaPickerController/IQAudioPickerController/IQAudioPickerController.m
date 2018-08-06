//
//  IQAudioPickerController.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-17 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <UIKit/UINavigationController.h>

#import "IQAudioPickerController.h"
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

@dynamic delegate;

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setTintColor:[UIColor purpleColor]];
    _selectedItems = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    IQSongsPlaylistViewController *playlistController = [[IQSongsPlaylistViewController alloc] init];
    IQSongsArtistListViewController *artistController = [[IQSongsArtistListViewController alloc] init];
    IQSongsListViewController *songsController = [[IQSongsListViewController alloc] init];
    IQSongsAlbumListViewController *albumsController = [[IQSongsAlbumListViewController alloc] init];
    IQSongsGenreViewController *genreController = [[IQSongsGenreViewController alloc] init];
    IQSongsCompilationsViewController *compilationsController = [[IQSongsCompilationsViewController alloc] init];
    IQSongsComposersViewController *composersController = [[IQSongsComposersViewController alloc] init];

    playlistController.audioPickerController = self;
    artistController.audioPickerController = self;
    songsController.audioPickerController = self;
    composersController.audioPickerController = self;
    compilationsController.audioPickerController = self;
    genreController.audioPickerController = self;
    albumsController.audioPickerController = self;

    self.viewControllers = @[[[UINavigationController alloc] initWithRootViewController:playlistController],
                             [[UINavigationController alloc] initWithRootViewController:artistController],
                             [[UINavigationController alloc] initWithRootViewController:songsController],
                             [[UINavigationController alloc] initWithRootViewController:albumsController],
                             [[UINavigationController alloc] initWithRootViewController:genreController],
                             [[UINavigationController alloc] initWithRootViewController:compilationsController],
                             [[UINavigationController alloc] initWithRootViewController:composersController],
                             ];
    [self setSelectedIndex:2];
    self.customizableViewControllers = nil;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
