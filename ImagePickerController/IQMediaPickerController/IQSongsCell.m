//
//  IQSongsCell.m
//  ImagePickerController
//
//  Created by Canopus 4 on 14/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQSongsCell.h"
#import "IQShadowView.h"

@implementation IQSongsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 50);

        IQShadowView *shadowView = [[IQShadowView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:shadowView];

        self.imageViewSong = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewSong.clipsToBounds = YES;
        self.imageViewSong.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewSong.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shadowView addSubview:self.imageViewSong];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 315-50, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 315-50, 20)];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelSubTitle];
        
        self.labelDuration = [[UILabel alloc] init];
        self.labelDuration.backgroundColor = [UIColor clearColor];
        self.labelDuration.font = [UIFont boldSystemFontOfSize:12];
        self.labelDuration.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        self.accessoryView = self.labelDuration;
        
        [self setIsSelected:NO];
    }
    return self;
}

-(void)layoutSubviews
{
    [self.labelDuration sizeToFit];

    [super layoutSubviews];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    if (_isSelected)
    {
        self.labelTitle.textColor = [UIColor purpleColor];
        self.labelSubTitle.textColor = [UIColor purpleColor];
        self.labelDuration.textColor = [UIColor purpleColor];
    }
    else
    {
        self.labelTitle.textColor = [UIColor blackColor];
        self.labelSubTitle.textColor = [UIColor grayColor];
        self.labelDuration.textColor = [UIColor darkGrayColor];
    }
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
