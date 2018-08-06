//
//  IQSongsListViewController.m
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
#import <UIKit/UIImageView.h>
#import <MediaPlayer/MPMediaItemCollection.h>
#import <MediaPlayer/MPMediaQuery.h>

#import "IQSongsListViewController.h"
#import "IQSongsListTableHeaderView.h"
#import "IQAudioPickerUtility.h"
#import "IQSongsCell.h"
#import "IQAudioPickerController.h"
#import "UIImage+IQMediaPickerController.h"

@interface IQSongsListViewController ()

@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@end

@implementation IQSongsListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Songs";
        self.tabBarItem.image = [UIImage imageInsideMediaPickerBundleNamed:@"songs"];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[IQSongsCell class] forCellReuseIdentifier:NSStringFromClass([IQSongsCell class])];
    [self.tableView registerClass:[IQSongsListTableHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([IQSongsListTableHeaderView class])];

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
    [self.tableView reloadData];
    
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
    }
    else
    {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
        [self.navigationItem setLeftBarButtonItem:cancelItem animated:animated];
    }

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
    
    MPMediaItem *item;

    if (self.collections)
    {
        item = [[[self.collections objectAtIndex:indexPath.section] items] objectAtIndex:indexPath.row];
    }
    else
    {
        item = [[[MPMediaQuery songsQuery] items] objectAtIndex:indexPath.row];
    }
    
    cell.isSelected = [self.audioPickerController.selectedItems containsObject:item];
    
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
    
    MPMediaItem *item = [[[MPMediaQuery songsQuery] items] objectAtIndex:indexPath.row];

    if (self.collections)
    {
        item = [[[self.collections objectAtIndex:indexPath.section] items] objectAtIndex:indexPath.row];
    }
    else
    {
        item = [[[MPMediaQuery songsQuery] items] objectAtIndex:indexPath.row];
    }
    
    
    if (self.audioPickerController.allowsPickingMultipleItems == NO)
    {
        [self.audioPickerController.selectedItems addObject:item];

        if ([self.audioPickerController.delegate respondsToSelector:@selector(audioPickerController:didPickMediaItems:)])
        {
            [self.audioPickerController.delegate audioPickerController:self.audioPickerController didPickMediaItems:self.audioPickerController.selectedItems];
        }
        
        [self.audioPickerController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.audioPickerController.selectedItems containsObject:item])
        {
            [self.audioPickerController.selectedItems removeObject:item];
        }
        else
        {
            NSUInteger count = self.audioPickerController.selectedItems.count;
            
            if (self.audioPickerController.maximumItemCount == 0 || self.audioPickerController.maximumItemCount > count)
            {
                [self.audioPickerController.selectedItems addObject:item];
            }
        }
        
        [self updateSelectedCountAnimated:YES];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *items = [self.collections objectAtIndex:section];
    
    if (items.count)
    {
        return 80;
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
