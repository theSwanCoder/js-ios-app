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

@interface JMRepositoryListLoader ()
@property (nonatomic, strong) NSMutableArray *rootFolders;
@end

@implementation JMRepositoryListLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rootFolders = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Overloaded API
- (void)loadNextPage
{
    _needUpdateData = NO;
    
    if (self.resourceLookup || (!self.resourceLookup && self.searchQuery.length)) {
        [super loadNextPage];
    } else {
        [self loadRootFolders];
    }
}

#pragma mark - Private API
- (void)loadRootFolders
{
    // load root contents
    // now there are next folders
    // if PRO version - "/root" and "/public"
    // if CE version - "/root"
    
    
    // TODO: Need clear this moment because it's hack for refresh control refreshing fix
    [self.rootFolders removeAllObjects];
    
    
    BOOL isAllRootFolderLoaded = (self.rootFolders.count == [self rootFoldersCount]);
    if (isAllRootFolderLoaded) {
        [self finishLoadingWithError:nil];
    } else {
        [self loadResourceLookup:[self rootResourceURI]];
    }
}

- (void)loadResourceLookup:(NSString *)resourceURI
{
    [self.restClient resourceLookupForURI:resourceURI resourceType:[JSConstants sharedInstance].WS_TYPE_FOLDER completionBlock:@weakself(^(JSOperationResult *result)) {
        if (result.error) {
            if (result.error.code == JSSessionExpiredErrorCode) {
                if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
                    [self loadResourceLookup:resourceURI];
                } else {
                    [self finishLoadingWithError:result.error];
                    [JMUtils showLoginViewAnimated:YES completion:nil];
                }
            } else {
                [self finishLoadingWithError:result.error];
            }
        } else {
            JSResourceLookup *resourceLookup = result.objects.firstObject;
            if (resourceLookup) {
                if (!resourceLookup.resourceType) {
                    resourceLookup.resourceType = [JSConstants sharedInstance].WS_TYPE_FOLDER;
                }
                [self.rootFolders addObject:resourceLookup];
                self.sections = @{
                                  @(JMResourcesListSectionTypeFolder) : self.rootFolders,
                                  @(JMResourcesListSectionTypeReportUnit) : @[],
                                  };
            }

            
            BOOL isAllRootFolderLoaded = (self.rootFolders.count == [self rootFoldersCount]);
            if (!isAllRootFolderLoaded) {
                [self loadResourceLookup:[self publicResourceURI]];
            } else {
                [self finishLoadingWithError:nil];
            }
        }
    }@weakselfend];
}

- (void)finishLoadingWithError:(NSError *)error
{
    if (!error) {
        for (JSResourceLookup *lookup in self.rootFolders) {
            if ([self shouldBeAddedResourceLookup:lookup]) {
                [self addResourcesWithResource:lookup];
            }
        }

        [self sortLoadedResourcesUsingComparator:^NSComparisonResult(JSResourceLookup *obj1, JSResourceLookup *obj2) {
            return [obj1.label compare:obj2.label options:NSCaseInsensitiveSearch];
        }];
    }
    [super finishLoadingWithError:error];
}

#pragma mark - Utils
- (BOOL) shouldBeAddedResourceLookup:(JSResourceLookup *)resource
{
    return (!self.searchQuery ||
            (self.searchQuery && resource.label && [resource.label rangeOfString:self.searchQuery
                                                                         options:NSCaseInsensitiveSearch].location != NSNotFound) ||
            (self.searchQuery && resource.resourceDescription && [resource.resourceDescription rangeOfString:self.searchQuery
                                                                                                     options:NSCaseInsensitiveSearch].location != NSNotFound));
}

- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return [super listItemsWithOption:option];
        case JMResourcesListLoaderOption_Filter:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.type.all", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT, [JSConstants sharedInstance].WS_TYPE_DASHBOARD, [JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY, [JSConstants sharedInstance].WS_TYPE_FOLDER]}];
    }
}

- (BOOL)loadRecursively
{
    return !!self.searchQuery;
}

- (NSString *)rootResourceURI
{
    return @"/";
}

- (NSString *)publicResourceURI
{
    return @"/public";
}

- (NSInteger)rootFoldersCount
{
    return [JMUtils isServerProEdition] ? 2 : 1;
}

@end
