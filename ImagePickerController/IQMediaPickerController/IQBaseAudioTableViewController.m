//
//  IQBaseAudioPickerController.m
//  ImagePickerController
//
//  Created by Canopus 4 on 14/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQBaseAudioTableViewController.h"
#import "IQSongsCell.h"
#import "IQAlbumViewCell.h"
#import "IQSongsListTableHeaderView.h"

@interface IQBaseAudioTableViewController ()

@end

@implementation IQBaseAudioTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[IQSongsCell class] forCellReuseIdentifier:NSStringFromClass([IQSongsCell class])];
    [self.tableView registerClass:[IQAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQAlbumViewCell class])];
    [self.tableView registerClass:[IQSongsListTableHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([IQSongsListTableHeaderView class])];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

@end
