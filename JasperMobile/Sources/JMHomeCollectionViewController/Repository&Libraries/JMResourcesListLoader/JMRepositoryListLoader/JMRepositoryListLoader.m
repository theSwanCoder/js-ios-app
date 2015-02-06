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


#import "JMRepositoryListLoader.h"
#import "JMRequestDelegate.h"

@interface JMRepositoryListLoader ()

@property (nonatomic, strong) NSMutableArray *rootFolders;
@property (nonatomic, strong) NSMutableArray *rootFoldersURIs;

@end

@implementation JMRepositoryListLoader
- (id)init
{
    self = [super init];
    if (self) {
        self.rootFolders = [NSMutableArray array];
    }
    return self;
}

- (BOOL)loadRecursively
{
    return !!self.searchQuery;
}

- (void)loadNextPage
{
    if (self.resourceLookup || (!self.resourceLookup && [self.searchQuery length])) {
        [super loadNextPage];
    } else {
        _needUpdateData = NO;
        
        if (![self.rootFolders count]) {
            [self loadResourceLookup:[self.rootFoldersURIs lastObject]];
        } else {
            [self finishLoading];
        }
    }
}

- (NSMutableArray *)rootFoldersURIs
{
    if (!_rootFoldersURIs) {
        _rootFoldersURIs = [NSMutableArray arrayWithObject:@"/"];
        if ([self.resourceClient.serverInfo.edition isEqualToString:self.constants.SERVER_EDITION_PRO]) {
            [_rootFoldersURIs addObject:@"/public"];
        }
    }
    return _rootFoldersURIs;
}

- (void)loadResourceLookup:(NSString *)resourceURI
{
    void (^requestDidFinishLoading)(void) = ^(void){
        [self.rootFoldersURIs removeObject:resourceURI];
        if ([self.rootFoldersURIs count]) {
            [self loadResourceLookup:[self.rootFoldersURIs lastObject]];
        } else {
            [self finishLoading];
        }
    };
    
    JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateWithCompletionBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        JSResourceLookup *resourceLookup = [result.objects objectAtIndex:0];
        if (resourceLookup) {
            if (!resourceLookup.resourceType) {
                resourceLookup.resourceType = self.constants.WS_TYPE_FOLDER;
            }
            if (resourceLookup) {
                [self.rootFolders addObject:resourceLookup];
            }
        }
        requestDidFinishLoading();
    } @weakselfend
    errorBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        requestDidFinishLoading();
    } @weakselfend
    viewControllerToDismiss: nil];
    
    [self.resourceClient getResourceLookup:resourceURI delegate:requestDelegate];
}

- (BOOL) shouldBeAddedResourceLookup:(JSResourceLookup *)resource
{
    return (!self.searchQuery ||
            (self.searchQuery && resource.label && [resource.label rangeOfString:self.searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound) ||
            (self.searchQuery && resource.resourceDescription && [resource.resourceDescription rangeOfString:self.searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound));
}

- (void)finishLoading
{
    for (JSResourceLookup *lookup in self.rootFolders) {
        if ([self shouldBeAddedResourceLookup:lookup]) {
            [self.resources addObject:lookup];
        }
    }
    self.resources = [NSMutableArray arrayWithArray:[self.resources sortedArrayUsingComparator:^NSComparisonResult(JSResourceLookup * obj1, JSResourceLookup * obj2) {
        return [obj1.label compare:obj2.label options:NSCaseInsensitiveSearch];
    }]];
    _isLoadingNow = NO;
    [self.delegate resourceListDidLoaded:self withError:nil];
}

- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return [super listItemsWithOption:option];
        case JMResourcesListLoaderOption_Filter:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.resources.type.all", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD, self.constants.WS_TYPE_DASHBOARD_LEGACY, self.constants.WS_TYPE_FOLDER]}];
    }
}

@end
