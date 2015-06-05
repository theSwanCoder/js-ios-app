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

extern NSString * const kJMResourceListLoaderOptionItemTitleKey;
extern NSString * const kJMResourceListLoaderOptionItemValueKey;

typedef NS_ENUM(NSInteger, JMResourcesListLoaderOption) {
    JMResourcesListLoaderOption_Filter = 0,
    JMResourcesListLoaderOption_Sort
};

typedef NS_ENUM(NSInteger, JMResourcesListSectionType) {
    JMResourcesListSectionTypeFolder,
    JMResourcesListSectionTypeReportUnit
};


@class JMResourcesListLoader;
@protocol JMResourcesListLoaderDelegate <NSObject>
- (void)resourceListLoaderDidStartLoad:(JMResourcesListLoader *)listLoader;
- (void)resourceListLoaderDidEndLoad:(JMResourcesListLoader *)listLoader withResources:(NSArray *)resources;
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
@property (nonatomic, readonly) BOOL hasNextPage;
@property (nonatomic, readonly) NSInteger offset;
@property (nonatomic, readonly) NSString *accessType;
@property (nonatomic, assign) NSInteger filterBySelectedIndex;
@property (nonatomic, assign) NSInteger sortBySelectedIndex;

@property (nonatomic, copy) NSDictionary *sections;


// start point for loading process
- (void)setNeedsUpdate;
- (void)updateIfNeeded;
//
- (void)loadNextPage;

// helpers
- (NSUInteger)resourceCount;
- (void)addResourcesWithResource:(id)resource;
- (void)addResourcesWithResources:(NSArray *)resources;
- (id)resourceAtIndex:(NSInteger)index;
- (void)sortLoadedResourcesUsingComparator:(NSComparator)compartor;

// search
- (void)searchWithQuery:(NSString *)query;
- (void)clearSearchResults;

//
- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option;
- (id)parameterForQueryWithOption:(JMResourcesListLoaderOption)option;
- (NSString *)titleForPopupWithOption:(JMResourcesListLoaderOption)option;

- (void)finishLoadingWithError:(NSError *)error;
@end
