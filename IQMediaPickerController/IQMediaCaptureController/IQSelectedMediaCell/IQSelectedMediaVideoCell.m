//
//  IQSelectedMediaVideoCell.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2017 Iftekhar Qurashi.
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


#import <UIKit/UILabel.h>
#import <UIKit/UIImageView.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>

#import "IQSelectedMediaVideoCell.h"
#import "NSString+IQTimeIntervalFormatter.h"
#import "UIImage+IQMediaPickerController.h"

@interface IQSelectedMediaVideoCell ()

@property(nonatomic) UILabel *labelDuration;
@property(nonatomic) UIImageView *imageViewPreview;
@property(nonatomic) UIImageView *imageViewPlay;

@end

@implementation IQSelectedMediaVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

        self.imageViewPreview = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageViewPreview.clipsToBounds = YES;
        self.imageViewPreview.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageViewPreview];
        
        self.imageViewPlay = [[UIImageView alloc] initWithImage:[[UIImage imageInsideMediaPickerBundleNamed:@"IQ_control_video_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.imageViewPlay.tintColor = [UIColor whiteColor];
        self.imageViewPlay.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageViewPlay.layer.shadowOffset = CGSizeZero;
        self.imageViewPlay.layer.shadowRadius = 2.0;
        self.imageViewPlay.layer.shadowOpacity = 0.5;
        self.imageViewPlay.center = CGPointMake(self.contentView.bounds.size.width/2, self.contentView.bounds.size.height/2);
        [self.contentView addSubview:self.imageViewPlay];
        
        self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.bounds)-20, CGRectGetWidth(self.contentView.bounds), 20)];
        self.labelDuration.textColor = [UIColor whiteColor];
        self.labelDuration.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.labelDuration.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.labelDuration];
    }
    return self;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL canPerform = [super canPerformAction:action withSender:sender];
    
    if (canPerform == NO)
    {
        if (action == @selector(delete:))
        {
            canPerform = YES;
        }
    }
    
    return canPerform;
}

-(void)delete:(id)sender
{
    UIResponder *collectionViewResponder = [self nextResponder];
    
    do {
        if ([collectionViewResponder isKindOfClass:[UICollectionView class]])
        {
            break;
        }
        else
        {
            collectionViewResponder = [self nextResponder];
        }
    } while (collectionViewResponder != nil);
    
    
    if ([collectionViewResponder isKindOfClass:[UICollectionView class]])
    {
        UICollectionView *collectionView = (UICollectionView*)collectionViewResponder;
        
        if ([collectionView.delegate respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)])
        {
            NSIndexPath *indexPath = [collectionView indexPathForCell:self];
            
            [collectionView.delegate collectionView:collectionView performAction:_cmd forItemAtIndexPath:indexPath withSender:sender];
        }
    }
}

-(void)setFileURL:(NSURL *)fileURL
{
    _fileURL = fileURL;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    if (asset)
    {
        NSTimeInterval durationInSeconds = CMTimeGetSeconds(asset.duration);
        
        self.labelDuration.text = [NSString stringWithFormat:@"  %@",[NSString timeStringForTimeInterval:durationInSeconds forceIncludeHours:NO]];
        
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
        self.imageViewPreview.image = thumbnail;
    }
    else
    {
        self.labelDuration.text = @"  00:00";
        self.imageViewPreview.image = nil;
    }
}

@end
