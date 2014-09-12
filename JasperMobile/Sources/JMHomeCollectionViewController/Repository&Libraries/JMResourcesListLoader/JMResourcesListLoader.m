//
//  JMResourcesListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourcesListLoader.h"
#import "JMRequestDelegate.h"

#import <Objection-iOS/JSObjection.h>
#import <Objection-iOS/Objection.h>

@interface JMResourcesListLoader ()

@property (nonatomic, readwrite) BOOL isLoadingNow;
@end


@implementation JMResourcesListLoader
objection_requires(@"resourceClient", @"constants")

@synthesize resources = _resources;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceClient = _resourceClient;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        self.isLoadingNow = NO;
        self.resources = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadResources:)
                                                     name:kJMLoadResourcesInDetail
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) takeParametersFromNotificationUserInfo:(NSDictionary *)userInfo
{
    if ([userInfo objectForKey:kJMResourcesTypes]) {
        self.resourcesTypes = [userInfo objectForKey:kJMResourcesTypes];
    }
    self.loadRecursively = [[userInfo objectForKey:kJMLoadRecursively] boolValue];
    self.resourceLookup = [userInfo objectForKey:kJMResourceLookup];
    self.searchQuery = [userInfo objectForKey:kJMSearchQuery];
    self.sortBy = [userInfo objectForKey:kJMSortBy];
}


#pragma mark - Observer Methods
- (void)loadResources:(NSNotification *)notification
{
    // Reset state
    self.totalCount = 0;
    self.offset = 0;
    
    [self.resources removeAllObjects];
    [self.delegate resourceListDidStartLoading:self];

    if (!self.isLoadingNow) {
        self.isLoadingNow = YES;
        
        [self takeParametersFromNotificationUserInfo:notification.userInfo];
        [self loadNextPage];
    }
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    __weak typeof(self)weakSelf = self;
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        if (!weakSelf.totalCount) {
            weakSelf.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        [weakSelf.resources addObjectsFromArray:result.objects];
        weakSelf.offset += kJMResourceLimit;
        
        weakSelf.isLoadingNow = NO;
        [weakSelf.delegate resourceListDidLoaded:weakSelf withError:nil];
        
    } errorBlock:^(JSOperationResult *result) {
        weakSelf.isLoadingNow = NO;
        [weakSelf.delegate resourceListDidLoaded:weakSelf withError:result.error];
    }];
    
    [self.resourceClient resourceLookups:self.resourceLookup.uri query:self.searchQuery types:self.resourcesTypes
                                  sortBy:self.sortBy recursive:self.loadRecursively offset:self.offset limit:kJMResourceLimit delegate:delegate];
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
}

@end
