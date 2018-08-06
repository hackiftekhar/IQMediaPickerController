//
//  IQSongsListTableHeaderView.m
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


#import "IQSongsListTableHeaderView.h"
#import <UIKit/UIImageView.h>
#import <UIKit/UILabel.h>

@implementation IQSongsListTableHeaderView

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.contentView.frame = CGRectMake(0, 0, 320, 80);
        
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:shadowView];
        
        self.imageViewAlbum = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewAlbum.clipsToBounds = YES;
        self.imageViewAlbum.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewAlbum.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [shadowView addSubview:self.imageViewAlbum];
        
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 315-75, 20)];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.font = [UIFont boldSystemFontOfSize:15];
        self.labelTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelTitle];
        
        self.labelSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 315-75, 20)];
        self.labelSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;;
        [self.contentView addSubview:self.labelSubTitle];
        
        self.labelSubSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 315-75, 20)];
        self.labelSubSubTitle.backgroundColor = [UIColor clearColor];
        self.labelSubSubTitle.font = [UIFont systemFontOfSize:13];
        self.labelSubSubTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.labelSubSubTitle];
        
    }

    return self;
}

@end
