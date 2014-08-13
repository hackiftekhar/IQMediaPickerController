//
//  IQSongListViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongListTableHeaderView.h"
#import "IQAudioPickerUtility.h"

@implementation IQSongListViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[IQSongListTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

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
    cell.imageView.image = image;
    
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.text = [IQAudioPickerUtility secondsToTimeString:[[item valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue]];
    [label sizeToFit];
    
    cell.accessoryView = label;
    
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
        MPMediaItemCollection *collection = [self.collections objectAtIndex:section];
        
        MPMediaItemArtwork *artwork = [collection.representativeItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *image = [artwork imageWithSize:artwork.bounds.size];
        
        UINavigationBar *header = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        [header setTintColor:nil];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [header addSubview:imageView];

        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 200, 20)];
        [labelTitle setFont:[UIFont boldSystemFontOfSize:17]];
        labelTitle.text = [collection.representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        [header addSubview:labelTitle];
        
        UILabel *labelArtist = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 200, 20)];
        labelArtist.font = [UIFont systemFontOfSize:12];
        [header addSubview:labelArtist];
        
        if (collection.items.count == 0)
        {
            labelArtist.text = [NSString stringWithFormat:@"no songs"];
        }
        else
        {
            NSUInteger totalMinutes = [IQAudioPickerUtility mediaCollectionDuration:collection];

            labelArtist.text = [NSString stringWithFormat:@"%lu %@, %lu %@",(unsigned long)collection.count,(collection.count>1?@"songs":@"song"),(unsigned long)totalMinutes,(totalMinutes>1?@"mins":@"min")];
        }
        
        return header;
    }
    else
    {
        return nil;
    }
}

@end
