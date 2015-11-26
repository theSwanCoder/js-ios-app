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


#import "JMSavedResourcesListLoader.h"

#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"
#import "JMFavorites+Helpers.h"
#import "JSResourceLookup+Helpers.h"

@implementation JMSavedResourcesListLoader

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsUpdate) name:kJMSavedResourcesDidChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNextPage {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = [self predicates];
    
    NSError *error;
    NSArray *fetchedObjects = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest
                                                                                                     error:&error];
    if (error) {
        [self finishLoadingWithError:error];
    } else {
        for(JMSavedResources *savedResource in fetchedObjects) {
            [self addResourcesWithResource:[savedResource wrapperFromSavedReports]];
        }

        _needUpdateData = NO;
        
        [self finishLoadingWithError:nil];
    }
}

- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return [super listItemsWithOption:option];
        case JMResourcesListLoaderOption_Filter: {
            NSMutableArray *filterItems = [NSMutableArray array];
            [filterItems addObject:@{kJMResourceListLoaderOptionItemTitleKey : JMCustomLocalizedString(@"resources.filterby.type.all", nil),
                                     kJMResourceListLoaderOptionItemValueKey: [JMUtils supportedFormatsForReportSaving]}];

            for (NSString *format in [JMUtils supportedFormatsForReportSaving]) {
                [filterItems addObject:
                 @{kJMResourceListLoaderOptionItemTitleKey: [format uppercaseString],
                   kJMResourceListLoaderOptionItemValueKey: @[format]}];
            }
            return filterItems;
        }
    }
}

#pragma mark - Utils
- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMSavedResources inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    if ([self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]) {
        BOOL ascending = self.sortBySelectedIndex == 0;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort] ascending:ascending];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }
    
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSPredicate *)predicates
{
    NSMutableArray *predicates = [@[[[JMSessionManager sharedManager] predicateForCurrentServerProfile]] mutableCopy];
    [predicates addObject:[NSPredicate predicateWithFormat:@"format IN %@", [self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]]];
    if (self.searchQuery && self.searchQuery.length) {
        NSMutableArray *queryPredicates = [NSMutableArray array];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"resourceDescription LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:queryPredicates]];
    }
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
}

@end
