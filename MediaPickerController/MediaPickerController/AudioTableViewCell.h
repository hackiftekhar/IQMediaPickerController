//
//  AudioTableViewCell.h
//  IQMediaPickerController
//
//  Copyright (c) 2013-14 Iftekhar Qurashi.
//

#import <UIKit/UIKit.h>

@interface AudioTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAudio;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlay;


@end
