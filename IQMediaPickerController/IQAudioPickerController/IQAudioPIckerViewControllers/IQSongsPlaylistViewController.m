//
//  IQSongsPlaylistViewController.m
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
#import <UIKit/UINavigationItem.h>
#import <UIKit/UIBarButtonItem.h>
#import <UIKit/UITabBarItem.h>
#import <UIKit/UILabel.h>
#import <MediaPlayer/MPMediaItemCollection.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMediaPlaylist.h>

#import "IQSongsPlaylistViewController.h"
#import "IQSongsListViewController.h"
#import "IQAudioPickerUtility.h"
#import "IQAudioPickerController.h"
#import "UIImage+IQMediaPickerController.h"

@interface IQSongsPlaylistViewController ()

@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@end

@implementation IQSongsPlaylistViewController
{
    NSArray<__kindof MPMediaItemCollection *> *playlists;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Playlists";
        self.tabBarItem.image = [UIImage imageInsideMediaPickerBundleNamed:@"playlists"];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 60;
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
//    [query setGroupingType:MPMediaGroupingPlaylist];

    playlists = [query collections];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.selectedMediaCountItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedMediaCountItem.possibleTitles = [NSSet setWithObject:@"999 media selected"];
    self.selectedMediaCountItem.enabled = NO;
    
    self.toolbarItems = @[flexItem,self.selectedMediaCountItem,flexItem];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSelectedCountAnimated:animated];
}

-(void)updateSelectedCountAnimated:(BOOL)animated
{
    if ([self.audioPickerController.selectedItems count])
    {
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:animated];
        
        [self.navigationController setToolbarHidden:NO animated:animated];
        
        NSString *finalText = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.audioPickerController.selectedItems count]];
        
        if (self.audioPickerController.maximumItemCount > 0)
        {
            finalText = [finalText stringByAppendingFormat:@" (%lu maximum) ",(unsigned long)self.audioPickerController.maximumItemCount];
        }
        
        self.selectedMediaCountItem.title = finalText;
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
        [self.navigationController setToolbarHidden:YES animated:animated];
        self.selectedMediaCountItem.title = nil;
    }
}

-(void)doneAction:(UIBarButtonItem*)item
{
    if ([self.audioPickerController.delegate respondsToSelector:@selector(audioPickerController:didPickMediaItems:)])
    {
        [self.audioPickerController.delegate audioPickerController:self.audioPickerController didPickMediaItems:self.audioPickerController.selectedItems];
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
    return playlists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    IQSongsListViewController *controller = [[IQSongsListViewController alloc] init];
    controller.audioPickerController = self.audioPickerController;
    
    MPMediaPlaylist *item = [playlists objectAtIndex:indexPath.row];
    
    controller.title = [item valueForProperty:MPMediaPlaylistPropertyName];
    controller.collections = @[item];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
