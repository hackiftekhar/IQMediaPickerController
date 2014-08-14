//
//  IQSongsPlaylistViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsPlaylistViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongsListViewController.h"
#import "IQAudioPickerUtility.h"
@implementation IQSongsPlaylistViewController
{
    NSArray *playlists;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Playlists";
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
//    [query setGroupingType:MPMediaGroupingPlaylist];

    playlists = [query collections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return playlists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    MPMediaPlaylist *item = [playlists objectAtIndex:indexPath.row];
    cell.textLabel.text = [item valueForProperty:MPMediaPlaylistPropertyName];
    
    if (item.items.count == 0)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"no songs"];
    }
    else
    {
        NSUInteger totalMinutes = [IQAudioPickerUtility mediaCollectionDuration:item];

        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@, %lu %@",(unsigned long)item.count,(item.count>1?@"songs":@"song"),(unsigned long)totalMinutes,(totalMinutes>1?@"mins":@"min")];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQSongsListViewController *controller = [[IQSongsListViewController alloc] init];
    
    MPMediaPlaylist *item = [playlists objectAtIndex:indexPath.row];
    
    controller.title = [item valueForProperty:MPMediaPlaylistPropertyName];
    controller.collections = @[item];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
