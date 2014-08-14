//
//  IQSongListViewController.h
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQBaseAudioTableViewController.h"

@class MPMediaItemCollection;

@interface IQSongsListViewController : IQBaseAudioTableViewController

@property(nonatomic, strong) NSString *property;

@property(nonatomic, strong) NSArray *collections;

@end
