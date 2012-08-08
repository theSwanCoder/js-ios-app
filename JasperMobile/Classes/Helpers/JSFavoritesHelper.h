//
//  JSFavoritesHelper.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import <jasperserver-mobile-sdk-ios/JSClient.h>
#import <Foundation/Foundation.h>

// JSFavoritesHelper provides methods for adding, removing, getting resources from favorites
// and synchronizing favorites state with NSUserDefault
@interface JSFavoritesHelper : NSObject

@property (nonatomic) NSInteger serverIndex;
@property (nonatomic, retain) JSClient *client;

// Check if passed resource is a wrapper
+ (BOOL)isResourceWrapper:(JSResourceDescriptor *)resource;

// Init for specified server (by server index)
- (id)initWithServerIndex:(NSInteger)serverIndex andClient:(JSClient *)client;

// Add to favorites. Warning: This will not automatically write changes to NSUserDefaults, 
// additionaly you need to call synchronizeWithUserDefaults to do that
- (void)addToFavorites:(JSResourceDescriptor *)resourceDescriptor;

// Remove from favorites
- (void)removeFromFavorites:(JSResourceDescriptor *)resourceDescriptor;

// Check if resource was already added to favorites
- (BOOL)isResourceInFavorites:(JSResourceDescriptor *)resourceDescriptor;

// Returns list of wrappers from favorites. Wrapper is a JSResourceDescriptor 
// with only setted name, label and special wsType
- (NSMutableArray *)wrappersFromFavorites;

// Write changes to NSUserDefaults
- (void)synchronizeWithUserDefaults;

// Clear favorites for server and write changes to NSUserDefaults
- (void)clearFavoritesAndSynchronizeWithUserDefaults;

@end
