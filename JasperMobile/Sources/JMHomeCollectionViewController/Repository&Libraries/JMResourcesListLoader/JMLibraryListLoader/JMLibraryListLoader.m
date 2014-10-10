//
//  JMLibraryListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/12/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMLibraryListLoader.h"
#import "JMServerProfile+Helpers.h"
#import "JMFavorites+Helpers.h"

@implementation JMLibraryListLoader

- (id)init
{
    self = [super init];
    if (self) {
        self.resourcesTypes = @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];
        self.searchQuery = nil;
        self.sortBy = @"label";
        self.loadRecursively = YES;
        self.filterByTag = nil;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kJMFavoritesDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakself(^(NSNotification *note)) {
            if (self.filterByTag && self.filterByTag.length) {
                [self setNeedsUpdate];
            }
        } @weakselfend];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNextPage {
    if (self.filterByTag && [self.filterByTag isEqualToString:@"favorites"]) {
        JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kJMFavorites inManagedObjectContext:[JMUtils managedObjectContext]];
        if (self.sortBy) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortBy ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        }

        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:kJMResourceLimit];
        [fetchRequest setFetchOffset:self.offset];
        
        NSMutableArray *predicates = [NSMutableArray array];
        [predicates addObject:[NSPredicate predicateWithFormat:@"serverProfile == %@", activeServerProfile]];
        [predicates addObject:[NSPredicate predicateWithFormat:@"username == %@", activeServerProfile.username]];
        [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", activeServerProfile.organization]];
        
        [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", self.resourcesTypes]];
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
            for(JMFavorites *favorite in fetchedObjects) {
                [self.resources addObject:[favorite wrapperFromFavorite]];
            }
            _needUpdateData = NO;
            _isLoadingNow = NO;
            [self.delegate resourceListDidLoaded:self withError:nil];
        }
    } else {
        [super loadNextPage];
    }
}

@end
