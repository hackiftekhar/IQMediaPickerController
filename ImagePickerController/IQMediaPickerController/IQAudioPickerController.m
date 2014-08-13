//
//  IQAudioPickerController.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAudioPickerController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation IQAudioPickerController
{
    NSArray *items;
    NSArray *collections;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    items = [query collections];
    collections = [query collections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    MPMediaItem *item = [items objectAtIndex:indexPath.row];

    
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSLog(@"%@",[item valueForProperty:MPMediaItemPropertyAssetURL]);

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
