//
//  JMRepositoryListLoader.m
//  Tibco JasperMobile
//
//  Created by Oleksii Gubariev on 10/9/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMRepositoryListLoader.h"

@implementation JMRepositoryListLoader
- (id)init
{
    self = [super init];
    if (self) {
        self.resourcesType = JMResourcesListLoaderObjectType_RepositoryAll;
        self.filterBy = JMResourcesListLoaderFilterBy_None;
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
        NSArray *baseFolders = @[@{@"folderName" : JMCustomLocalizedString(@"repository.root.organization", nil), @"folderURI" : @"/"},
                                 @{@"folderName" : JMCustomLocalizedString(@"repository.root.public", nil), @"folderURI" : @"/public"}];
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
