/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSFavoritesHelper.m
//  Jaspersoft Corporation
//

#import "JSFavoritesHelper.h"
#import "Favorites.h"
#import "JasperMobileAppDelegate.h"

@interface JSFavoritesHelper()

@property (nonatomic, retain) ServerProfile *serverProfile;

@end

@implementation JSFavoritesHelper

- (id)initWithServerProfile:(ServerProfile *)serverProfile {
    if (self = [super init]) {
        self.serverProfile = serverProfile;
    }
    return self;
}

- (void)addToFavorites:(JSResourceDescriptor *)resourceDescriptor {
    NSManagedObjectContext *managedObjectContext = [[JasperMobileAppDelegate sharedInstance] managedObjectContext];
    
    Favorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:managedObjectContext];
    favorites.label = resourceDescriptor.label;
    favorites.uri = resourceDescriptor.uriString;
    favorites.wsType = resourceDescriptor.wsType;
    favorites.username = self.serverProfile.username;
    favorites.organization = self.serverProfile.organization;
    [self.serverProfile addFavoritesObject:favorites];
    
    [managedObjectContext save:nil];
}

- (BOOL)isResourceInFavorites:(JSResourceDescriptor *)resourceDescriptor {
    NSFetchRequest *favoritesFetchRequest = [self favoritesFetchRequest:resourceDescriptor];
    NSManagedObjectContext *managedObjectContext = [[JasperMobileAppDelegate sharedInstance] managedObjectContext];
    return [managedObjectContext countForFetchRequest:favoritesFetchRequest error:nil] == 1;
}

- (void)removeFromFavorites:(JSResourceDescriptor *)resourceDescriptor {
    NSFetchRequest *fetchRequest = [self favoritesFetchRequest:resourceDescriptor];
    NSManagedObjectContext *managedObjectContext = [[JasperMobileAppDelegate sharedInstance] managedObjectContext];

    Favorites *favorites = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    [managedObjectContext deleteObject:favorites];
    [managedObjectContext save:nil];
}
     
- (NSArray *)wrappersFromFavorites {
    NSMutableArray *resources = [NSMutableArray array];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]];
    for (Favorites *favorites in [self.serverProfile.favorites sortedArrayUsingDescriptors:sortDescriptors]) {
        // Skip favorites for other usernames and organizations
        if (![self.serverProfile.username isEqual:favorites.username] ||
            ![self.serverProfile.organization isEqual:favorites.organization]) {
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

- (NSFetchRequest *)favoritesFetchRequest:(JSResourceDescriptor *)resourceDescriptor {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(serverProfile == %@) AND (uri like %@) AND (username like %@) AND (organization like %@)",
                              self.serverProfile, resourceDescriptor.uriString, self.serverProfile.username, self.serverProfile.organization];
    fetchRequest.predicate = predicate;
    return fetchRequest;
}

@end
