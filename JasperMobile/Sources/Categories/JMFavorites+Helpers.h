//
//  JMFavorites+Helpers.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMFavorites.h"
extern NSString * const kJMFavorites;

@interface JMFavorites (Helpers)

// Adds resource to favorites
+ (void)addToFavorites:(JSResourceLookup *)resource;

// Removes resource from favorites
+ (void)removeFromFavorites:(JSResourceLookup *)resource;

// Checks if resource was already added to favorites
+ (BOOL)isResourceInFavorites:(JSResourceLookup *)resource;

// Returns wrapper from favorites. Wrapper is a JSResourceLookup
// with only provided name, label and wsType
- (JSResourceLookup *)wrapperFromFavorite;

@end
