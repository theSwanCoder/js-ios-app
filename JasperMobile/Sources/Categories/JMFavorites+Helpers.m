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


#import "JMFavorites+Helpers.h"
#import "JMServerProfile+Helpers.h"
#import "JMSessionManager.h"


NSString * const kJMFavorites = @"Favorites";

@implementation JMFavorites (Helpers)

+ (void)addToFavorites:(JSResourceLookup *)resource
{
    JSProfile *sessionServerProfile = [JMSessionManager sharedManager].restClient.serverProfile;
    JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForname:sessionServerProfile.alias];
    JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:kJMFavorites inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    favorites.uri = resource.uri;
    favorites.label = resource.label;
    favorites.wsType = resource.resourceType;
    favorites.creationDate = resource.creationDate;
    favorites.resourceDescription = resource.resourceDescription;
    favorites.organization = activeServerProfile.organization;
    favorites.username = sessionServerProfile.username;
    [activeServerProfile  addFavoritesObject:favorites];

    [[JMCoreDataManager sharedInstance] save:nil];
}

+ (void)removeFromFavorites:(JSResourceLookup *)resource
{
    JMFavorites *favorites = [self favoritesFromResourceLookup:resource];
    [[JMCoreDataManager sharedInstance].managedObjectContext deleteObject:favorites];
    
    [[JMCoreDataManager sharedInstance] save:nil];
}

+ (BOOL)isResourceInFavorites:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.uri];
    return ([[JMCoreDataManager sharedInstance].managedObjectContext countForFetchRequest:fetchRequest error:nil] > 0);
}

+ (JMFavorites *)favoritesFromResourceLookup:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.uri];
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

- (JSResourceLookup *)wrapperFromFavorite
{
    JSResourceLookup *resource = [[JSResourceLookup alloc] init];
    resource.uri = self.uri;
    resource.label = self.label;
    resource.resourceType = self.wsType;
    resource.creationDate = self.creationDate;
    resource.resourceDescription = self.resourceDescription;
    return resource;
}

#pragma mark - Private

+ (NSFetchRequest *)favoritesFetchRequest:(NSString *)resourceUri
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMFavorites];
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:[[JMSessionManager sharedManager] predicateForCurrentServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"uri LIKE[cd] %@", resourceUri]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    return fetchRequest;
}
@end
