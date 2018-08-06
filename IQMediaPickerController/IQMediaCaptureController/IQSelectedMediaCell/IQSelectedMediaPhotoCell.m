//
//  IQSelectedMediaPhotoCell.m
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


#import <UIKit/UIImageView.h>

#import "IQSelectedMediaPhotoCell.h"

@interface IQSelectedMediaPhotoCell ()

@end

@implementation IQSelectedMediaPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

        _imageViewPreview = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageViewPreview.clipsToBounds = YES;
        _imageViewPreview.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageViewPreview];
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

@end
