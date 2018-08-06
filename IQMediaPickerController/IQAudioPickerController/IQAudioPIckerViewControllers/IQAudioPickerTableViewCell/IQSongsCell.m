//
//  IQSongsCell.m
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


#import <UIKit/UINibLoading.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UILabel.h>

#import "IQSongsCell.h"

@implementation IQSongsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 50);

        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
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
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
