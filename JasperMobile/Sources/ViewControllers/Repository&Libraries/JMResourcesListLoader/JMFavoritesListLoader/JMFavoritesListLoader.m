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


#import "JMFavoritesListLoader.h"
#import "JMServerProfile+Helpers.h"
#import "JMFavorites+Helpers.h"

@implementation JMFavoritesListLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loadRecursively = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsUpdate) name:kJMFavoritesDidChangedNotification object:nil];
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
        NSMutableArray *folders = [NSMutableArray array];
        NSMutableArray *resources = [NSMutableArray array];
        for(JMFavorites *favorite in fetchedObjects) {
            if ([favorite.wsType isEqualToString:[JSConstants sharedInstance].WS_TYPE_FOLDER]) {
                [folders addObject:[favorite wrapperFromFavorite]];
            } else {
                [resources addObject:[favorite wrapperFromFavorite]];
            }
        }
        [self addResourcesWithResources:folders];
        [self addResourcesWithResources:resources];
        
        self.sections = @{
                          @(JMResourcesListSectionTypeFolder) : [folders copy],
                          @(JMResourcesListSectionTypeReportUnit) : [resources copy],
                          };
        
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
            NSMutableArray *itemsArray = [@[
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.type.all", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT, [JSConstants sharedInstance].WS_TYPE_DASHBOARD, [JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY, [JSConstants sharedInstance].WS_TYPE_FOLDER, kJMSavedReportUnit]},
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.type.reportUnit", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT, kJMSavedReportUnit]},
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.type.folder", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_FOLDER]}
                                            ] mutableCopy];
            if ([JMUtils isServerProEdition]) {
                id dashboardItem = @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.type.dashboard", nil),
                                     kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_DASHBOARD, [JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY]};
                [itemsArray insertObject:dashboardItem atIndex:2];
            }
            return itemsArray;
        }
    }
}

#pragma mark - Utils
- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMFavorites inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    if ([self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSPredicate *)predicates
{
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:[[JMSessionManager sharedManager] predicateForCurrentServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", [self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]]];
    if (self.searchQuery && self.searchQuery.length) {
        NSMutableArray *queryPredicates = [NSMutableArray array];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"resourceDescription LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:queryPredicates]];
    }
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
}

@end