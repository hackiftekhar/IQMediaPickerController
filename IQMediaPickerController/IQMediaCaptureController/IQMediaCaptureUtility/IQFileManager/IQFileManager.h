//
//  IQFileManager.h
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


#import <Foundation/NSObject.h>

@class AVURLAsset;

typedef void(^CompletionHandler)(BOOL merged);

@interface IQFileManager : NSObject

+ (NSString*)IQDocumentDirectory;
+ (NSString*)IQTemporaryDirectory;

+ (NSArray<NSString *>*)filesAtPath:(NSString*)path;
+ (CGFloat)durationOfFileAtPath:(NSString*)path;
+ (NSArray<NSNumber *>*)durationsOfFilesAtPath:(NSString*)path;
+ (NSArray<NSNumber *>*)durationsOfMediaURLs:(NSArray<NSURL*>*)URLs;

+ (void)mergeItemsFromPath:(NSString*)fromPath toPath:(NSString*)toPath completionHandler:(CompletionHandler)handler;

//Urls, Asset Urls
+ (AVURLAsset*)assetURLForFilePath:(NSString*)filePath;
+ (AVURLAsset*)assetURLForFileURL:(NSURL*)fileURL;
+ (NSURL*)URLForFilePath:(NSString*)filePath;

+ (void)removeItemAtPath:(NSString*)path;
+ (void)removeItemsAtPath:(NSString*)path;
+ (void)copyItemAtPath:(NSString*)atPath toPath:(NSString*)toPath;
+ (void)moveItemAtPath:(NSString*)atPath toPath:(NSString*)toPath;

//+ (void)removeItemAtURL:(NSURL*)atURL;
//+ (void)removeItemsAtURL:(NSURL*)atURL;
//+ (void)copyItemAtURL:(NSURL*)atURL toURL:(NSURL*)toURL;
//+ (void)moveItemAtURL:(NSURL*)atURL toURL:(NSURL*)toURL;

@end
