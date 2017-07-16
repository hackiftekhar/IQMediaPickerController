//
//  VideoTableViewCell.h
//  IQMediaPickerController
//
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (nonatomic) IBOutlet UILabel *labelTitle;
@property (nonatomic) IBOutlet UILabel *labelSubtitle;
@property (nonatomic) IBOutlet UIButton *buttonPlay;

@end
