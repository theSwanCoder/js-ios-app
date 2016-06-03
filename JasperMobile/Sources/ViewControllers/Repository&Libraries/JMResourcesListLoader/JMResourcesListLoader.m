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


#import "JMResourcesListLoader.h"
#import "JMResource.h"
#import "JMResourceLoaderOption.h"

NSString * const kJMResourceListLoaderOptionItemTitleKey = @"JMResourceListLoaderFilterItemTitleKey";
NSString * const kJMResourceListLoaderOptionItemValueKey = @"JMResourceListLoaderFilterItemValueKey";

@interface JMResourcesListLoader ()

@property (atomic, strong) NSMutableArray <JMResource *>*resourcesFolders;
@property (atomic, strong) NSMutableArray <JMResource *>*resourcesItems;
@property (nonatomic, strong) NSMutableArray <JMResource *>*allResources;

@property (nonatomic, assign) BOOL needUpdateData;
@property (nonatomic, assign) BOOL isLoadingNow;
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation JMResourcesListLoader
@synthesize resource = _resource;

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLoadingNow = NO;
        _resourcesFolders = [NSMutableArray array];
        _resourcesItems = [NSMutableArray array];
        _needUpdateData = YES;
        _loadRecursively = YES;
    }
    return self;
}

#pragma mark - Change state API

- (void)setNeedsUpdate
{
    self.needUpdateData = YES;
}

- (void)updateIfNeeded
{
    if (self.needUpdateData && !self.isLoadingNow) {
        [self resetState];
        self.isLoadingNow = YES;
        
        [self.delegate resourceListLoaderDidStartLoad:self];
        [self loadNextPage];
    }
}

