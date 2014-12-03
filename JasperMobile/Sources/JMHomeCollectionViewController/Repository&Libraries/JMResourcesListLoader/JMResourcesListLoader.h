/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMResourcesListLoader.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

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

@class JMResourcesListLoader;
@protocol JMResourcesListLoaderDelegate <NSObject>
@required
- (void)resourceListDidStartLoading:(JMResourcesListLoader *)listLoader;
- (void)resourceListDidLoaded:(JMResourcesListLoader *)listLoader withError:(NSError *)error;

@end

@interface JMResourcesListLoader : NSObject <JMResourceClientHolder> {
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
@property (nonatomic, readonly) BOOL hasNextPage;
@property (nonatomic, readonly) NSInteger offset;

- (void)setNeedsUpdate;

- (void)updateIfNeeded;

- (void)searchWithQuery:(NSString *)query;

- (void)clearSearchResults;

- (void)loadNextPage;

- (NSString *)sortByParameterForQuery;

- (NSArray *)resourcesTypesParameterForQuery;

@end
