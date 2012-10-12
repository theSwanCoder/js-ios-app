/*
 * Jaspersoft Mobile SDK
 * Copyright (C) 2001 - 2012 Jaspersoft Corporation. All rights reserved.
 * http://www.jasperforge.org/projects/mobile
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is part of Jaspersoft Mobile SDK.
 *
 * Jaspersoft Mobile SDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Jaspersoft Mobile SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Jaspersoft Mobile. If not, see <http://www.gnu.org/licenses/>.
 */

//
//  JSFavoritesHelper.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 07.08.12.
//  Copyright (c) 2012 Jaspersoft. All rights reserved.
//

#import <jaspersoft-sdk/JaspersoftSDK.h>
#import <Foundation/Foundation.h>

// JSFavoritesHelper provides methods for adding, removing, getting resources from favorites
// and synchronizing favorites state with NSUserDefault
@interface JSFavoritesHelper : NSObject

// Check if passed resource is a wrapper
+ (BOOL)isResourceWrapper:(JSResourceDescriptor *)resource;

// Init for specified server (by server index)
- (id)initWithServerIndex:(NSInteger)serverIndex andProfile:(JSProfile *)profile;

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

// Check if changes was made to favorites
- (BOOL)isChangesWasMade;

@end
