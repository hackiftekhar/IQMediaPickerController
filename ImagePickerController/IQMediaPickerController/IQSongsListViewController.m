//
//  IQSongListViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongsListTableHeaderView.h"
#import "IQAudioPickerUtility.h"
#import "IQSongsCell.h"

@implementation IQSongsListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Songs";
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.collections)
    {
        return self.collections.count;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.collections)
    {
        MPMediaItemCollection *collection = [self.collections objectAtIndex:section];
        return collection.count;
    }
    else
    {
        return [[[MPMediaQuery songsQuery] items] count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQSongsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQSongsCell class]) forIndexPath:indexPath];

    MPMediaItem *item = [[[MPMediaQuery songsQuery] items] objectAtIndex:indexPath.row];

    if (self.collections)
    {
        item = [[[self.collections objectAtIndex:indexPath.section] items] objectAtIndex:indexPath.row];
    }
    else
    {
        item = [[[MPMediaQuery songsQuery] items] objectAtIndex:indexPath.row];
    }
    
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    cell.imageViewSong.image = image;
    
    cell.labelTitle.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.labelSubTitle.text = [item valueForProperty:MPMediaItemPropertyArtist];
    cell.labelDuration.text = [IQAudioPickerUtility secondsToTimeString:[[item valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *items = [self.collections objectAtIndex:section];
    
    if (items.count)
    {
        return 100;
    }
    else
    {
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.collections)
    {
        IQSongsListTableHeaderView *headerView =[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([IQSongsListTableHeaderView class])];
        
        MPMediaItemCollection *collection = [self.collections objectAtIndex:section];
        
        MPMediaItemArtwork *artwork = [collection.representativeItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *image = [artwork imageWithSize:artwork.bounds.size];
        headerView.imageViewAlbum.image = image;
        
        headerView.labelTitle.text = [collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];

        if (collection.items.count == 0)
        {
            headerView.labelSubTitle.text = [NSString stringWithFormat:@"no songs"];
        }
        else
        {
            NSUInteger totalMinutes = [IQAudioPickerUtility mediaCollectionDuration:collection];

            headerView.labelSubTitle.text = [NSString stringWithFormat:@"%lu %@, %lu %@",(unsigned long)collection.count,(collection.count>1?@"songs":@"song"),(unsigned long)totalMinutes,(totalMinutes>1?@"mins":@"min")];
        }
        
        return headerView;
    }
    else
    {
        return nil;
    }
}

@end
