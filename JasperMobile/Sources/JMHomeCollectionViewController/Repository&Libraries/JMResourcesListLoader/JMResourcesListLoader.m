//
//  JMResourcesListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/11/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourcesListLoader.h"
#import "JMRequestDelegate.h"

@interface JMResourcesListLoader ()

@property (nonatomic, assign) BOOL needUpdateData;
@property (nonatomic, assign) BOOL isLoadingNow;
@end


@implementation JMResourcesListLoader
objection_requires(@"resourceClient", @"constants")

@synthesize resources = _resources;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceClient = _resourceClient;
@synthesize totalCount = _totalCount;
@synthesize offset = _offset;
@synthesize isLoadingNow = _isLoadingNow;
@synthesize needUpdateData = _needUpdateData;

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        self.isLoadingNow = NO;
        self.resources = [NSMutableArray array];
        [self setNeedsUpdate];
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
        self.totalCount = 0;
        self.offset = 0;
        
        [self.resources removeAllObjects];
        [self.delegate resourceListDidStartLoading:self];
        
        self.isLoadingNow = YES;
        [self loadNextPage];
    }
}

#pragma mark - JMPagination

- (void)loadNextPage
{
    self.needUpdateData = NO;
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        if (!self.totalCount) {
            self.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        }
        [self.resources addObjectsFromArray:result.objects];
        self.offset += kJMResourceLimit;
        
        self.isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
        
    } @weakselfend
    errorBlock:@weakselfnotnil(^(JSOperationResult *result)) {
        self.isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:result.error];
    } @weakselfend];
    
    [self.resourceClient resourceLookups:self.resourceLookup.uri query:self.searchQuery types:self.resourcesTypes
                                  sortBy:self.sortBy recursive:self.loadRecursively offset:self.offset limit:kJMResourceLimit delegate:delegate];
}

- (BOOL)hasNextPage
{
    return self.offset < self.totalCount;
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

@end
