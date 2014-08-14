//
//  IQSongsCell.m
//  ImagePickerController
//
//  Created by Canopus 4 on 14/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsCell.h"

@implementation IQSongsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 50);
        
        self.imageViewSong = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.imageViewSong.contentMode = UIViewContentModeScaleAspectFit;
        self.imageViewSong.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.imageViewSong];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 320, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 320, 20)];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelSubTitle];
        
        self.labelDuration = [[UILabel alloc] init];
        self.labelDuration.backgroundColor = [UIColor clearColor];
        self.labelDuration.font = [UIFont boldSystemFontOfSize:12];
        self.labelDuration.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.accessoryView = self.labelDuration;
    }
    return self;
}

-(void)layoutSubviews
{
    [self.labelDuration sizeToFit];

    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
