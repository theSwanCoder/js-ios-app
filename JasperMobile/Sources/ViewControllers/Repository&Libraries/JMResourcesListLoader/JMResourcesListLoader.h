/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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

// search
- (void)searchWithQuery:(NSString *)query;
- (void)clearSearchResults;

//
- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)option;
- (id)parameterForQueryWithOptionType:(JMResourcesListLoaderOptionType)optionType;
- (NSString *)titleForPopupWithOptionType:(JMResourcesListLoaderOptionType)optionType;

- (void)finishLoadingWithError:(NSError *)error;
@end
