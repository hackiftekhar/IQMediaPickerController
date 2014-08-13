//
//  IQSongsCompilationsViewController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsCompilationsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IQSongListViewController.h"

@implementation IQSongsCompilationsViewController
{
    NSArray *collections;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    MPMediaQuery *query = [MPMediaQuery compilationsQuery];
    //    [query setGroupingType:MPMediaGroupingAlbumArtist];
    
    collections = [query collections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return collections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    MPMediaItemCollection *item = [collections objectAtIndex:indexPath.row];
    
    MPMediaItemArtwork *artwork = [item.representativeItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    cell.imageView.image = image;
    cell.textLabel.text = [item.representativeItem valueForProperty:MPMediaItemPropertyGenre];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)item.count,(item.count>1?@"songs":@"song")];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([IQSongListViewController class])])
    {
        IQSongListViewController *controller = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.collections = @[[collections objectAtIndex:indexPath.row]];
    }
}


@end
