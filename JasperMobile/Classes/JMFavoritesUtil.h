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
//  JMFavoritesUtil.h
//  Jaspersoft Corporation
//

#import "JMServerProfile.h"
#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

/**
 Provides methods for adding, removing, getting resources from favorites
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMFavoritesUtil : NSObject {
    @private
    JMServerProfile *_serverProfile;
}

// Indicates if there was any db transactions or server profile was modified
// so data should be refreshed
@property (nonatomic, assign) BOOL needsToRefreshFavorites;

// Sets resource with a specified uri, label and type. For this resource favorites will be modified
- (void)setResource:(NSString *)resourceUri label:(NSString *)label type:(NSString *)type;

// Sets a server profile to retrieve, add or delete favorites
- (void)setServerProfile:(JMServerProfile *)serverProfile;

// Adds resource to favorites
- (void)addToFavorites;

// Removes resource from favorites
- (void)removeFromFavorites;

// Removes from favorites
- (void)removeFromFavorites:(NSString *)resourceUri;

// Checks if resource was already added to favorites
- (BOOL)isResourceInFavorites;

// Returns list of wrappers from favorites. Wrapper is a JSResourceLookup
// with only provided name, label and wsType
- (NSMutableArray *)wrappersFromFavorites;

// Saves changes
- (void)persist;

@end
