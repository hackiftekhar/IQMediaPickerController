//
//  IQPartitionBar.m
//  ImagePickerController
//
//  Created by Iftekhar on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQPartitionBar.h"
#import "IQPartitionView.h"

@interface IQPartitionBar ()<IQPartitionViewDelegate>

@end

@implementation IQPartitionBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setSelectedIndex:-1];
        
        [self setBackgroundColor:[UIColor grayColor]];
    }
    return self;
}


-(void)setPartitions:(NSArray *)partitions
{
    [self setPartitions:partitions animated:NO];
}

-(void)setPartitions:(NSArray *)partitions animated:(BOOL)animated;
{
    NSMutableArray *newPartitions = [[NSMutableArray alloc] init];
    
    for (NSNumber *progress in partitions)
    {
        if ([progress floatValue] <= 0.1)   [newPartitions addObject:[NSNumber numberWithFloat:0.1]];
        else    [newPartitions addObject:progress];
    }
    
    _partitions = newPartitions;
    
    CGFloat availableWidth = self.frame.size.width - ([_partitions count]+1);
    
    CGFloat totalProgress = 0;
    
    for (NSNumber *progress in _partitions)
        totalProgress += [progress floatValue];
    
    CGFloat progressMultiplier = availableWidth/totalProgress;
    
    NSMutableArray *currentViews = [NSMutableArray arrayWithArray:self.subviews];
    
    CGFloat currentX = 1;
    
    for (NSNumber *progress in _partitions)
    {
        IQPartitionView *view = [currentViews firstObject];
        
        CGFloat aProgress = [progress floatValue];

        if (view)
        {
            [currentViews removeObject:view];
        }
        else
        {
            CGFloat width = aProgress*progressMultiplier;

            view = [[IQPartitionView alloc] initWithFrame:CGRectMake(currentX+width/2, 1, 0, self.frame.size.height-2)];
            view.contentMode = UIViewContentModeScaleToFill;
            [view setDelegate:self];
            [self addSubview:view];
        }
        
        CGRect frame = CGRectMake(currentX, 1, aProgress*progressMultiplier, self.frame.size.height-2);
        
        [UIView animateWithDuration:(animated?0.2:0) delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            [view setFrame:frame];
            [view setText:[NSString stringWithFormat:@"%.2f",aProgress]];
        } completion:nil];
        
        currentX = CGRectGetMaxX(frame)+1;
    }
    
    for (UIView *aView in currentViews)
    {
        [aView removeFromSuperview];
    }
}

-(void)removeSelectedPartition
{
    [self removePartitionAtIndex:self.selectedIndex];
}

-(void)removePartitionAtIndex:(NSInteger )index
{
    if (self.selectedIndex != -1)
    {
        NSMutableArray *newPartitions = [[self partitions] mutableCopy];
        [newPartitions removeObjectAtIndex:index];
        [self setPartitions:newPartitions animated:YES];
        
        if (self.selectedIndex>index)
        {
            [self setSelectedIndex:self.selectedIndex-1];
        }
        else if(self.selectedIndex == index)
        {
            [self setSelectedIndex:-1];
        }
    }
}

-(void)partitionView:(IQPartitionView*)partition didSelect:(BOOL)selected
{
    for (IQPartitionView *view in self.subviews)
    {
        if (selected)
        {
            if (view!=partition)
                [view setSelected:NO];
        }
        else
        {
            [view setSelected:NO];
        }
    }

    if ([_delegate respondsToSelector:@selector(partitionBar:didSelectPartitionIndex:)])
    {
        NSUInteger index = -1;

        if (selected)
        {
            index = [self.subviews indexOfObject:partition];
        }
        
        _selectedIndex = index;
        [_delegate partitionBar:self didSelectPartitionIndex:index];
    }
}

-(void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    if (selectedIndex>self.subviews.count || selectedIndex<0)
    {
        _selectedIndex = -1;
    }
    
    for (IQPartitionView *view in self.subviews)
    {
        [view setSelected:NO];
    }
    
    if (selectedIndex != -1 && selectedIndex < self.subviews.count)
    {
        IQPartitionView *view = [self.subviews objectAtIndex:selectedIndex];
        [view setSelected:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(partitionBar:didSelectPartitionIndex:)])
    {
        [_delegate partitionBar:self didSelectPartitionIndex:_selectedIndex];
    }

}

@end
