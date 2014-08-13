//
//  IQAudioPickerUtility.h
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMediaItemCollection;

@interface IQAudioPickerUtility : NSObject

+(NSString*)secondsToTimeString:(NSTimeInterval)seconds;

+(NSUInteger)secondsToMins:(NSTimeInterval)seconds;

+(NSUInteger)mediaCollectionDuration:(MPMediaItemCollection*)collection;

@end