- (void)resetState
{
    self.offset = 0;
    self.totalCount = 0;
    self.hasNextPage = NO;
    self.allResources = nil;
    [self.resourcesFolders removeAllObjects];
    [self.resourcesItems removeAllObjects];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Properties
- (void)setFilterBySelectedIndex:(NSInteger)filterBySelectedIndex
{
    if (_filterBySelectedIndex != filterBySelectedIndex) {
        _filterBySelectedIndex = filterBySelectedIndex;
        [self setNeedsUpdate];
        [self updateIfNeeded];
    }
}

- (void)setSortBySelectedIndex:(NSInteger)sortBySelectedIndex
{
    if (_sortBySelectedIndex != sortBySelectedIndex) {
        _sortBySelectedIndex = sortBySelectedIndex;
        [self setNeedsUpdate];
        [self updateIfNeeded];
    }
}

- (NSInteger)limitOfLoadingResources
{
    return kJMResourceLimit;
}

- (NSArray <JMResource *>*)allResources
{
    if (!_allResources && [_allResources count] == 0) {
        _allResources = [NSMutableArray arrayWithArray:self.resourcesFolders];
        [_allResources addObjectsFromArray:self.resourcesItems];
    }
    return _allResources;
}

#pragma mark - Public API
- (NSUInteger)resourceCount
{
    return self.allResources.count;
}

- (JMResource *)resourceAtIndex:(NSInteger)index
{
    if (index < [self resourceCount]) {
        return self.allResources[index];
    }
    return nil;
}

- (void)addResourcesWithResource:(JMResource *)resource
{
    if (resource.type == JMResourceTypeFolder) {
        [self.resourcesFolders addObject:resource];
    } else {
        [self.resourcesItems addObject:resource];
    }
    self.allResources = nil;
}

- (void)addResourcesWithResources:(NSArray <JMResource *>*)resources
{
    for (id resource in resources) {
        [self addResourcesWithResource:resource];
    }
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    self.needUpdateData = NO;
    __weak typeof(self)weakSelf = self;
    [self.restClient resourceLookups:self.resource.resourceLookup.uri
                               query:self.searchQuery
                               types:[self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Filter]
                              sortBy:[self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort]
                          accessType:self.accessType
                           recursive:self.loadRecursively
                              offset:self.offset
                               limit:[self limitOfLoadingResources]
                     completionBlock:^(JSOperationResult *result) {
                         __strong typeof(self)strongSelf = weakSelf;
                         if (result.error) {
                             if (result.error.code == JSSessionExpiredErrorCode) {
                                 [JMUtils showLoginViewAnimated:YES completion:nil];
                             } else {
                                 [strongSelf finishLoadingWithError:result.error];
                             }
                         } else {
                             for (id resourceLookup in result.objects) {
                                 if ([resourceLookup isKindOfClass:[JSResourceLookup class]]) {
                                     JMResource *resource = [JMResource resourceWithResourceLookup:resourceLookup];
                                     [strongSelf addResourcesWithResource:resource];
                                 }
                             }
                             
                             if (result.allHeaderFields[@"Next-Offset"]) {
                                 strongSelf.offset = [result.allHeaderFields[@"Next-Offset"] integerValue];
                                 strongSelf.hasNextPage = [result.objects count] == kJMResourceLimit;
                             } else {
                                 strongSelf.offset += kJMResourceLimit;
                                 if (!strongSelf.totalCount) {
                                     strongSelf.totalCount = [result.allHeaderFields[@"Total-Count"] integerValue];
                                 }
                                 strongSelf.hasNextPage = strongSelf.offset < strongSelf.totalCount;
                             }
                             [strongSelf finishLoadingWithError:nil];
                             
                         }
                     }];
}

- (void)finishLoadingWithError:(NSError *)error
{
    self.isLoadingNow = NO;
    if (error) {
        [self.delegate resourceListLoaderDidFailed:self withError:error];
    } else {
        [self.delegate resourceListLoaderDidEndLoad:self withResources:self.allResources];
    }
}

#pragma mark - Search
- (void)searchWithQuery:(NSString *)query
{
    if (![self.searchQuery isEqualToString:query]) {
        self.searchQuery = query;
        [self setNeedsUpdate];
        [self updateIfNeeded];
    }
}

- (void)clearSearchResults
{
    if (self.searchQuery) {
        self.searchQuery = nil;
        [self setNeedsUpdate];
        [self updateIfNeeded];
    }
}

#pragma mark - Utils
- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            NSArray *allOptions = @[
                    [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_sortby_name", nil)
                                                      value:@"label"],
                    [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_sortby_creationDate", nil)
                                                      value:@"creationDate"],
                    [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_sortby_modifiedDate", nil)
                                                      value:@"updateDate"]
            ];
            return allOptions;
        }
        case JMResourcesListLoaderOptionType_Filter:{
            NSArray *allOptions;
            if ([JMUtils isServerProEdition]) {
                // reports
                NSArray *reportsValues = @[kJS_WS_TYPE_REPORT_UNIT];
                JMResourceLoaderOption *reportFilterOption = [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_filterby_type_reportUnit", nil)
                                                                                               value:reportsValues];
                // dashboards
                NSArray *dashboardsValues = @[kJS_WS_TYPE_DASHBOARD, kJS_WS_TYPE_DASHBOARD_LEGACY];
                JMResourceLoaderOption *dashboardFilterOption = [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_filterby_type_dashboard", nil)
                                                                                                  value:dashboardsValues];
                // all
                NSArray *allValues = reportsValues;
                allValues = [allValues arrayByAddingObjectsFromArray:dashboardsValues];
                JMResourceLoaderOption *allItemsFilterOption = [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_filterby_type_all", nil)
                                                                                           value:allValues];
                allOptions = @[
                        allItemsFilterOption,
                        reportFilterOption,
                        dashboardFilterOption
                ];
            } else {
                NSArray *reportsValues = @[kJS_WS_TYPE_REPORT_UNIT];
                JMResourceLoaderOption *reportFilterOption = [JMResourceLoaderOption optionWithTitle:JMCustomLocalizedString(@"resources_filterby_type_reportUnit", nil)
                                                                                               value:reportsValues];
                allOptions = @[
                        reportFilterOption
                ];
            }
            return allOptions;
        }
    }
}

- (id)parameterForQueryWithOptionType:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            NSArray *allSortOptions = [self listItemsWithOption:optionType];
            if (allSortOptions.count > self.sortBySelectedIndex) {
                JMResourceLoaderOption *option = allSortOptions[self.sortBySelectedIndex];
                id value = option.value;
                return value;
            }
            break;
        }
        case JMResourcesListLoaderOptionType_Filter:
            if ([JMUtils isServerProEdition]) {
                return [[self listItemsWithOption:optionType][self.filterBySelectedIndex] value];
            } else {
                return [[self listItemsWithOption:optionType].firstObject value];
            }
            break;
    }
    return nil;
}

- (NSString *)titleForPopupWithOptionType:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Filter:
            return JMCustomLocalizedString(@"resources_filterby_title", nil);
        case JMResourcesListLoaderOptionType_Sort:
            return JMCustomLocalizedString(@"resources_sortby_title", nil);
    }
    return nil;
}

@end
