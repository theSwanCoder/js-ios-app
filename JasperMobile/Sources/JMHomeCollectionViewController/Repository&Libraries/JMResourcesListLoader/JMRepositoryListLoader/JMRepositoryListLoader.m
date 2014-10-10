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
        self.resourcesTypes = @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD, self.constants.WS_TYPE_FOLDER];
        self.searchQuery = nil;
        self.sortBy = @"label";
        self.loadRecursively = NO;
        self.filterByTag = nil;
    }
    return self;
}

- (void)loadNextPage
{
    if (self.resourceLookup) {
        [super loadNextPage];
    } else {
        JSResourceLookup *rootResourceLookup = [[JSResourceLookup alloc] init];
        rootResourceLookup.label = @"Organization";
        rootResourceLookup.uri = @"/";
        rootResourceLookup.resourceType = self.constants.WS_TYPE_FOLDER;
        [self.resources addObject:rootResourceLookup];
        
        JSResourceLookup *publicResourceLookup = [[JSResourceLookup alloc] init];
        publicResourceLookup.label = @"Public";
        publicResourceLookup.uri = @"/public";
        publicResourceLookup.resourceType = self.constants.WS_TYPE_FOLDER;
        [self.resources addObject:publicResourceLookup];
        
        _needUpdateData = NO;
        _isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}

@end
