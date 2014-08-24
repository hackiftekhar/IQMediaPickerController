//
//  VideoTableViewCell.h
//  IQMediaPickerController
//
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlay;

@end
