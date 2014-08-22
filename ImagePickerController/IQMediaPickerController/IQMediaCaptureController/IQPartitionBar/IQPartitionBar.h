//
//  IQPartitionBar.h
//  ImagePickerController
//
//  Created by Iftekhar on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQPartitionBar;

@protocol IQPartitionBarDelegate <NSObject>

-(void)partitionBar:(IQPartitionBar*)bar didSelectPartitionIndex:(NSUInteger)index;

@end

@interface IQPartitionBar : UIView

@property(nonatomic, assign) NSInteger selectedIndex;

@property(nonatomic, assign) IBOutlet id<IQPartitionBarDelegate> delegate;
//NSArray of NSNumber containing to progress value in CGFloat.
@property(nonatomic, strong) NSArray *partitions;
-(void)removeSelectedPartition;
-(void)removePartitionAtIndex:(NSInteger )index;

-(void)setPartitions:(NSArray *)partitions animated:(BOOL)animated;

@end
