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

@interface JMFavoritesListLoader ()
@property (nonatomic, assign, readwrite) NSInteger offset;
@end

@implementation JMFavoritesListLoader
@synthesize offset;

- (id)init
{
    self = [super init];
    if (self) {
        self.loadRecursively = YES;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kJMFavoritesDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:@weakself(^(NSNotification *note)) {
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMFavorites inManagedObjectContext:[JMUtils managedObjectContext]];
    if ([self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort]) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self parameterForQueryWithOption:JMResourcesListLoaderOption_Sort] ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:kJMResourceLimit];
    [fetchRequest setFetchOffset:self.offset];
    
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"serverProfile == %@", activeServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"username == %@", activeServerProfile.username]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", activeServerProfile.organization]];
    
    [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", [self parameterForQueryWithOption:JMResourcesListLoaderOption_Filter]]];
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
        self.offset += kJMResourceLimit;
        _needUpdateData = NO;
        _isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}

- (NSArray *)listItemsWithOption:(JMResourcesListLoaderOption)option
{
    switch (option) {
        case JMResourcesListLoaderOption_Sort:
            return [super listItemsWithOption:option];
        case JMResourcesListLoaderOption_Filter:
            return @[
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.resources.type.all", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD, self.constants.WS_TYPE_DASHBOARD_LEGACY, self.constants.WS_TYPE_FOLDER]},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.resources.type.reportUnit", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[self.constants.WS_TYPE_REPORT_UNIT]},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.resources.type.dashboard", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[self.constants.WS_TYPE_DASHBOARD, self.constants.WS_TYPE_DASHBOARD_LEGACY]},
                     @{kJMResourceListLoaderOptionItemTitleKey: JMCustomLocalizedString(@"master.resources.type.folder", nil),
                       kJMResourceListLoaderOptionItemValueKey: @[self.constants.WS_TYPE_FOLDER]}
                     ];
    }
}

@end
