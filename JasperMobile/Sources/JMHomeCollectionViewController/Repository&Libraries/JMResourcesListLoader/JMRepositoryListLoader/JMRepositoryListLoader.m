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

- (void)loadNextPage
{
    if (self.resourceLookup) {
        [super loadNextPage];
    } else {
        NSArray *baseFolders = nil;
        if ([self.resourceClient.serverInfo.edition isEqualToString:self.constants.SERVER_EDITION_PRO]) {
            baseFolders = @[@{@"folderName" : JMCustomLocalizedString(@"repository.root.organization", nil), @"folderURI" : @"/"},
              @{@"folderName" : JMCustomLocalizedString(@"repository.root.public", nil), @"folderURI" : @"/public"}];
        } else {
            baseFolders = @[@{@"folderName" : JMCustomLocalizedString(@"repository.root.root", nil), @"folderURI" : @"/"}];
        }
  
        for (NSDictionary *folder in baseFolders) {
            if (!self.searchQuery || (self.searchQuery && [[folder objectForKey:@"folderName"] rangeOfString:self.searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound)) {
                JSResourceLookup *rootResourceLookup = [[JSResourceLookup alloc] init];
                rootResourceLookup.label = [folder objectForKey:@"folderName"];
                rootResourceLookup.uri = [folder objectForKey:@"folderURI"];
                rootResourceLookup.resourceType = self.constants.WS_TYPE_FOLDER;
                [self.resources addObject:rootResourceLookup];
            }
        }
        _needUpdateData = NO;
        _isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}

@end
