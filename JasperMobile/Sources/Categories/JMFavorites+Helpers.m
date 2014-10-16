/*
 * Tibco JasperMobile for iOS
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

NSString * const kJMFavorites = @"Favorites";

@implementation JMFavorites (Helpers)

+ (void)addToFavorites:(JSResourceLookup *)resource
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:kJMFavorites inManagedObjectContext:self.managedObjectContext];
    favorites.uri = resource.uri;
    favorites.label = resource.label;
    favorites.wsType = resource.resourceType;
    favorites.creationDate = resource.creationDate;
    favorites.resourceDescription = resource.resourceDescription;
    favorites.username = activeServerProfile.username;
    favorites.organization = activeServerProfile.organization;
    [activeServerProfile addFavoritesObject:favorites];
    
    [self.managedObjectContext save:nil];
}

+ (void)removeFromFavorites:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.uri];
    JMFavorites *favorites = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    [self.managedObjectContext deleteObject:favorites];
    
    [self.managedObjectContext save:nil];
}

+ (BOOL)isResourceInFavorites:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resource.uri];
    return ([self.managedObjectContext countForFetchRequest:fetchRequest error:nil] > 0);
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

+ (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

+ (NSFetchRequest *)favoritesFetchRequest:(NSString *)resourceUri
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMFavorites];
    NSMutableString *format = [NSMutableString stringWithString:@"(serverProfile == %@) AND (uri LIKE[cd] %@) AND (username LIKE[cd] %@) AND "];
    
    if (activeServerProfile.organization.length) {
        [format appendString:@"(organization LIKE[cd] %@)"];
    } else {
        [format appendString:@"(organization = %@)"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format, activeServerProfile, resourceUri, activeServerProfile.username, activeServerProfile.organization];
    fetchRequest.predicate = predicate;
    
    return fetchRequest;
}
@end
