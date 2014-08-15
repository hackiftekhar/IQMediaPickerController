//
//  IQSongsCell.h
//  ImagePickerController
//
//  Created by Canopus 4 on 14/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQSongsCell : UITableViewCell

@property(nonatomic, strong) UIImageView *imageViewSong;
@property(nonatomic, strong) UILabel *labelTitle;
@property(nonatomic, strong) UILabel *labelSubTitle;

@property(nonatomic, strong) UILabel *labelDuration;

@property(nonatomic, assign) BOOL isSelected;

@end
