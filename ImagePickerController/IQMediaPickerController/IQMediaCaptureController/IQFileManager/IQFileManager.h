//
//  IQFileManager.h
//  ImagePickerController
//
//  Created by Iftekhar on 06/08/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVURLAsset;

typedef void(^CompletionHandler)(BOOL merged);

@interface IQFileManager : NSObject

+ (NSString*)IQDocumentDirectory;
+ (NSString*)IQTemporaryDirectory;

+ (NSArray*)filesAtPath:(NSString*)path;
+ (CGFloat)durationOfFileAtPath:(NSString*)path;
+ (NSArray*)durationsOfFilesAtPath:(NSString*)path;
+ (NSArray*)durationsOfMediaURLs:(NSArray*)URLs;

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
