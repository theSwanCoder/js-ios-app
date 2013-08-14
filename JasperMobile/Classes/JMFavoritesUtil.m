/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMFavoritesUtil.m
//  Jaspersoft Corporation
//

#import "JMFavoritesUtil.h"
#import "JMFavorites.h"
#import <Objection-iOS/Objection.h>

@interface JMFavoritesUtil()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL isResourceInFavorites;
@property (nonatomic, assign) BOOL isResourceInFavoritesPreviousValue;
@end

@implementation JMFavoritesUtil
objection_register_singleton(JMFavoritesUtil)
objection_requires(@"managedObjectContext")

#pragma mark - Accessors

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    _serverProfile = serverProfile;
}

- (void)setResourceDescriptor:(JSResourceDescriptor *)resourceDescriptor
{
    _resourceDescriptor = resourceDescriptor;
    NSFetchRequest *favoritesFetchRequest = [self favoritesFetchRequest:resourceDescriptor];
    self.isResourceInFavorites = [self.managedObjectContext countForFetchRequest:favoritesFetchRequest error:nil] == 1;
    self.isResourceInFavoritesPreviousValue = self.isResourceInFavorites;
}

#pragma mark - JMFavoritesUtil

- (void)addToFavorites
{
    self.isResourceInFavorites = YES;
}

- (void)removeFromFavorites
{
    self.isResourceInFavorites = NO;
}

- (void)removeFromFavorites:(JSResourceDescriptor *)resourceDescriptor
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resourceDescriptor];
    JMFavorites *favorites = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    [self.managedObjectContext deleteObject:favorites];
    [self.managedObjectContext save:nil];
}

- (void)persist
{    
    // Check if changes for resource was not made
    if (self.isResourceInFavorites == self.isResourceInFavoritesPreviousValue) return;
    
    // Check if resource should be added to favorites
    if (self.isResourceInFavorites) {
        JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites"
                                                               inManagedObjectContext:self.managedObjectContext];
        favorites.label = self.resourceDescriptor.label;
        favorites.uri = self.resourceDescriptor.uriString;
        favorites.wsType = self.resourceDescriptor.wsType;
        favorites.username = _serverProfile.username;
        favorites.organization = _serverProfile.organization;
        
        [_serverProfile addFavoritesObject:favorites];
        [self.managedObjectContext save:nil];
    } else {
        [self removeFromFavorites:self.resourceDescriptor];
    }
    
    self.needsToRefreshFavorites = YES;
    self.isResourceInFavoritesPreviousValue = self.isResourceInFavorites;
}

- (BOOL)isResourceInFavorites
{
    return _isResourceInFavorites;
}
     
- (NSArray *)wrappersFromFavorites
{
    NSMutableArray *resources = [NSMutableArray array];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]];
    
    for (JMFavorites *favorites in [_serverProfile.favorites sortedArrayUsingDescriptors:sortDescriptors]) {
        // Skip favorites for other usernames and organizations
        if (![_serverProfile.username isEqual:favorites.username] ||
            ![_serverProfile.organization isEqual:favorites.organization]) {
            continue;
        }
        
        JSResourceDescriptor *resource = [[JSResourceDescriptor alloc] init];
        resource.uriString = favorites.uri;
        resource.label = favorites.label;
        resource.wsType = favorites.wsType;
        
        [resources addObject:resource];
    }
    
    return resources;
}

#pragma mark - Private

- (NSFetchRequest *)favoritesFetchRequest:(JSResourceDescriptor *)resourceDescriptor
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(serverProfile == %@) AND (uri like %@) AND (username like %@) AND (organization like %@)",
                              _serverProfile, resourceDescriptor.uriString, _serverProfile.username, _serverProfile.organization];
    fetchRequest.predicate = predicate;
    
    return fetchRequest;
}

@end
