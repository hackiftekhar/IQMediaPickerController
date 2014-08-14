//
//  IQSongsComposersViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsComposersViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongsListViewController.h"
#import "IQAlbumViewCell.h"

@implementation IQSongsComposersViewController
{
    NSArray *collections;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Composers";
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    MPMediaQuery *query = [MPMediaQuery composersQuery];
    
    collections = [query collections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return collections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQAlbumViewCell class]) forIndexPath:indexPath];
    
    MPMediaItemCollection *item = [collections objectAtIndex:indexPath.row];
    
    MPMediaItemArtwork *artwork = [item.representativeItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    cell.imageViewAlbum.image = image;
    cell.labelTitle.text = [item.representativeItem valueForProperty:MPMediaItemPropertyComposer];
    
    MPMediaQuery *query = [MPMediaQuery composersQuery];
    [query setGroupingType:MPMediaGroupingAlbum];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[item.representativeItem valueForProperty:MPMediaItemPropertyComposer] forProperty:MPMediaItemPropertyComposer]];
    
    NSUInteger albums = [[query collections] count];
    NSUInteger songs = [[query items] count];
    
    cell.labelSubTitle.text = [NSString stringWithFormat:@"%lu %@, %lu %@",(unsigned long)albums,(albums>1?@"albums":@"album"),(unsigned long)songs,(songs>1?@"songs":@"song")];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQSongsListViewController *controller = [[IQSongsListViewController alloc] init];
    
    MPMediaItemCollection *item = [collections objectAtIndex:indexPath.row];
    
    controller.title = [item.representativeItem valueForProperty:MPMediaItemPropertyComposer];
    
    MPMediaQuery *query = [MPMediaQuery composersQuery];
    [query setGroupingType:MPMediaGroupingAlbum];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:controller.title forProperty:MPMediaItemPropertyComposer]];
    
    controller.collections = [query collections];
    
    [self.navigationController pushViewController:controller animated:YES];
}


@end
