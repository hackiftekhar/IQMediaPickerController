//
//  IQSongsPlaylistViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsPlaylistViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongListViewController.h"
#import "IQAudioPickerUtility.h"
@implementation IQSongsPlaylistViewController
{
    NSArray *playlists;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([IQSongListViewController class])])
    {
        IQSongListViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        MPMediaPlaylist *item = [playlists objectAtIndex:indexPath.row];

        controller.title = [item valueForProperty:MPMediaPlaylistPropertyName];
        controller.collections = @[item];
    }
}

@end
