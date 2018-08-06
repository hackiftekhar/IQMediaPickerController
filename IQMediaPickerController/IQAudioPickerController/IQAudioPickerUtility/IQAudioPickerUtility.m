//
//  IQAudioPickerUtility.m
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


#import <MediaPlayer/MPMediaItemCollection.h>

#import "IQAudioPickerUtility.h"

@implementation IQAudioPickerUtility

+(NSString*)secondsToTimeString:(NSTimeInterval)seconds
{
    NSUInteger totalMinutes = (NSUInteger)seconds/60;
    NSUInteger totalSeconds = ((NSUInteger)seconds)%60;
    
    CGFloat reminder = seconds-(totalMinutes*60)-totalSeconds;
    
    totalSeconds+=round(reminder);
    
    if (totalSeconds>= 60)
    {
        totalMinutes++;
        totalSeconds = 0;
    }
    
    return [NSString stringWithFormat:@"%ld:%02ld",(unsigned long)totalMinutes,(unsigned long)totalSeconds];
}

+(NSUInteger)secondsToMins:(NSTimeInterval)seconds
{
    NSUInteger totalMinutes = (NSUInteger)seconds/60;
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
