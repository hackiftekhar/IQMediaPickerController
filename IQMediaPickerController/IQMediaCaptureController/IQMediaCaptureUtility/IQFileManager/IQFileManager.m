//
//  IQFileManager.m
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


#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVComposition.h>
#import <AVFoundation/AVAsset.h>

#import "IQFileManager.h"

@implementation IQFileManager

+ (NSString*)IQDocumentDirectory
{
    return [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
}

+ (NSString*)IQTemporaryDirectory
{
    return NSTemporaryDirectory();
}

+ (NSArray<NSString *>*)filesAtPath:(NSString*)path
{
    NSArray<NSString *> *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSMutableArray<NSString *> *retVal = [NSMutableArray new];
    for (NSString *str in items)
    {
        [retVal addObject:[NSString stringWithFormat:@"%@/%@", path, str]];
    }
    return retVal;
}

+ (CGFloat)durationOfFileAtPath:(NSString*)path
{
    AVURLAsset *urlAsset = [self assetURLForFilePath:path];
    
    Float64 time = CMTimeGetSeconds([urlAsset duration]);
    return time;
}

+ (NSArray<NSNumber*>*)durationsOfFilesAtPath:(NSString*)path;
{
    NSArray<NSString *> *items = [self filesAtPath:path];
    
    NSMutableArray<NSNumber*> *durations = [[NSMutableArray alloc] init];
    
    for (NSString *path in items)
    {
        [durations addObject:[NSNumber numberWithDouble:[[self class] durationOfFileAtPath:path]]];
    }
    
    return durations;
}

+ (NSArray<NSNumber*>*)durationsOfMediaURLs:(NSArray<NSURL*>*)URLs
{
    NSMutableArray<NSNumber*> *durations = [[NSMutableArray alloc] init];
    
    for (NSURL *url in URLs)
    {
        [durations addObject:[NSNumber numberWithDouble:[[self class] durationOfFileAtPath:url.relativePath]]];
    }
    
    return durations;
}


+ (void)mergeItemsFromPath:(NSString*)fromPath toPath:(NSString*)toPath completionHandler:(CompletionHandler)handler
{
    [self removeItemAtPath:toPath];
    
    NSArray<NSString*> *itemsToMerge = [self filesAtPath:fromPath];
    
    if (itemsToMerge.count == 0)
    {
        handler(NO);
        return;
    }
    if (itemsToMerge.count ==1)
    {
        [self copyItemAtPath:[itemsToMerge firstObject] toPath:toPath];
        
        handler(YES);
        return;
    }
    
    NSURL *exportURL = [NSURL fileURLWithPath:toPath];
   
    AVMutableComposition *mainComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compositionVideoTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *soundtrackTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime insertTime = kCMTimeZero;
    
    for(NSString *strPath in itemsToMerge)
    {
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:strPath]];
        CMTime subtrahend = CMTimeMake(1, 10);
        
        if([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count])
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(videoAsset.duration, subtrahend)) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:insertTime error:nil];
        
        if([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count])
            [soundtrackTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(videoAsset.duration, subtrahend)) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:insertTime error:nil];
        
        // Updating the insertTime for the next insert
        insertTime = CMTimeAdd(insertTime, CMTimeSubtract(videoAsset.duration, subtrahend));
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mainComposition presetName:AVAssetExportPresetHighestQuality];

    // Setting attributes of the exporter
    exporter.outputURL=exportURL;
    exporter.outputFileType =AVFileTypeMPEG4; //AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch ([exporter status])
        {
            case AVAssetExportSessionStatusCompleted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(YES);
                });
            }   break;
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(NO);
                });
            }
                break;
        }
    }];
}

+ (AVURLAsset*)assetURLForFilePath:(NSString*)filePath
{
    return [self assetURLForFileURL:[self URLForFilePath:filePath]];
}

+ (AVURLAsset*)assetURLForFileURL:(NSURL*)fileURL
{
    return [AVURLAsset URLAssetWithURL:fileURL options:nil];
}

+ (NSURL*)URLForFilePath:(NSString*)filePath
{
    return [NSURL fileURLWithPath:filePath];
}

+ (void)removeItemAtPath:(NSString*)path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

+ (void)removeItemsAtPath:(NSString*)path;
{
    NSArray<NSString*> *items = [self filesAtPath:path];
    for (NSString *str in items)
    {
        [self removeItemAtPath:str];
    }
}
+ (void)copyItemAtPath:(NSString*)atPath toPath:(NSString*)toPath
{
    [self removeItemAtPath:toPath];
    [[NSFileManager defaultManager] copyItemAtPath:atPath toPath:toPath error:NULL];
}

+ (void)moveItemAtPath:(NSString*)atPath toPath:(NSString*)toPath
{
    [self removeItemAtPath:toPath];
    [[NSFileManager defaultManager] moveItemAtPath:atPath toPath:toPath error:NULL];
}

+ (void)removeItemAtURL:(NSURL*)atURL
{
    [self removeItemAtPath:atURL.relativePath];
}

+ (void)removeItemsAtURL:(NSURL*)atURL
{
    [self removeItemAtPath:atURL.relativePath];
}

+ (void)copyItemAtURL:(NSURL*)atURL toURL:(NSURL*)toURL
{
    [self copyItemAtPath:atURL.relativePath toPath:toURL.relativePath];
}

+ (void)moveItemAtURL:(NSURL*)atURL toURL:(NSURL*)toURL
{
    [self moveItemAtPath:atURL.relativePath toPath:toURL.relativePath];
}

@end
