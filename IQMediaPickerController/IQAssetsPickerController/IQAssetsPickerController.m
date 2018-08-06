//
//  IQAssetsPickerController.m
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


#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>

#import "IQAssetsPickerController.h"
#import "IQAssetsAlbumViewCell.h"

@interface IQAssetsPickerController ()

@property UIBarButtonItem *cancelBarButton;
@property UIBarButtonItem *doneBarButton;
@property UIBarButtonItem *selectedMediaCountItem;

@property (nonatomic, strong) NSArray<NSArray<PHCollection*>*> *sections;

@property(nonatomic, strong) NSMutableDictionary *albumCache;
@property(nonatomic, assign) BOOL isLoading;

@end

@implementation IQAssetsPickerController

#pragma - mark View lifecycle

-(void)dealloc
{
    [_albumCache removeAllObjects];
    _albumCache = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectedItems = [[NSMutableArray alloc] init];
    _albumCache = [[NSMutableDictionary alloc] init];

    //If top level framework
    if(self.collectionList == nil)
    {
        self.navigationItem.title = @"All Albums";
    }
    else
    {
        self.navigationItem.title = self.collectionList.localizedTitle;
    }
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    if (self.collectionList == nil)
    {
        self.cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
        [self.navigationItem setLeftBarButtonItem:self.cancelBarButton];
    }
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.selectedMediaCountItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedMediaCountItem.possibleTitles = [NSSet setWithObject:@"999 media selected"];
    self.selectedMediaCountItem.enabled = NO;
    
    self.toolbarItems = @[flexItem,self.selectedMediaCountItem,flexItem];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    self.tableView.rowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[IQAssetsAlbumViewCell class] forCellReuseIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class])];
    
    [self refreshAlbumList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (self.tableView.numberOfSections > 0)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections-1)] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self updateSelectedCountAnimated:animated];
}

-(void)refreshAlbumList
{
    self.isLoading = YES;
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    
    [_albumCache removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    
    [operationQueue addOperationWithBlock:^{
        
        NSMutableArray <PHCollection*> *allCollections = [[NSMutableArray alloc] init];
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        
        NSMutableArray<NSPredicate*> *predicates = [[NSMutableArray alloc] init];
        
        for (NSNumber *mediaType in weakSelf.mediaTypes) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %@",mediaType];
            [predicates addObject:predicate];
        }
        
        NSCompoundPredicate *finalPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
        
        options.predicate = finalPredicate;
        
        NSMutableArray<NSArray<PHCollection*>*> *allSections = [[NSMutableArray alloc] init];
        //If top level framework
        if(weakSelf.collectionList == nil)
        {
            {
                PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                
                NSMutableArray<PHAssetCollection*> *smartCollections = [[NSMutableArray alloc] init];
                for (PHAssetCollection *collection in smartAlbums)
                {
                    PHAssetCollection *assetCollection = (PHAssetCollection*)collection;
                    
                    PHFetchResult<PHAsset*> * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                    
                    if (fetchResult.count > 0)
                    {
                        NSMutableDictionary *dict = [@{@"count":@(fetchResult.count)} mutableCopy];
                        weakSelf.albumCache[collection.localIdentifier] = dict;
                        [smartCollections addObject:assetCollection];
                    }
                }
                
                [allSections addObject:smartCollections];
            }

            {
                PHFetchResult<PHCollection *> *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                
                NSMutableArray<PHCollection*> *collectionsToKeep = [[NSMutableArray alloc] init];
                
                for (PHCollection *collection in userCollections)
                {
                    if ([collection canContainAssets])
                    {
                        PHAssetCollection *assetCollection = (PHAssetCollection*)collection;
                        
                        PHFetchResult<PHAsset*> * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                        
                        if (fetchResult.count > 0)
                        {
                            NSMutableDictionary *dict = [@{@"count":@(fetchResult.count)} mutableCopy];
                            weakSelf.albumCache[collection.localIdentifier] = dict;
                            [collectionsToKeep addObject:collection];
                        }
                    }
                    else if ([collection canContainCollections])
                    {
                        PHCollectionList *collectionList = (PHCollectionList*)collection;
                        
                        PHFetchResult<PHCollection *> *fetchResult = [PHCollection fetchCollectionsInCollectionList:collectionList options:nil];
                        
                        if (fetchResult.count > 0)
                        {
                            NSMutableDictionary *dict = [@{@"count":@(fetchResult.count)} mutableCopy];
                            weakSelf.albumCache[collection.localIdentifier] = dict;
                            [collectionsToKeep addObject:collection];
                        }
                    }
                }

                [allSections addObject:collectionsToKeep];
            }
        }
        else
        {
            PHFetchResult<PHCollection *> *fetchResult = [PHCollection fetchCollectionsInCollectionList:weakSelf.collectionList options:nil];
            
            NSMutableArray<PHCollection*> *collectionsToKeep = [[NSMutableArray alloc] init];

            for (int x = 0; x < fetchResult.count; x ++)
            {
                PHCollection *collection = fetchResult[x];
                [allCollections addObject:collection];
                
                if ([collection canContainAssets])
                {
                    PHAssetCollection *assetCollection = (PHAssetCollection*)collection;
                    
                    PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection
                                                                                options:options];
                    
                    NSMutableDictionary *dict = [@{@"count":@(fetchResult.count)} mutableCopy];
                    weakSelf.albumCache[collection.localIdentifier] = dict;
                    [collectionsToKeep addObject:collection];
                }
                else if ([collection canContainCollections])
                {
                    PHCollectionList *collectionList = (PHCollectionList*)collection;
                    
                    PHFetchResult<PHCollection *> *fetchResult = [PHCollection fetchCollectionsInCollectionList:collectionList options:nil];
                    
                    NSMutableDictionary *dict = [@{@"count":@(fetchResult.count)} mutableCopy];
                    weakSelf.albumCache[collection.localIdentifier] = dict;
                    [collectionsToKeep addObject:collection];
                }
            }

            [allSections addObject:collectionsToKeep];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.isLoading = NO;
            weakSelf.sections = allSections;
            
            if (allSections.count > 0)
            {
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, allSections.count)] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                [weakSelf.tableView reloadData];
            }
        }];
    }];
}

