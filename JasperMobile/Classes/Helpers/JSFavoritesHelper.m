/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
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

static NSString * const JS_APP_TYPE_FAVORITE_WRAPPER = @"JS_APP_TYPE_FAVORITE_WRAPPER";

@interface JSFavoritesHelper()

// Inner favorites state

@property (nonatomic) NSInteger serverIndex;
@property (nonatomic, copy) NSString *userNameWithOrgId;
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) NSString *serverKey;
@property (nonatomic) BOOL changesWasMade;

@end

@implementation JSFavoritesHelper

@synthesize serverIndex = _serverIndex;
@synthesize userNameWithOrgId = _userNameWithOrgId;
@synthesize serverKey = _serverKey;
@synthesize favorites = _favorites;
@synthesize changesWasMade = _changesWasMade;

+ (BOOL)isResourceWrapper:(JSResourceDescriptor *)resource {
    return [resource.wsType isEqualToString: JS_APP_TYPE_FAVORITE_WRAPPER];
}

- (id)initWithServerIndex:(NSInteger)serverIndex andClient:(JSClient *)client {
    if (self = [super init]) {
        self.serverIndex = serverIndex;
        self.userNameWithOrgId = [client.jsServerProfile getUsernameWithOrgId];
        self.serverKey = [NSString stringWithFormat: @"jaspersoft.server.favorites.%d", self.serverIndex];
        self.changesWasMade = NO;
        
        // Load all favorites for specified server
        NSDictionary *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:self.serverKey] 
                                   objectForKey: self.userNameWithOrgId] ?: [[[NSDictionary alloc] init] autorelease];
        self.favorites = [[[NSMutableDictionary alloc] initWithDictionary:favorites] autorelease];
    }
    
    return self;
}

- (id)init {
    return [self initWithServerIndex:0 andClient:nil];
}

- (void)addToFavorites:(JSResourceDescriptor *)resourceDescriptor {
    self.changesWasMade = YES;
    [self.favorites setObject:[[[NSDictionary alloc] initWithObjectsAndKeys:resourceDescriptor.label, @"label", 
                               resourceDescriptor.wsType, @"wsType", nil] autorelease] forKey:resourceDescriptor.uri];
}

- (BOOL)isResourceInFavorites:(JSResourceDescriptor *)resourceDescriptor {
    if (!resourceDescriptor) {
        return NO;
    }
    
    return [self.favorites objectForKey:resourceDescriptor.uri] != NULL;
}

- (void)removeFromFavorites:(JSResourceDescriptor *)resourceDescriptor {
    self.changesWasMade = YES;
    [self.favorites removeObjectForKey:resourceDescriptor.uri];
}

- (void)synchronizeWithUserDefaults {
    if (self.changesWasMade) {        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *allFavorites = [[NSMutableDictionary alloc] 
                                             initWithDictionary:([prefs objectForKey:self.serverKey] ?: [NSDictionary dictionary])];
        [allFavorites setObject:self.favorites forKey:self.userNameWithOrgId];
        [prefs setObject:allFavorites forKey:self.serverKey];
        [prefs synchronize];
        self.changesWasMade = NO;
        [allFavorites release];
    }
}

- (NSArray *)wrappersFromFavorites {
    if (!self.favorites.count) {
        return nil;
    }
    
    NSArray *sortedKeys = [self.favorites keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 objectForKey:@"label"] compare:[obj2 objectForKey:@"label"]];
    }];
    
    NSMutableArray *resources = [NSMutableArray arrayWithCapacity:0];
    for (NSString *uri in sortedKeys) {
        JSResourceDescriptor *resource = [[JSResourceDescriptor alloc] init];
        resource.uri = uri;
        resource.label = [[self.favorites objectForKey:uri] objectForKey:@"label"];
        resource.wsType = [[self.favorites objectForKey:uri] objectForKey:@"wsType"];
        
        [resources addObject:resource];
        [resource release];
    }
    
    return resources;
}

- (void)clearFavoritesAndSynchronizeWithUserDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:self.serverKey];
    [prefs synchronize];
}

- (BOOL)isChangesWasMade {
    return self.changesWasMade;
}

- (void)dealloc {
    [_userNameWithOrgId release];
    [_serverKey release];
    [_favorites release];
    [super dealloc];
}

@end
