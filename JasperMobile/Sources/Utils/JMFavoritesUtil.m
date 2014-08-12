/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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

#define kJMFavorites @"Favorites"

@interface JMFavoritesUtil()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL isResourceInFavorites;
@property (nonatomic, assign) BOOL isResourceInFavoritesPreviousValue;
@property (nonatomic, strong) NSString *resourceUri;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *label;
@end

@implementation JMFavoritesUtil
objection_register_singleton(JMFavoritesUtil)
objection_requires(@"managedObjectContext")

#pragma mark - Accessors

- (void)setResource:(NSString *)resourceUri label:(NSString *)label type:(NSString *)type
{
    self.resourceUri = resourceUri;
    self.label = label;
    self.type = type;
    
    NSFetchRequest *favoritesFetchRequest = [self favoritesFetchRequest:resourceUri];
    self.isResourceInFavorites = [self.managedObjectContext countForFetchRequest:favoritesFetchRequest error:nil] == 1;
    self.isResourceInFavoritesPreviousValue = self.isResourceInFavorites;
}

- (void)setServerProfile:(JMServerProfile *)serverProfile
{
    _serverProfile = serverProfile;
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

- (void)removeFromFavorites:(NSString *)resourceUri
{
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resourceUri];
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
        JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:kJMFavorites
                                                               inManagedObjectContext:self.managedObjectContext];
        favorites.label = self.label;
        favorites.uri = self.resourceUri;
        favorites.wsType = self.type;
        favorites.username = _serverProfile.username;
        favorites.organization = _serverProfile.organization;
        
        [_serverProfile addFavoritesObject:favorites];
        [self.managedObjectContext save:nil];
    } else {
        [self removeFromFavorites:self.resourceUri];
    }
    
    self.needsToRefreshFavorites = YES;
    self.isResourceInFavoritesPreviousValue = self.isResourceInFavorites;
}

- (BOOL)isResourceInFavorites
{
    return _isResourceInFavorites;
}
     
- (NSMutableArray *)wrappersFromFavorites
{
    NSMutableArray *resources = [NSMutableArray array];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]];
    
    for (JMFavorites *favorites in [_serverProfile.favorites sortedArrayUsingDescriptors:sortDescriptors]) {
        if ([_serverProfile.username isEqualToString:favorites.username] &&
            (_serverProfile.organization == favorites.organization ||
             [_serverProfile.organization isEqualToString:favorites.organization])) {

            JSResourceLookup *resource = [[JSResourceLookup alloc] init];
            resource.uri = favorites.uri;
            resource.label = favorites.label;
            resource.resourceType = favorites.wsType;

            [resources addObject:resource];
        }
    }
    
    return resources;
}

#pragma mark - Private

- (NSFetchRequest *)favoritesFetchRequest:(NSString *)uri
{

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMFavorites];
    NSMutableString *format = [NSMutableString stringWithString:@"(serverProfile == %@) AND (uri like %@) AND (username like %@) AND "];

    if (_serverProfile.organization.length) {
        [format appendString:@"(organization like %@)"];
    } else {
        [format appendString:@"(organization = %@)"];
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:format,
                              _serverProfile, uri, _serverProfile.username, _serverProfile.organization];
    fetchRequest.predicate = predicate;
    
    return fetchRequest;
}

@end
