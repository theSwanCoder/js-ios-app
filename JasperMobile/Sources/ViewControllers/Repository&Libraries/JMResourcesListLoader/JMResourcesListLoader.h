/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"

extern NSString * const kJMResourceListLoaderOptionItemTitleKey;
extern NSString * const kJMResourceListLoaderOptionItemValueKey;

typedef NS_ENUM(NSInteger, JMResourcesListLoaderOptionType) {
    JMResourcesListLoaderOptionType_Filter,
    JMResourcesListLoaderOptionType_Sort
};

@class JMResourcesListLoader;
@class JMResource;
@class JMResourceLoaderOption;

@protocol JMResourcesListLoaderDelegate <NSObject>
- (void)resourceListLoaderDidStartLoad:(JMResourcesListLoader *)listLoader;
- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray <JMResource *>*)resources;
- (void)resourceListLoaderDidFailed:(JMResourcesListLoader *)listLoader withError:(NSError *)error;
@end

@interface JMResourcesListLoader : NSObject <JMResourceClientHolder> {
    BOOL _isLoadingNow;
    BOOL _needUpdateData;
}

@property (nonatomic, weak) id <JMResourcesListLoaderDelegate> delegate;
// Params for loading request.
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, assign) BOOL      loadRecursively;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString *accessType;
@property (nonatomic, assign) NSInteger filterBySelectedIndex;
@property (nonatomic, assign) NSInteger sortBySelectedIndex;
@property (nonatomic, assign) BOOL isLoadingNow;

- (NSInteger)limitOfLoadingResources;

// start point for loading process
- (void)setNeedsUpdate;
- (void)updateIfNeeded;
//
- (void)loadNextPage;

// helpers
- (NSUInteger)resourceCount;
- (void)addResourcesWithResource:(JMResource *)resource;
- (void)addResourcesWithResources:(NSArray <JMResource *>*)resources;
- (JMResource *)resourceAtIndex:(NSInteger)index;

- (BOOL)validateResourceFilteringBeforeAdding:(JMResource *)resource;

// search
- (void)searchWithQuery:(NSString *)query;
- (void)clearSearchResults;

//
- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)option;
- (id)parameterForQueryWithOptionType:(JMResourcesListLoaderOptionType)optionType;

- (void)finishLoadingWithError:(NSError *)error;
@end
