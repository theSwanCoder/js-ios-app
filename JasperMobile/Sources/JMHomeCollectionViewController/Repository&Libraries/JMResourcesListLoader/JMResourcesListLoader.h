//
//  JMResourcesListLoader.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"
#import "JMPagination.h"

typedef NS_ENUM(NSInteger, JMResourcesListLoaderObjectType) {
    JMResourcesListLoaderObjectType_Folders = 1 << 0,
    JMResourcesListLoaderObjectType_Reports = 1 << 1,
    JMResourcesListLoaderObjectType_Dashboards = 1 << 2,
    
    JMResourcesListLoaderObjectType_LibraryAll = (JMResourcesListLoaderObjectType_Reports | JMResourcesListLoaderObjectType_Dashboards),
    JMResourcesListLoaderObjectType_RepositoryAll = (JMResourcesListLoaderObjectType_LibraryAll | JMResourcesListLoaderObjectType_Folders)
};

typedef NS_ENUM(NSInteger, JMResourcesListLoaderSortBy) {
    JMResourcesListLoaderSortBy_Name = 0,
    JMResourcesListLoaderSortBy_Date
};

typedef NS_ENUM(NSInteger, JMResourcesListLoaderFilterBy) {
    JMResourcesListLoaderFilterBy_None = 0,
    JMResourcesListLoaderFilterBy_Favorites
};


@class JMResourcesListLoader;
@protocol JMResourcesListLoaderDelegate <NSObject>
@required
- (void)resourceListDidStartLoading:(JMResourcesListLoader *)listLoader;
- (void)resourceListDidLoaded:(JMResourcesListLoader *)listLoader withError:(NSError *)error;

@end

@interface JMResourcesListLoader : NSObject <JMResourceClientHolder, JMPagination> {
    BOOL _isLoadingNow;
    BOOL _needUpdateData;

}

@property (nonatomic, weak) id <JMResourcesListLoaderDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *resources;

// Params for loading request.
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, assign) BOOL      loadRecursively;
@property (nonatomic, assign) JMResourcesListLoaderObjectType resourcesType;
@property (nonatomic, assign) JMResourcesListLoaderSortBy sortBy;
@property (nonatomic, assign) JMResourcesListLoaderFilterBy filterBy;

- (void)setNeedsUpdate;

- (void)updateIfNeeded;

- (void)searchWithQuery:(NSString *)query;

- (void)clearSearchResults;

- (NSString *)sortByParameterForQuery;

- (NSString *)filterByParameterForQuery;

- (NSArray *)resourcesTypesParameterForQuery;

@end
