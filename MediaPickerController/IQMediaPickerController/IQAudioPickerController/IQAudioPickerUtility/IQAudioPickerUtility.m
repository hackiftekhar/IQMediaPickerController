//
//  IQAudioPickerUtility.m
//  IQAudioPickerController
//
//  Created by Iftekhar on 13/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQAudioPickerUtility.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation IQAudioPickerUtility

+(NSString*)secondsToTimeString:(NSTimeInterval)seconds
{
    NSUInteger totalMinutes = seconds/60;
    NSUInteger totalSeconds = ((NSUInteger)seconds)%60;
    
    CGFloat reminder = seconds-(totalMinutes*60)-totalSeconds;
    
    totalSeconds+=roundf(reminder);
    
    if (totalSeconds>= 60)
    {
        totalMinutes++;
        totalSeconds = 0;
    }
    
    return [NSString stringWithFormat:@"%ld:%02ld",(long)totalMinutes,(unsigned long)totalSeconds];
}

+(NSUInteger)secondsToMins:(NSTimeInterval)seconds
{
    NSUInteger totalMinutes = seconds/60;
    NSUInteger totalSeconds = ((NSUInteger)seconds)%60;
    
    if (totalSeconds>= 30)
    {
        totalMinutes++;
    }
    
    return totalMinutes;
}

+(NSUInteger)mediaCollectionDuration:(MPMediaItemCollection*)collection
{
    NSTimeInterval totalDuration = 0;
    for (MPMediaItem *mediaItem in collection.items)
    {
        totalDuration += [[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    }
    
    return [IQAudioPickerUtility secondsToMins:totalDuration];
}

@end
