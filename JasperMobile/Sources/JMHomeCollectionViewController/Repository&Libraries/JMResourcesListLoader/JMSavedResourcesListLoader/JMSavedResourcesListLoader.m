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


#import "JMSavedResourcesListLoader.h"

#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"

@interface JMSavedResourcesListLoader ()
@property (nonatomic, assign, readwrite) NSInteger offset;
@end

@implementation JMSavedResourcesListLoader
@synthesize offset;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.resourcesType = JMResourcesListLoaderObjectType_LibraryAll;
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
        self.offset += kJMResourceLimit;
        _needUpdateData = NO;
        _isLoadingNow = NO;
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}
@end
