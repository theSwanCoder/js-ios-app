//
//  JMConstants.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/18/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
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

__deprecated extern NSString * const kJMDefaultsCount;
__deprecated extern NSString * const kJMDefaultsFirstRun;
__deprecated extern NSString * const kJMDefaultsNotFirstRun;
__deprecated extern NSString * const kJMDefaultsUpdatedVersions;

// Notifications
extern NSString * const kJMChangeServerProfileNotification;

// Some shared keys for dictionary
extern NSString * const kJMServerProfileKey;

// Tags for menus. Decraled as define constants because they can be used
// in switch-case structure
#define kJMLibraryMenuTag 0
#define kJMRepositoryMenuTag 1
#define kJMFavoritesMenuTag 2
#define kJMServersMenuTag 3