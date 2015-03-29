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


#import "JMResourcesListLoader.h"
#import "JSResourceLookup+Helpers.h"

NSString * const kJMResourceListLoaderOptionItemTitleKey = @"JMResourceListLoaderFilterItemTitleKey";
NSString * const kJMResourceListLoaderOptionItemValueKey = @"JMResourceListLoaderFilterItemValueKey";

@interface JMResourcesListLoader ()
@property (nonatomic, strong) NSMutableArray *resources;
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
        _resources = [NSMutableArray array];
        _filterBySelectedIndex = 0;
        _sortBySelectedIndex = 0;
        _needUpdateData = YES;
        _sections = @{
                      @(JMResourcesListSectionTypeFolder) : @[],
                      @(JMResourcesListSectionTypeReportUnit) : @[],
                      };
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
        [self.delegate resourceListLoaderDidStartLoad:self];
        
        self.isLoadingNow = YES;
        [self loadNextPage];
    }
}

- (void)resetState
{
    self.offset = 0;
    self.totalCount = 0;
    self.hasNextPage = NO;
    [self.resources removeAllObjects];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.sections = @{
                      @(JMResourcesListSectionTypeFolder) : @[],
                      @(JMResourcesListSectionTypeReportUnit) : @[],
                      };
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

#pragma mark - Public API
- (NSArray *)loadedResources
{
    return [self.resources copy];
}

- (NSUInteger)resourceCount
{
    return self.resources.count;
}

- (id)resourceAtIndex:(NSInteger)index
{
    return [self.resources objectAtIndex:index];
}

- (void)addResourcesWithResource:(id)resource
{
    [self.resources addObject:resource];
}

- (void)addResourcesWithResources:(NSArray *)resources
{
    [self.resources addObjectsFromArray:resources];
}

- (void)sortLoadedResourcesUsingComparator:(NSComparator)compartor
{
    [self.resources sortUsingComparator:compartor];
}

- (NSArray *)loadedResourcesMatchName:(NSString *)name
{
    NSMutableArray *resources = [NSMutableArray array];
    for (JSResourceLookup *resourceLookup in self.resources) {
        if ([resourceLookup.label containsString:name]) {
            [resources addObject:resourceLookup];
        }
    }
    return [resources copy];
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    self.needUpdateData = NO;
    [self.restClient resourceLookups:self.resourceLookup.uri
                               query:self.searchQuery
                               types:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]
                              sortBy:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]
                           recursive:self.loadRecursively
                              offset:self.offset
                               limit:kJMResourceLimit
                     completionBlock:@weakself(^(JSOperationResult *result)) {
                         if (result.error) {
                             if (result.error.code == JSSessionExpiredErrorCode) {
                                 if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                                     [self loadNextPage];
                                 } else {
                                     [self finishLoadingWithError:result.error];
                                     [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                                         [self loadNextPage];
                                     } @weakselfend];
                                 }
                             } else {
                                 [self finishLoadingWithError:result.error];
                             }
                         } else {
                             [self addResourcesWithResources:result.objects];
                             
                             NSMutableArray *folders = [NSMutableArray arrayWithArray:self.sections[@(JMResourcesListSectionTypeFolder)]];
                             NSMutableArray *reportUnits = [NSMutableArray arrayWithArray:self.sections[@(JMResourcesListSectionTypeReportUnit)]];
                             for (JSResourceLookup *resourceLookup in result.objects) {
                                 if ([resourceLookup isFolder]) {
                                     [folders addObject:resourceLookup];
                                 } else {
                                     [reportUnits addObject:resourceLookup];
                                 }
                             }
                             
                             self.sections = @{
                                               @(JMResourcesListSectionTypeFolder) : [folders copy],
                                               @(JMResourcesListSectionTypeReportUnit) : [reportUnits copy],
                                               };
                             
                             if ([result.allHeaderFields objectForKey:@"Next-Offset"]) {
                                 self.offset = [[result.allHeaderFields objectForKey:@"Next-Offset"] integerValue];
                                 self.hasNextPage = [result.objects count] == kJMResourceLimit;
                             } else {
                                 self.offset += kJMResourceLimit;
                                 if (!self.totalCount) {
                                     self.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
                                 }
                                 self.hasNextPage = self.offset < self.totalCount;
                             }
                             [self finishLoadingWithError:nil];
                         }
                     } @weakselfend];
}

- (void)finishLoadingWithError:(NSError *)error
{
    self.isLoadingNow = NO;
    if (error) {
        [self.delegate resourceListLoaderDidFailed:self withError:error];
    } else {
        [self.delegate resourceListLoaderDidEndLoad:self withResources:[self loadedResources]];
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
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.name", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"label"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.date", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"creationDate"}
                     ];
        default:
            return nil;
    }
}

- (id)parameterForQueryWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            if ([[self listItemsWithOption:option] count] > self.sortBySelectedIndex) {
                return [[[self listItemsWithOption:option] objectAtIndex:self.sortBySelectedIndex] objectForKey:kJMResourceListLoaderOptionItemValueKey];
            }
            break;
        case JMResourcesListLoaderOption_Filter:
            if ([[self listItemsWithOption:option] count] > self.filterBySelectedIndex) {
                return [[[self listItemsWithOption:option] objectAtIndex:self.filterBySelectedIndex] objectForKey:kJMResourceListLoaderOptionItemValueKey];
            }
            break;
    }
    return nil;
}

- (NSString *)titleForPopupWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Filter:
            return JMCustomLocalizedString(@"resources.title", nil);
        case JMResourcesListLoaderOption_Sort:
            return JMCustomLocalizedString(@"resources.sortby.title", nil);
    }
    return nil;
}

@end
