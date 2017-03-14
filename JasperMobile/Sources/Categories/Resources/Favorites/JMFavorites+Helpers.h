/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMFavorites.h"

@class JMResource;
extern NSString * const kJMFavorites;

@interface JMFavorites (Helpers)

// Adds resource to favorites
+ (void)addToFavorites:(JMResource *)resource;

// Removes resource from favorites
+ (void)removeFromFavorites:(JMResource *)resource;

// Checks if resource was already added to favorites
+ (BOOL)isResourceInFavorites:(JMResource *)resource;

// Returns favorites report from JSResourceLookup
+ (JMFavorites *)favoritesFromResourceLookup:(JMResource *)resource;


// Returns wrapper from favorites. Wrapper is a JSResourceLookup
- (JMResource *)wrapperFromFavorite;

// Returns all favorites.
+ (NSArray *)allFavorites;

@end
