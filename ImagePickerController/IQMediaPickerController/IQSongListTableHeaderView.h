//
//  IQTableViewHeaderView.h
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IQSongListTableHeaderView : UITableViewHeaderFooterView

@property(nonatomic, strong) IBOutlet UIImageView *imageViewAlbum;
@property(nonatomic, strong) IBOutlet UILabel *labelAlbumName;
@property(nonatomic, strong) IBOutlet UILabel *labelArtistName;

@end
