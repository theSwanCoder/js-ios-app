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
//  JMConstants.m
//  Jaspersoft Corporation
//

#import "JMConstants.h"
#import "UIColor+RGBComponent.h"

// Constants for NSUserDefaults
NSString * const kJMDefaultsActiveServer = @"jaspersoft.server.active";
NSString * const kJMDefaultsCurrentVersion = @"jaspersoft.mobile.current.version";
NSString * const kJMDefaultsFavorites = @"jaspersoft.server.favorites.%d";
NSString * const kJMDefaultsServerAlias = @"jaspersoft.server.alias.%d";
NSString * const kJMDefaultsServerAlwaysAskPassword = @"jaspersoft.server.alwaysAskPassword.%d";
NSString * const kJMDefaultsServerBaseUrl = @"jaspersoft.server.baseUrl.%d";
NSString * const kJMDefaultsServerOrganization = @"jaspersoft.server.organization.%d";
NSString * const kJMDefaultsServerPassword = @"jaspersoft.server.password.%d";
NSString * const kJMDefaultsServerUsername = @"jaspersoft.server.username.%d";

// Notifications
NSString * const kJMChangeServerProfileNotification = @"changeServerProfile";
NSString * const kJMResetApplicationNotification = @"resetApplication";
NSString * const kJMSelectMenuNotification = @"selectMenu";
NSString * const kJMClearSavedReportsListNotification = @"clearSavedReports";
// Notifications used to connect master and detail view controllers
NSString * const kJMShowResourcesListInMaster = @"showResourcesListInMaster";
NSString * const kJMShowResourcesListInDetail = @"showResourcesListInDetail";
NSString * const kJMLoadResourcesInDetail = @"loadResourcesInDetail";

// Shared keys for NSDictionary
NSString * const kJMMenuTag = @"menuTag";
NSString * const kJMNotUpdateMenuKey = @"ignoreMenuUpdates";
NSString * const kJMServerProfileKey = @"serverProfile";
NSString * const kJMResources = @"resources";
NSString * const kJMResourceLookup = @"resourceLookup";
NSString * const kJMInputControls = @"inputControls";
NSString * const kJMHasMandatoryInputControls = @"hasMandatoryInputControls";
NSString * const kJMLoadRecursively = @"loadRecursively";
NSString * const kJMSelectedResourceIndex = @"selectedResourceIndex";
NSString * const kJMResourcesTypes = @"resourcesTypes";
NSString * const kJMSearchQuery = @"searchQuery";
NSString * const kJMSortBy = @"sortBy";
NSString * const kJMTotalCount = @"totalCount";
NSString * const kJMOffset = @"offset";

// Settings keys
NSString * const kJMDefaultRequestTimeout = @"defaultRequestTimeout";
NSString * const kJMReportRequestTimeout = @"reportRequestTimeout";


// Directory to store downloaded reports
NSString * const kJMReportsDirectory = @"reports";

// Name of the main report file (outputResource)
NSString * const kJMReportFilename = @"report";
