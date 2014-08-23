//
//  IQAssetsAlbumViewCell.m
//  ImagePickerController
//
//  Created by Iftekhar on 16/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAssetsAlbumViewCell.h"
#import "IQAssetsPickerShadowView.h"

@implementation IQAssetsAlbumViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 80);
        
        IQAssetsPickerShadowView *shadowView = [[IQAssetsPickerShadowView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:shadowView];

        self.imageViewAlbum = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewAlbum.clipsToBounds = YES;
        self.imageViewAlbum.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewAlbum.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shadowView addSubview:self.imageViewAlbum];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 315-75, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 40, 315-75, 20)];
        self.labelSubTitle.textColor = [UIColor grayColor];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelSubTitle];
    }
    return self;
}

@end
