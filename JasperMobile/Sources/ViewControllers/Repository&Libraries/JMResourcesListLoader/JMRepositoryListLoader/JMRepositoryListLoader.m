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


#import "JMRepositoryListLoader.h"
#import "JMResource.h"
#import "JMResourceLoaderOption.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"
#import "JMLocalization.h"

@interface JMRepositoryListLoader ()
@property (nonatomic, strong) NSMutableArray *rootFoldersURIs;
@end

@implementation JMRepositoryListLoader

#pragma mark - Overloaded API
- (void)loadNextPage
{
    _needUpdateData = NO;
    
    if (self.resource || (!self.resource && self.searchQuery.length)) {
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
    // if PRO version - "/root" and may be "/public"
    // if CE version - "/root"
    
    self.rootFoldersURIs = [@[[self rootResourceURI], [self publicResourceURI]] mutableCopy];
    [self loadNextResourceForResource:nil];
}

- (void) loadNextResourceForResource:(NSString *)resource
{
    if (resource && [self.rootFoldersURIs indexOfObject:resource] != NSNotFound) {
        [self.rootFoldersURIs removeObject:resource];
    }
    if (self.rootFoldersURIs.count) {
        [self loadResourceLookup:[self.rootFoldersURIs firstObject]];
    } else {
        [self finishLoadingWithError:nil];
    }
}

- (void)loadResourceLookup:(NSString *)resourceURI
{
    __weak typeof(self)weakSelf = self;
    [self.restClient resourceLookupForURI:resourceURI
                             resourceType:kJS_WS_TYPE_FOLDER
                               modelClass:[JSResourceLookup class]
                          completionBlock:^(JSOperationResult *result) {
                              __strong typeof(self)strongSelf = weakSelf;
                              if (result.error) {
                                  if (result.error.code == JSSessionExpiredErrorCode) {
                                      [JMUtils showLoginViewAnimated:YES completion:nil];
                                  } else if ([resourceURI isEqualToString:[strongSelf rootResourceURI]]) {
                                      [strongSelf finishLoadingWithError:result.error];
                                  } else {
                                      [strongSelf loadNextResourceForResource:resourceURI];
                                  }
                              } else {
                                  JSResourceLookup *resourceLookup = result.objects.firstObject;
                                  if (resourceLookup) {
                                      if (!resourceLookup.resourceType) {
                                          resourceLookup.resourceType = kJS_WS_TYPE_FOLDER;
                                      }
                                      JMResource *resource = [JMResource resourceWithResourceLookup:resourceLookup];
                                      [strongSelf addResourcesWithResource:resource];
                                  }
                                  
                                  [strongSelf loadNextResourceForResource:resourceURI];
                              }
                          }];
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

- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort:{
            JMResourceLoaderOption *filterOption = [[super listItemsWithOption:optionType] firstObject];
            return @[
                     filterOption
                     ];
        }
        case JMResourcesListLoaderOptionType_Filter:
            return @[
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_all")
                                                      value:@[
                                                              kJS_WS_TYPE_REPORT_UNIT,
                                                              kJS_WS_TYPE_DASHBOARD,
                                                              kJS_WS_TYPE_DASHBOARD_LEGACY,
                                                              kJS_WS_TYPE_FOLDER,
                                                              kJS_WS_TYPE_FILE
                                                      ]]
            ];
    }
}

- (BOOL)loadRecursively
{
    return self.searchQuery != nil;
}

- (NSString *)rootResourceURI
{
    return @"/";
}

- (NSString *)publicResourceURI
{
    return @"/public";
}

@end
