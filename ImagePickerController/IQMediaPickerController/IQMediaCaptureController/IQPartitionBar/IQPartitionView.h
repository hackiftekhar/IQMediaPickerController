//
//  IQPartitionView.h
//  ImagePickerController
//
//  Created by Canopus 4 on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQPartitionView;

@protocol IQPartitionViewDelegate <NSObject>

-(void)partitionView:(IQPartitionView*)partition didSelect:(BOOL)selected;

@end

@interface IQPartitionView : UILabel

@property(nonatomic, assign) id<IQPartitionViewDelegate> delegate;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, strong, readonly) UITapGestureRecognizer *tapRecognizer;

@end