-(void)setMediaTypes:(NSArray<NSNumber *> *)mediaTypes
{
    _mediaTypes = [[NSMutableOrderedSet orderedSetWithArray:mediaTypes] array];
}

-(void)updateSelectedCountAnimated:(BOOL)animated
{
    if ([self.selectedItems count])
    {
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:animated];
        [self.navigationController setToolbarHidden:NO animated:animated];
        
        NSString *finalText = [NSString stringWithFormat:@"%lu Media selected",(unsigned long)[self.selectedItems count]];
        
        if (self.maximumItemCount > 0)
        {
            finalText = [finalText stringByAppendingFormat:@" (%lu maximum) ",(unsigned long)self.maximumItemCount];
        }

        self.selectedMediaCountItem.title = finalText;
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
        [self.navigationController setToolbarHidden:YES animated:animated];
        self.selectedMediaCountItem.title = nil;
    }
}

-(void)sendFinalSelectedAssets
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didPickAssets:)])
    {
        [self.delegate assetsPickerController:self didPickAssets:self.selectedItems];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction:(UIBarButtonItem *)sender
{
    [self sendFinalSelectedAssets];
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
    {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (_collectionList == nil ? 44 : 0);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_collectionList == nil)
    {
        if (section == 0)
        {
            return @"Albums";
        }
        else if (section == 1)
        {
            return @"My Albums";
        }
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.isLoading == YES && self.sections == nil)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.color = [UIColor lightGrayColor];
        [activityIndicator startAnimating];
        
        tableView.backgroundView = activityIndicator;
    }
    else if (self.sections.count == 0 || (self.sections.count == 1 && self.sections.firstObject.count == 0))
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame)-20, 0)];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        
        NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0],NSForegroundColorAttributeName:[UIColor darkGrayColor]};
        NSDictionary *messageAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor grayColor]};

        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Empty Folder" attributes:titleAttributes];
        NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:@"\n\nThis folder contains no albums" attributes:messageAttributes];
        NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] init];
        [finalMessage appendAttributedString:attributedTitle];
        [finalMessage appendAttributedString:attributedMessage];
        label.attributedText = finalMessage;

        CGSize labelNewSize = [label sizeThatFits:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)];
        
        label.frame = CGRectMake(0, 0, label.frame.size.width, labelNewSize.height);
        
        tableView.backgroundView = label;
    }
    else
    {
        tableView.backgroundView = nil;
    }
    
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQAssetsAlbumViewCell *albumCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IQAssetsAlbumViewCell class]) forIndexPath:indexPath];
    [albumCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    PHCollection * collection = self.sections[indexPath.section][indexPath.row];

    NSMutableDictionary *cacheDict = _albumCache[collection.localIdentifier];
    albumCell.labelTitle.text = collection.localizedTitle;
    albumCell.imageViewAlbum.image = cacheDict[@"image"];
    albumCell.labelSubTitle.text = [NSString stringWithFormat:@"%@",cacheDict[@"count"]?:@""];
    
    albumCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (albumCell.imageViewAlbum.image == nil)
    {
        __weak typeof(self) weakSelf = self;

        __weak IQAssetsAlbumViewCell * weakCell = albumCell;

        CGRect imageViewFrame = albumCell.imageViewAlbum.frame;
        
        //PHAssetCollection
        if ([collection canContainAssets])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection*)collection;
            
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            operationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
            
            [operationQueue addOperationWithBlock:^{
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                
                NSMutableArray<NSPredicate*> *predicates = [[NSMutableArray alloc] init];
                
                for (NSNumber *mediaType in weakSelf.mediaTypes) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %@",mediaType];
                    [predicates addObject:predicate];
                }
                
                NSCompoundPredicate *finalPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
                
                options.predicate = finalPredicate;
                if ([options respondsToSelector:@selector(setFetchLimit:)])
                {
                    options.fetchLimit = 1;
                }

                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

                PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection
                                                                            options:options];
                
                if ([fetchResult lastObject])
                {
                    PHImageRequestOptions * options = [PHImageRequestOptions new];
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    options.synchronous = NO;
                    
                    CGFloat scale = [[UIScreen mainScreen] scale];
                    CGSize targetSize = CGSizeMake(imageViewFrame.size.width*scale, imageViewFrame.size.height*scale);
                    
                    [[PHImageManager defaultManager] requestImageForAsset:[fetchResult lastObject] targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            cacheDict[@"image"] = result;
                            
                            weakCell.imageViewAlbum.image = result;
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
                        [[NSOperationQueue mainQueue] addOperation:operation];
                    }];
                }
                else
                {
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        
                        weakCell.imageViewAlbum.image = nil;
                    }];
                    
                    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
                    [[NSOperationQueue mainQueue] addOperation:operation];
                }
            }];
        }
        else if ([collection canContainCollections])
        {
            weakCell.imageViewAlbum.image = nil;
        }
    }
    
    return albumCell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PHCollection *collection = self.sections[indexPath.section][indexPath.row];
    
    if ([collection canContainAssets])
    {
        PHAssetCollection *assetCollection = (PHAssetCollection*)collection;

        IQAlbumAssetsViewController *assetsVC = [[IQAlbumAssetsViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        assetsVC.mediaTypes = self.mediaTypes;
        assetsVC.collection =  assetCollection;
        assetsVC.assetController = self;
        [self.navigationController pushViewController:assetsVC animated:YES];
    }
    else if ([collection canContainCollections])
    {
        PHCollectionList *collectionList = (PHCollectionList*)collection;

        IQAssetsPickerController *assetsVC = [[IQAssetsPickerController alloc] init];
        assetsVC.collectionList = collectionList;
        assetsVC.delegate = self.delegate;
        assetsVC.allowsPickingMultipleItems = self.allowsPickingMultipleItems;
        assetsVC.maximumItemCount = self.maximumItemCount;
        assetsVC.mediaTypes = self.mediaTypes;
        assetsVC.selectedItems = self.selectedItems;
        [self.navigationController pushViewController:assetsVC animated:YES];
    }
}

@end
