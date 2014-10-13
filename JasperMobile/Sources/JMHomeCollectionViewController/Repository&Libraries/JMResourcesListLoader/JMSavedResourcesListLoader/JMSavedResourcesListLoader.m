//
//  JMSavedResourcesListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSavedResourcesListLoader.h"

#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"

@implementation JMSavedResourcesListLoader

- (id)init
{
    self = [super init];
    if (self) {
        
        self.resourcesType = JMResourcesListLoaderObjectType_LibraryAll;
        self.filterBy = JMResourcesListLoaderFilterBy_None;
        self.sortBy = JMResourcesListLoaderSortBy_Name;
        self.loadRecursively = NO;

        [[NSNotificationCenter defaultCenter] addObserverForName:kJMSavedResourcesDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakselfnotnil(^(NSNotification *note)) {
            [self setNeedsUpdate];
        } @weakselfend];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNextPage {
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMSavedResources inManagedObjectContext:[JMUtils managedObjectContext]];
    if (self.sortByParameterForQuery) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortByParameterForQuery ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:kJMResourceLimit];
    [fetchRequest setFetchOffset:self.offset];
    
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"serverProfile == %@", activeServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"username == %@", activeServerProfile.username]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", activeServerProfile.organization]];
    
    [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", self.resourcesTypesParameterForQuery]];
    if (self.searchQuery && self.searchQuery.length) {
        NSMutableArray *queryPredicates = [NSMutableArray array];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"resourceDescription LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:queryPredicates]];
    }
    
    fetchRequest.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[JMUtils managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    _isLoadingNow = NO;
    if (fetchedObjects == nil) {
        [self.delegate resourceListDidLoaded:self withError:error];
    } else {
        for(JMSavedResources *resource in fetchedObjects) {
            [self.resources addObject:[resource wrapperFromSavedReports]];
        }
        _needUpdateData = NO;
        _isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}
@end
