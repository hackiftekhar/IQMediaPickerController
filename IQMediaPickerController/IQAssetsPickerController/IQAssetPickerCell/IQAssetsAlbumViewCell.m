//
//  IQAssetsAlbumViewCell.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2013-17 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <UIKit/UIImageView.h>
#import <UIKit/UILabel.h>

#import "IQAssetsAlbumViewCell.h"

@implementation IQAssetsAlbumViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGRect contentRect = CGRectMake(0, 0, 320, 100);
        self.contentView.frame = contentRect;
        
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:shadowView];

        self.imageViewAlbum = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewAlbum.clipsToBounds = YES;
        self.imageViewAlbum.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        self.imageViewAlbum.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewAlbum.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shadowView addSubview:self.imageViewAlbum];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(95, 25, 315-75, 25)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:17];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(95, 50, 315-75, 25)];
        self.labelSubTitle.textColor = [UIColor grayColor];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:16];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelSubTitle];
    }
    return self;
}

@end
