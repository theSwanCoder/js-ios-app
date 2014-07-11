/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
#import "UIColor+RGBComponent.h"

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
extern NSString * const kJMClearSavedReportsListNotification;
// Notifications used to connect master and detail view controllers
extern NSString * const kJMShowResourcesListInMaster;
extern NSString * const kJMShowResourcesListInDetail;
extern NSString * const kJMLoadResourcesInDetail;

// Shared keys for dictionary
extern NSString * const kJMMenuTag;
extern NSString * const kJMNotUpdateMenuKey;
extern NSString * const kJMServerProfileKey;
extern NSString * const kJMResources;
extern NSString * const kJMResourceLookup;
extern NSString * const kJMInputControls;
extern NSString * const kJMHasMandatoryInputControls;
extern NSString * const kJMLoadRecursively;
extern NSString * const kJMSelectedResourceIndex;
extern NSString * const kJMResourcesTypes;
extern NSString * const kJMSearchQuery;
extern NSString * const kJMSortBy;
extern NSString * const kJMTotalCount;
extern NSString * const kJMOffset;

// Settings keys
extern NSString * const kJMDefaultRequestTimeout;
extern NSString * const kJMReportRequestTimeout;

// Report directory
extern NSString * const kJMReportsDirectory;

// Name of the main report file (outputResource)
extern NSString * const kJMReportFilename;

// Tags for menus. Declared as define constants because they can be used
// in switch-case structure
#define kJMRepositoryMenuTag 0
#define kJMLibraryMenuTag 1
#define kJMFavoritesMenuTag 2
#define kJMSavedReportsMenuTag 3
#define kJMServersMenuTag 4


#define kJMMasterViewWidth 163
#define kJMDetailViewLightBackgroundColor       [UIColor colorFromHexString:@"#E5E9EB"]
#define kJMDetailViewLightTextColor             [UIColor colorFromHexString:@"#8F8F8F"]
#define kJMDetailActionBarItemsBackgroundColor  [UIColor colorFromHexString:@"#2D3036"]
