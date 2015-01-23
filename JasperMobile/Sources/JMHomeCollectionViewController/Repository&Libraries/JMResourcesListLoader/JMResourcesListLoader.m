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
#import "JMRequestDelegate.h"

NSString * const kJMResourceListLoaderOptionItemTitleKey = @"JMResourceListLoaderFilterItemTitleKey";
NSString * const kJMResourceListLoaderOptionItemValueKey = @"JMResourceListLoaderFilterItemValueKey";

@interface JMResourcesListLoader ()
@property (nonatomic, assign) BOOL needUpdateData;
@property (nonatomic, assign) BOOL isLoadingNow;
@property (nonatomic, assign, readwrite) BOOL hasNextPage;
@property (nonatomic, assign, readwrite) NSInteger offset;
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation JMResourcesListLoader
objection_requires(@"resourceClient", @"constants")

@synthesize resourceLookup = _resourceLookup;
@synthesize resourceClient = _resourceClient;

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        _isLoadingNow = NO;
        _resources = [NSMutableArray array];
        _filterBySelectedIndex = 0;
        _sortBySelectedIndex = 0;
        _needUpdateData = YES;
    }
    return self;
}

- (void)setNeedsUpdate
{
    self.needUpdateData = YES;
}

- (void)updateIfNeeded
{
    if (self.needUpdateData && !self.isLoadingNow) {
        // Reset state
        self.offset = 0;
        self.totalCount = 0;
        self.hasNextPage = NO;
        [self.resources removeAllObjects];
        [self.delegate resourceListDidStartLoading:self];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        self.isLoadingNow = YES;
        [self loadNextPage];
    }
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

#pragma mark - JMPagination

- (void)loadNextPage
{
    self.needUpdateData = NO;
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        [self.resources addObjectsFromArray:result.objects];

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
        
        self.isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
        
    } @weakselfend
    errorBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        self.isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:result.error];
    } @weakselfend];
    
    [self.resourceClient resourceLookups:self.resourceLookup.uri
                                   query:self.searchQuery
                                   types:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]
                                  sortBy:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]
                               recursive:self.loadRecursively
                                  offset:self.offset
                                   limit:kJMResourceLimit
                                delegate:delegate];
}

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

- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.sortby.type.name", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"label"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.sortby.type.date", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"creationDate"}];
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
            return JMCustomLocalizedString(@"master.resources.title", nil);
        case JMResourcesListLoaderOption_Sort:
            return JMCustomLocalizedString(@"master.sortby.title", nil);
    }
    return nil;
}

@end
