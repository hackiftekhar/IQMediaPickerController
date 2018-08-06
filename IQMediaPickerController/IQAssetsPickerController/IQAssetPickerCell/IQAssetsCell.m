//
//  IQAssetsCell.m
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


#import "IQAssetsCell.h"
#import <Photos/PHImageManager.h>
#import <Photos/PHAsset.h>
#import "NSString+IQTimeIntervalFormatter.h"

@interface IQAssetsCell()

@property(nonatomic, assign) __block PHImageRequestID imageRequestID;
@property (nonatomic) UIImageView *imageViewAsset;
@property (nonatomic) UILabel *labelDuration;

@end

@implementation IQAssetsCell

-(void)initialize
{
    self.checkmarkView.alpha = 0.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView *shadowView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:shadowView];
        
        self.imageViewAsset = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewAsset.clipsToBounds = YES;
        self.imageViewAsset.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewAsset.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.imageViewAsset];
    
        self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageViewAsset.bounds.size.height-15, self.bounds.size.width, 15)];
        self.labelDuration.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
//        self.labelDuration.textAlignment = NSTextAlignmentCenter;
        self.labelDuration.textColor = [UIColor whiteColor];
        self.labelDuration.font = [UIFont boldSystemFontOfSize:12];
        self.labelDuration.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        [self.contentView addSubview:self.labelDuration];

        self.checkmarkView = [[IQCheckmarkView alloc] init];
        self.checkmarkView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.checkmarkView.frame = CGRectMake(self.imageViewAsset.bounds.size.width - 24, self.imageViewAsset.bounds.size.height - 24, 20, 20);
        [self.contentView addSubview:self.checkmarkView];
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageViewAsset.image = nil;
    _labelDuration.text =  nil;

    if (self.imageRequestID != PHInvalidImageRequestID)
    {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
}

-(void)setAsset:(PHAsset *)asset
{
    _asset = asset;
    
    __weak typeof(self) weakSelf = self;
    
    self.imageRequestID = PHInvalidImageRequestID;

    PHImageRequestOptions * options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = NO;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize targetSize = CGSizeMake(self.imageViewAsset.frame.size.width*scale, self.imageViewAsset.frame.size.height*scale);
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaType == PHAssetMediaTypeAudio)
    {
        self.labelDuration.text = [NSString stringWithFormat:@" %@ ",[NSString timeStringForTimeInterval:asset.duration forceIncludeHours:NO]];
    }
    
    self.imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        NSInteger resultImageRequestID = [info[PHImageResultRequestIDKey] integerValue];
        
        if ((weakSelf.imageRequestID == PHInvalidImageRequestID || weakSelf.imageRequestID == resultImageRequestID) && result)
        {
            weakSelf.imageViewAsset.image = result;
        }
    }];
}

@end
