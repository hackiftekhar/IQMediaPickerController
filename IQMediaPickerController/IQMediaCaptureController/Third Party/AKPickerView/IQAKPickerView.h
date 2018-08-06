//
//  AKPickerView.h
//  AKPickerViewSample
//
//  Created by Akio Yasui on 3/29/14.
//  Copyright (c) 2014 Akio Yasui. All rights reserved.
//

#import <UIKit/UIScrollView.h>
#import <UIKit/UILabel.h>

typedef NS_ENUM(NSInteger, IQAKPickerViewStyle) {
	IQAKPickerViewStyle3D = 1,
	IQAKPickerViewStyleFlat
};

@class IQAKPickerView;

@protocol IQAKPickerViewDataSource <NSObject>
@required
- (NSUInteger)numberOfItemsInPickerView:(IQAKPickerView *)pickerView;
@optional
- (NSString *)pickerView:(IQAKPickerView *)pickerView titleForItem:(NSInteger)item;
@end

@protocol IQAKPickerViewDelegate <UIScrollViewDelegate>
@optional
- (void)pickerView:(IQAKPickerView *)pickerView didSelectItem:(NSInteger)item;
- (CGSize)pickerView:(IQAKPickerView *)pickerView marginForItem:(NSInteger)item;
- (void)pickerView:(IQAKPickerView *)pickerView configureLabel:(UILabel * const)label forItem:(NSInteger)item;
@end

@interface IQAKPickerView : UIView

@property (nonatomic, weak) id <IQAKPickerViewDataSource> dataSource;
@property (nonatomic, weak) id <IQAKPickerViewDelegate> delegate;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *highlightedFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) CGFloat fisheyeFactor; // 0...1; slight value recommended such as 0.0001
@property (nonatomic, assign, getter=isMaskDisabled) BOOL maskDisabled;
@property (nonatomic, assign) IQAKPickerViewStyle pickerViewStyle;
@property (nonatomic, assign, readonly) NSUInteger selectedItem;
@property (nonatomic, assign, readonly) CGPoint contentOffset;

- (void)reloadData;
- (void)scrollToItem:(NSUInteger)item animated:(BOOL)animated;
- (void)selectItem:(NSUInteger)item animated:(BOOL)animated;
- (void)selectItem:(NSUInteger)item animated:(BOOL)animated notifySelection:(BOOL)notifySelection;

@end
