//
//  IQSongsArtistListViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsArtistListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongsListViewController.h"
#import "IQSongsAlbumViewCell.h"
#import "IQAudioPickerController.h"
#import "IQMediaPickerControllerConstants.h"

@implementation IQSongsArtistListViewController
{
    NSArray *collections;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Artists";
        self.tabBarItem.image = [UIImage imageNamed:@"artists"];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[IQSongsAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQSongsAlbumViewCell class])];

    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    [query setGroupingType:MPMediaGroupingAlbumArtist];
    
    collections = [query collections];

    if (self.audioPickerController.allowsPickingMultipleItems == NO)
    {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
        self.navigationItem.rightBarButtonItem = cancelItem;
    }
    else
    {
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
        self.navigationItem.rightBarButtonItem = doneItem;
    }
}

-(void)doneAction:(UIBarButtonItem*)item
{
    if ([self.audioPickerController.delegate respondsToSelector:@selector(audioPickerController:didPickMediaItems:)])
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        for (MPMediaItem *item in self.audioPickerController.selectedItems)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:item forKey:IQMediaItem];
            
            [items addObject:dict];
        }
        
        [self.audioPickerController.delegate audioPickerController:self.audioPickerController didPickMediaItems:items];
    }
    
    [self.audioPickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.audioPickerController.delegate respondsToSelector:@selector(audioPickerControllerDidCancel:)])
    {
        [self.audioPickerController.delegate audioPickerControllerDidCancel:self.audioPickerController];
    }
    
    [self.audioPickerController dismissViewControllerAnimated:YES completion:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return collections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQSongsAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQSongsAlbumViewCell class]) forIndexPath:indexPath];
    
    MPMediaItemCollection *item = [collections objectAtIndex:indexPath.row];
    
    MPMediaItemArtwork *artwork = [item.representativeItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    cell.imageViewAlbum.image = image;
    cell.labelTitle.text = [item.representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
    
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    [query setGroupingType:MPMediaGroupingAlbum];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[item.representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist] forProperty:MPMediaItemPropertyAlbumArtist]];
    
    NSUInteger albums = [[query collections] count];
    NSUInteger songs = [[query items] count];

    cell.labelSubTitle.text = [NSString stringWithFormat:@"%lu %@, %lu %@",(unsigned long)albums,(albums>1?@"albums":@"album"),(unsigned long)songs,(songs>1?@"songs":@"song")];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQSongsListViewController *controller = [[IQSongsListViewController alloc] init];
    controller.audioPickerController = self.audioPickerController;

    MPMediaItemCollection *item = [collections objectAtIndex:indexPath.row];
    
    controller.title = [item.representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
    
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    [query setGroupingType:MPMediaGroupingAlbum];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:controller.title forProperty:MPMediaItemPropertyAlbumArtist]];
    
    controller.collections = [query collections];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
