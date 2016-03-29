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
#import "JSResourceLookup+Helpers.h"

NSString * const kJMResourceListLoaderOptionItemTitleKey = @"JMResourceListLoaderFilterItemTitleKey";
NSString * const kJMResourceListLoaderOptionItemValueKey = @"JMResourceListLoaderFilterItemValueKey";

@interface JMResourcesListLoader ()

@property (atomic, strong) NSMutableArray *resourcesFolders;
@property (atomic, strong) NSMutableArray *resourcesItems;
@property (nonatomic, strong) NSMutableArray *allResources;

@property (nonatomic, assign) BOOL needUpdateData;
@property (nonatomic, assign) BOOL isLoadingNow;
@property (nonatomic, assign, readwrite) BOOL hasNextPage;
@property (nonatomic, assign, readwrite) NSInteger offset;
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation JMResourcesListLoader

@synthesize resourceLookup = _resourceLookup;

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLoadingNow = NO;
        _resourcesFolders = [NSMutableArray array];
        _resourcesItems = [NSMutableArray array];
        _filterBySelectedIndex = 0;
        _sortBySelectedIndex = 0;
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

- (NSMutableArray *)allResources
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

- (id)resourceAtIndex:(NSInteger)index
{
    if (index < [self resourceCount]) {
        return self.allResources[index];
    }
    return nil;
}

- (void)addResourcesWithResource:(id)resource
{
    if ([resource isFolder]) {
        [self.resourcesFolders addObject:resource];
    } else {
        [self.resourcesItems addObject:resource];
    }
    self.allResources = nil;
}

- (void)addResourcesWithResources:(NSArray *)resources
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
    [self.restClient resourceLookups:self.resourceLookup.uri
                               query:self.searchQuery
                               types:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]
                              sortBy:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]
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
                             for (JSResourceLookup *resourceLookup in result.objects) {
                                 [strongSelf addResourcesWithResource:resourceLookup];
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
- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.name", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"label"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.creationDate", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"creationDate"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.modifiedDate", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"updateDate"}
                     ];
        case JMResourcesListLoaderOption_Filter:{
            NSMutableArray *options = [@[
                                         @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.reportUnit", nil),
                                           kJMResourceListLoaderOptionItemValueKey: @[kJS_WS_TYPE_REPORT_UNIT]}] mutableCopy];
            if ([JMUtils isServerProEdition]) {
                id dashboardItem = @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.dashboard", nil),
                                     kJMResourceListLoaderOptionItemValueKey: @[kJS_WS_TYPE_DASHBOARD, kJS_WS_TYPE_DASHBOARD_LEGACY]};
                [options addObject:dashboardItem];
            }
            
            if ([options count] > 1) {
                NSMutableArray *allAvailableItems = [NSMutableArray array];
                for (NSDictionary *item in options) {
                    [allAvailableItems addObjectsFromArray:item[kJMResourceListLoaderOptionItemValueKey]];
                }
                id allItem = @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.all", nil), kJMResourceListLoaderOptionItemValueKey: allAvailableItems};
                [options insertObject:allItem atIndex:0];
            }
            
            return options;
        }
        default:
            return nil;
    }
}

- (id)parameterForQueryWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            if ([[self listItemsWithOption:option] count] > self.sortBySelectedIndex) {
                return [[self listItemsWithOption:option][self.sortBySelectedIndex] objectForKey:kJMResourceListLoaderOptionItemValueKey];
            }
            break;
        case JMResourcesListLoaderOption_Filter:
            if ([[self listItemsWithOption:option] count] > self.filterBySelectedIndex) {
                return [[self listItemsWithOption:option][self.filterBySelectedIndex] objectForKey:kJMResourceListLoaderOptionItemValueKey];
            }
            break;
    }
    return nil;
}

- (NSString *)titleForPopupWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Filter:
            return JMCustomLocalizedString(@"resources.filterby.title", nil);
        case JMResourcesListLoaderOption_Sort:
            return JMCustomLocalizedString(@"resources.sortby.title", nil);
    }
    return nil;
}

@end
