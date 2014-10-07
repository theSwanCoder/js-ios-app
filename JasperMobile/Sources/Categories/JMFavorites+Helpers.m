//
//  JMFavorites+Helpers.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

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
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    return [injector getObject:[NSManagedObjectContext class]];
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
