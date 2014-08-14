//
//  IQAlbumViewCell.m
//  ImagePickerController
//
//  Created by Canopus 4 on 14/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAlbumViewCell.h"

@implementation IQAlbumViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 80);
        
        self.imageViewAlbum = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        self.imageViewAlbum.contentMode = UIViewContentModeScaleAspectFit;
        self.imageViewAlbum.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.imageViewAlbum];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 320, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 320, 20)];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelSubTitle];
        
        self.labelSubSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 320, 20)];
        self.labelSubSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubSubTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.labelSubSubTitle];
    }
    return self;
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
