//
//  JSFavoritesHelper.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import "JSFavoritesHelper.h"

static NSString * const JS_APP_TYPE_FAVORITE_WRAPPER = @"JS_APP_TYPE_FAVORITE_WRAPPER";

@interface JSFavoritesHelper()

// Inner favorites state
@property (nonatomic, retain) NSMutableDictionary *favorites;
@property (nonatomic, retain) NSString *serverKey;
@property (nonatomic) BOOL changesWasMade;

@end

@implementation JSFavoritesHelper

@synthesize serverIndex = _serverIndex;
@synthesize client = _client;
@synthesize serverKey = _serverKey;
@synthesize favorites = _favorites;
@synthesize changesWasMade = _changesWasMade;

+ (BOOL)isResourceWrapper:(JSResourceDescriptor *)resource {
    return [resource.wsType isEqualToString: JS_APP_TYPE_FAVORITE_WRAPPER];
}

- (id)initWithServerIndex:(NSInteger)serverIndex andClient:(JSClient *)client {
    if (self = [super init]) {
        self.serverIndex = serverIndex;
        self.client = client;
        self.serverKey = [NSString stringWithFormat: @"jaspersoft.server.favorites.%d", self.serverIndex];
        self.changesWasMade = NO;
        
        // Load all favorites for specified server
        NSDictionary *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:self.serverKey] 
                                   objectForKey: [self.client.jsServerProfile getUsernameWithOrgId]] ?: [[[NSDictionary alloc] init] autorelease];
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
        NSString *userWithOrgId = [self.client.jsServerProfile getUsernameWithOrgId];
        NSMutableDictionary *allFavorites = [[NSMutableDictionary alloc] 
                                             initWithDictionary:([prefs objectForKey:self.serverKey] ?: [NSDictionary dictionary])];
        [allFavorites setObject:self.favorites forKey:userWithOrgId];
        [prefs setObject:allFavorites forKey:self.serverKey];
        [prefs synchronize];
        self.changesWasMade = false;
        [allFavorites release];
    }
}

- (NSArray *)wrappersFromFavorites {
    if (!self.favorites.count) {
        return nil;
    }
    
    // Create list of resources from favorites
    NSMutableArray *resources = [NSMutableArray arrayWithCapacity:0];
    for (NSString *uri in self.favorites.keyEnumerator) {
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

- (void)dealloc {
    [_client release];
    [_serverKey release];
    [_favorites release];
    [super dealloc];
}

@end
