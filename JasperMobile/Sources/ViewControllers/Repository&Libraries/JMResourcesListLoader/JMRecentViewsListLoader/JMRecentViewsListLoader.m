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


//
//  JMRecentViewsListLoader.m
//  TIBCO JasperMobile
//

#import "JMRecentViewsListLoader.h"
#import "JMRecentViews+Helpers.h"

@implementation JMRecentViewsListLoader
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsUpdate) name:kJMRecentViewsDidChangedNotification object:nil];
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
        for(JMRecentViews *recentView in fetchedObjects) {
            [resources addObject:[recentView wrapperFromJMRecentViews]];
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
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.name", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"label"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.date", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"lastViewDate"},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.sortby.type.countViews", nil),
                       kJMResourceListLoaderOptionItemValueKey: @"countOfViews"},
                     ];
        case JMResourcesListLoaderOption_Filter: {
            NSMutableArray *itemsArray = [@[
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.all", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT, [JSConstants sharedInstance].WS_TYPE_DASHBOARD, [JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY, [JSConstants sharedInstance].WS_TYPE_FOLDER, kJMSavedReportUnit]},
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.reportUnit", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_REPORT_UNIT]},
                                            @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.saved.reportUnit", nil),
                                              kJMResourceListLoaderOptionItemValueKey: @[kJMSavedReportUnit]}
                                            ] mutableCopy];
            if ([JMUtils isServerProEdition]) {
                id dashboardItem = @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"resources.filterby.type.dashboard", nil),
                                     kJMResourceListLoaderOptionItemValueKey: @[[JSConstants sharedInstance].WS_TYPE_DASHBOARD, [JSConstants sharedInstance].WS_TYPE_DASHBOARD_LEGACY]};
                [itemsArray insertObject:dashboardItem atIndex:3];
            }
            return itemsArray;
        }
    }
}

#pragma mark - Utils
- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMRecentViews inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    if ([self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]) {
        BOOL ascending = (self.sortBySelectedIndex == 0);
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]
                                                                       ascending:ascending];
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
