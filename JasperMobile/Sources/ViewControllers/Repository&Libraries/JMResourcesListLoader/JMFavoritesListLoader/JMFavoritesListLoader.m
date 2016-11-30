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


#import "JMFavoritesListLoader.h"
#import "JMServerProfile+Helpers.h"
#import "JMFavorites+Helpers.h"
#import "JMResourceLoaderOption.h"
#import "JMConstants.h"
#import "JMCoreDataManager.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "JMSessionManager.h"

@implementation JMFavoritesListLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
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
        for(JMFavorites *favorite in fetchedObjects) {
            [self addResourcesWithResource:[favorite wrapperFromFavorite]];
        }
        
        _needUpdateData = NO;
        
        [self finishLoadingWithError:nil];
    }
}

- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            return [super listItemsWithOption:optionType];
        }
        case JMResourcesListLoaderOptionType_Filter: {
            NSMutableArray *allFilterOptions = [@[
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_all")
                                                      value:@[
                                                              kJS_WS_TYPE_REPORT_UNIT,
                                                              kJS_WS_TYPE_DASHBOARD,
                                                              kJS_WS_TYPE_DASHBOARD_LEGACY,
                                                              kJS_WS_TYPE_FOLDER,
                                                              kJS_WS_TYPE_FILE,
                                                              kJMSavedReportUnit
                                                      ]],
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_reportUnit")
                                                      value:@[kJS_WS_TYPE_REPORT_UNIT]],
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_saved_reportUnit")
                                                      value:@[kJMSavedReportUnit]],
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_folder")
                                                      value:@[kJS_WS_TYPE_FOLDER]],
                    [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_files")
                                                      value:@[kJS_WS_TYPE_FILE]],
            ] mutableCopy];

            if ([JMUtils isServerProEdition]) {
                JMResourceLoaderOption *filterByDashboardOption = [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_dashboard")
                                                                                                    value:@[
                                                                                                            kJS_WS_TYPE_DASHBOARD,
                                                                                                            kJS_WS_TYPE_DASHBOARD_LEGACY
                                                                                                    ]];
                [allFilterOptions insertObject:filterByDashboardOption
                                       atIndex:3];
            }

            return allFilterOptions;
        }
    }
}

#pragma mark - Utils
- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMFavorites inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    if ([self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort]) {
        BOOL ascending = self.sortBySelectedIndex == 0;
        id key = [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                       ascending:ascending];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

- (NSPredicate *)predicates
{
    NSMutableArray *predicates = [@[[[JMSessionManager sharedManager] predicateForCurrentServerProfile]] mutableCopy];
    [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Filter]]];
    if (self.searchQuery && self.searchQuery.length) {
        NSMutableArray *queryPredicates = [NSMutableArray array];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"resourceDescription LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:queryPredicates]];
    }
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
}

@end
