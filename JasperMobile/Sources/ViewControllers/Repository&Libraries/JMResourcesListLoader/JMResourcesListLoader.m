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


#import "JaspersoftSDK.h"
#import "NSObject+Additions.h"
#import "JMResourcesListLoader.h"
#import "JMResource.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import "JMLocalization.h"

NSString * const kJMResourceListLoaderOptionItemTitleKey = @"JMResourceListLoaderFilterItemTitleKey";
NSString * const kJMResourceListLoaderOptionItemValueKey = @"JMResourceListLoaderFilterItemValueKey";

@interface JMResourcesListLoader ()

@property (atomic, strong) NSMutableArray <JMResource *>*resourcesFolders;
@property (atomic, strong) NSMutableArray <JMResource *>*resourcesItems;
@property (nonatomic, strong) NSMutableArray <JMResource *>*allResources;

@property (nonatomic, assign) BOOL needUpdateData;
@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, strong) NSArray *sortByAllOptions;
@property (nonatomic, strong) NSArray *filterByAllOptions;

@end

@implementation JMResourcesListLoader
@synthesize resource = _resource;
@synthesize isLoadingNow = _isLoadingNow;

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
        
        _filterBySelectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[self filterBySelectedIndexKey]];
        _sortBySelectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[self sortBySelectedIndexKey]];
    }
    return self;
}

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.filterBySelectedIndex
                                               forKey:[self filterBySelectedIndexKey]];
    [[NSUserDefaults standardUserDefaults] setInteger:self.sortBySelectedIndex
                                               forKey:[self sortBySelectedIndexKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (NSString *)accessType
{
    NSString *sortByString = [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort];
    return [sortByString isEqualToString:@"accessTime"] ? @"viewed" : nil;
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
    id currentFilterOptionValue = [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Filter];
    NSArray *supportedFilterTypes = [currentFilterOptionValue isKindOfClass:[NSArray class]] ? currentFilterOptionValue : @[currentFilterOptionValue];
    
    //We should send kJS_WS_TYPE_UNKNOW here according to http://jira.jaspersoft.com/browse/JRS-11049
    if ([supportedFilterTypes indexOfObject:resource.resourceLookup.resourceType] != NSNotFound) {
        if (resource.type == JMResourceTypeFolder) {
            [self.resourcesFolders addObject:resource];
        } else {
            [self.resourcesItems addObject:resource];
        }
        self.allResources = nil;
    }
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
- (NSArray <JMResourcesListLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            if (!self.sortByAllOptions) {
                self.sortByAllOptions = [self sortByAvailableOptions];
            }
            return self.sortByAllOptions;
        }
        case JMResourcesListLoaderOptionType_Filter:{
            if (!self.filterByAllOptions) {
                NSArray *allAvailableOptions = [self filterByAvailableOptions];
                
                if (allAvailableOptions.count > 1) {
                    NSMutableSet *optionValues = [NSMutableSet set];
                    for (JMResourcesListLoaderOption * option in allAvailableOptions) {
                        if ([option.value isKindOfClass:[NSArray class]]) {
                            [optionValues addObjectsFromArray:option.value];
                        } else {
                            [optionValues addObject:option.value];
                        }
                    }
                    JMResourcesListLoaderOption *allItemsFilterOption = [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Filter
                                                                                                              title:JMLocalizedString(@"resources_filterby_type_all")
                                                                                                              value:[optionValues allObjects]];
                    NSMutableArray *allOptions = [NSMutableArray arrayWithObject:allItemsFilterOption];
                    [allOptions addObjectsFromArray:allAvailableOptions];
                    self.filterByAllOptions = [allOptions copy];
                } else {
                    self.filterByAllOptions = allAvailableOptions;
                }
            }
            
            return self.filterByAllOptions;
        }
    }
}

- (NSArray <JMResourcesListLoaderOption *>*)sortByAvailableOptions
{
    NSArray *allOptions = @[
                            [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Sort
                                                                  title:JMLocalizedString(@"resources_sortby_name")
                                                                  value:@"label"],
                            [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Sort
                                                                  title:JMLocalizedString(@"resources_sortby_creationDate")
                                                                  value:@"creationDate"],
                            [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Sort
                                                                  title:JMLocalizedString(@"resources_sortby_modifiedDate")
                                                                  value:@"updateDate"]
                            ];
    return allOptions;
}

- (NSArray <JMResourcesListLoaderOption *>*)filterByAvailableOptions
{
    NSMutableArray *allOptions;
    // reports
    JMResourcesListLoaderOption *reportFilterOption = [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Filter
                                                                                            title:JMLocalizedString(@"resources_filterby_type_reportUnit")
                                                                                            value:@[kJS_WS_TYPE_REPORT_UNIT]];
    allOptions = [NSMutableArray arrayWithObject:reportFilterOption];
    
    if ([JMUtils isServerProEdition]) {
        // dashboards
        NSArray *dashboardsValues = @[kJS_WS_TYPE_DASHBOARD, kJS_WS_TYPE_DASHBOARD_LEGACY];
        JMResourcesListLoaderOption *dashboardFilterOption = [JMResourcesListLoaderOption optionWithType:JMResourcesListLoaderOptionType_Filter
                                                                                                   title:JMLocalizedString(@"resources_filterby_type_dashboard")
                                                                                                   value:dashboardsValues];
        [allOptions addObject:dashboardFilterOption];
    }
    return [allOptions copy];
}

- (NSArray *)parameterForQueryWithOptionType:(JMResourcesListLoaderOptionType)optionType
{
    NSArray *allOptions = [self listItemsWithOption:optionType];
    NSInteger optionSelectedIndex;
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort:
        optionSelectedIndex = self.sortBySelectedIndex;
        break;
        
        case JMResourcesListLoaderOptionType_Filter:
        optionSelectedIndex = self.filterBySelectedIndex;
        break;
    }
    
    if (allOptions.count > optionSelectedIndex) {
        JMResourcesListLoaderOption *option = allOptions[optionSelectedIndex];
        return option.value;
    }
    return nil;
}

- (NSString *)filterBySelectedIndexKey
{
    return [NSString stringWithFormat:@"%@FilterByIndexKey", NSStringFromClass([self class])];
}

- (NSString *)sortBySelectedIndexKey
{
    return [NSString stringWithFormat:@"%@SortByIndexKey", NSStringFromClass([self class])];
}
@end
