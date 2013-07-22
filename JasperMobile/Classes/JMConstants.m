//
//  JMConstants.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/18/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMConstants.h"

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
// Deprecated
NSString * const kJMDefaultsCount = @"jaspersoft.server.count";
NSString * const kJMDefaultsFirstRun = @"jaspersoft.mobile.firstRun";
NSString * const kJMDefaultsNotFirstRun = @"jaspersoft.mobile.notFirstRun";
NSString * const kJMDefaultsUpdatedVersions = @"jaspersoft.mobile.updated.versions";

// Notifications
NSString * const kJMChangeServerProfileNotification = @"changeServerProfile";

// Some shared keys for dictionary
NSString * const kJMServerProfileKey = @"serverProfile";
