//
//  IQAudioPickerController.h
//  IQAudioPickerController
//
//  Created by Iftekhar on 12/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol IQAudioPickerControllerDelegate;

@interface IQAudioPickerController : UIViewController

@property(nonatomic, assign) id<IQAudioPickerControllerDelegate> delegate;
@property (nonatomic) BOOL allowsPickingMultipleItems; // default is NO
@property(nonatomic, strong) NSMutableSet *selectedItems;

@end

@protocol IQAudioPickerControllerDelegate <NSObject>

- (void)audioPickerController:(IQAudioPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
- (void)audioPickerControllerDidCancel:(IQAudioPickerController *)mediaPicker;

@end



extern NSString *const IQMediaTypeAudio;