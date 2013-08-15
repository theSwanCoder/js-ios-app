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
//  JMConstants.h
//  Jaspersoft Corporation
//
//  Created by Vlad Zavadskii vzavadskii@jaspersoft.com
//  Since 1.6
//

#import <Foundation/Foundation.h>

// Constants for NSUserDefaults
extern NSString * const kJMDefaultsActiveServer;
extern NSString * const kJMDefaultsCurrentVersion;
extern NSString * const kJMDefaultsFavorites;
extern NSString * const kJMDefaultsServerAlias;
extern NSString * const kJMDefaultsServerAlwaysAskPassword;
extern NSString * const kJMDefaultsServerBaseUrl;
extern NSString * const kJMDefaultsServerOrganization;
extern NSString * const kJMDefaultsServerPassword;
extern NSString * const kJMDefaultsServerUsername;

// Notifications
extern NSString * const kJMChangeServerProfileNotification;
extern NSString * const kJMResetApplicationNotification;
extern NSString * const kJMSelectMenuNotification;

// Some shared keys for dictionary
extern NSString * const kJMMenuTag;
extern NSString * const kJMNotUpdateMenuKey;
extern NSString * const kJMServerProfileKey;

// Storyboard name
NSString *JMMainStoryboard();

// Tags for menus. Decraled as define constants because they can be used
// in switch-case structure
#define kJMLibraryMenuTag 0
#define kJMRepositoryMenuTag 1
#define kJMFavoritesMenuTag 2
#define kJMServersMenuTag 3
