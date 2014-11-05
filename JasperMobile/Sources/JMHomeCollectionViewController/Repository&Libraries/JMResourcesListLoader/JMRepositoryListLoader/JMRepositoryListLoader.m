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

@property (nonatomic, strong) JSResourceLookup *rootFolder;
@property (nonatomic, strong) JSResourceLookup *publicFolder;

@end

@implementation JMRepositoryListLoader
- (id)init
{
    self = [super init];
    if (self) {
        self.resourcesType = JMResourcesListLoaderObjectType_RepositoryAll;
        self.sortBy = JMResourcesListLoaderSortBy_Name;
        self.loadRecursively = NO;
    }
    return self;
}

- (BOOL) shouldBeAddedResourceLookup:(JSResourceLookup *)resource
{
   return (!self.searchQuery ||
           (self.searchQuery && resource.label && [resource.label rangeOfString:self.searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound) ||
           (self.searchQuery && resource.resourceDescription && [resource.resourceDescription rangeOfString:self.searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound));
}

- (void)loadNextPage
{
    if (self.resourceLookup) {
        [super loadNextPage];
    } else {
        _needUpdateData = NO;
        void(^finishBlock)(void) = ^(void){
            self->_isLoadingNow = NO;
            [self.delegate resourceListDidLoaded:self withError:nil];
        };
        
        void(^finishSearchBlock)(void) = ^(void){
            if (self.rootFolder && self.publicFolder) {
                if ([self shouldBeAddedResourceLookup:self.rootFolder]) {
                    [self.resources addObject:self.rootFolder];
                }
                if ([self shouldBeAddedResourceLookup:self.publicFolder]) {
                    [self.resources addObject:self.publicFolder];
                }
                
                self.resources = [NSMutableArray arrayWithArray:[self.resources sortedArrayUsingComparator:^NSComparisonResult(JSResourceLookup * obj1, JSResourceLookup * obj2) {
                    return [obj1.label compare:obj2.label options:NSCaseInsensitiveSearch];
                }]];
                finishBlock();
            }
        };

        void(^loadResourceLookupBlock)(NSString *resourceURI, JSResourceLookup * __strong *lookup) = ^(NSString *resourceURI, JSResourceLookup * __strong *lookup){
            JMRequestDelegate *requestDelegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                JSResourceLookup *resourceLookup = [result.objects objectAtIndex:0];
                if (!resourceLookup.resourceType) {
                    resourceLookup.resourceType = self.constants.WS_TYPE_FOLDER;
                }
                *lookup = resourceLookup;
                finishSearchBlock();
            } @weakselfend
            errorBlock:@weakselfnotnil(^(JSOperationResult *result)) {
                finishBlock();
            } @weakselfend
            viewControllerToDismiss: nil];
            [self.resourceClient getResourceLookup:resourceURI delegate:requestDelegate];

        };
        
        if (!self.rootFolder && !self.publicFolder) {
            loadResourceLookupBlock(@"/", &_rootFolder);
            loadResourceLookupBlock(@"/public", &_publicFolder);
        } else {
            finishSearchBlock();
        }
    }
}

@end
