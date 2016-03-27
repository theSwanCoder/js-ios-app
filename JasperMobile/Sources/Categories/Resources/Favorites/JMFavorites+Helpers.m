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


#import "JMFavorites+Helpers.h"
#import "JMServerProfile+Helpers.h"
#import "JMSessionManager.h"
#import "JMResource.h"


NSString * const kJMFavorites = @"Favorites";

@implementation JMFavorites (Helpers)

+ (void)addToFavorites:(JMResource *)resource
{
    JSProfile *sessionServerProfile = [JMSessionManager sharedManager].restClient.serverProfile;
    JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
    JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:kJMFavorites inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    favorites.uri = resource.resourceLookup.uri;
    favorites.label = resource.resourceLookup.label;
    favorites.wsType = resource.resourceLookup.resourceType;
    favorites.creationDate = resource.resourceLookup.creationDate;
    favorites.updateDate = resource.resourceLookup.updateDate;
    favorites.resourceDescription = resource.resourceLookup.resourceDescription;
    favorites.username = sessionServerProfile.username;
    favorites.version = resource.resourceLookup.version;
    [activeServerProfile  addFavoritesObject:favorites];

    [[JMCoreDataManager sharedInstance] save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

+ (void)removeFromFavorites:(JMResource *)resource
{
    JMFavorites *favorites = [self favoritesFromResourceLookup:resource];
    if (favorites) {
        [[JMCoreDataManager sharedInstance].managedObjectContext deleteObject:favorites];
        
        [[JMCoreDataManager sharedInstance] save:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
    }
}

+ (BOOL)isResourceInFavorites:(JMResource *)resource
{
    if (!resource.resourceLookup.uri) {
        return NO;
    }
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.resourceLookup.uri];
    return ([[JMCoreDataManager sharedInstance].managedObjectContext countForFetchRequest:fetchRequest error:nil] > 0);
}

+ (JMFavorites *)favoritesFromResourceLookup:(JMResource *)resource
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.resourceLookup.uri];
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

- (JMResource *)wrapperFromFavorite
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.uri = self.uri;
    resourceLookup.label = self.label;
    resourceLookup.resourceType = self.wsType;
    resourceLookup.creationDate = self.creationDate;
    resourceLookup.updateDate = self.updateDate;
    resourceLookup.resourceDescription = self.resourceDescription;
    resourceLookup.version = self.version;
    return [JMResource resourceWithResourceLookup:resourceLookup];;
}

+ (NSArray *)allFavorites
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMFavorites];
    NSArray *favoritesItems = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return favoritesItems;
}

#pragma mark - Private

+ (NSFetchRequest *)favoritesFetchRequest:(NSString *)resourceUri
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMFavorites];
    NSMutableArray *predicates = [@[[[JMSessionManager sharedManager] predicateForCurrentServerProfile]] mutableCopy];
    [predicates addObject:[NSPredicate predicateWithFormat:@"uri LIKE[cd] %@", resourceUri]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    return fetchRequest;
}
@end
