/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  TIBCO JasperMobile
//

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @author Aleksandr Dakhno odahno@tibco.com
 
 @since 1.6
 */

#import <Foundation/Foundation.h>
#import "UIColor+RGBComponent.h"

// Constants for NSUserDefaults
extern NSString * const kJMDefaultsCurrentVersion;
extern NSString * const kJMDefaultsIntroDidApear;

// Notifications
extern NSString * const kJMLoginDidSuccessNotification;
extern NSString * const kJMResetApplicationNotification;
extern NSString * const kJMFavoritesDidChangedNotification;
extern NSString * const kJMSavedResourcesDidChangedNotification;
extern NSString * const kJMRecentViewsDidChangedNotification;

// Shared keys for dictionary
extern NSString * const kJMTitleKey;
extern NSString * const kJMValueKey;
extern NSString * const kJMServerProfileKey;
extern NSString * const kJMResourceLookup;
extern NSString * const kJMInputControls;
extern NSString * const kJMLoadRecursively;
extern NSString * const kJMResourcesTypes;
extern NSString * const kJMSearchQuery;
extern NSString * const kJMSortBy;
extern NSString * const kJMFilterByTag;
extern NSString * const kJMReportKey;
extern NSString * const kJMDashboardKey;

// Settings keys
extern NSString * const kJMDefaultRequestTimeout;
extern NSString * const kJMDefaultSendingCrashReport;
extern NSString * const kJMDefaultUseVisualize;

// Demo server parameters
extern NSString * const kJMDemoServerAlias;
extern NSString * const kJMDemoServerUrl;
extern NSString * const kJMDemoServerOrganization;
extern NSString * const kJMDemoServerUsername;
extern NSString * const kJMDemoServerPassword;

// Report directory
extern NSString * const kJMReportsDirectory;

// Saved Items ws types
extern NSString * const kJMSavedReportUnit;

// Name of the main report file (outputResource)
extern NSString * const kJMReportFilename;

// Name of the thumbnail image file for saved reports
extern NSString * const kJMThumbnailImageFileName;

// Error domain for report loader
extern NSString * const kJMReportLoaderErrorDomain;


// Privacy Policy Link
extern NSString * const kJMPrivacyPolicyURI;

#define kJMResourceLimit                                100
#define kJMMasterViewWidth                              [JMUtils isIphone] ? 210.f : 240.f
#define kJMMasterViewAnimationDuration                  0.2f

#define kJMDetailViewLightBackgroundColor               [UIColor colorFromHexString:@"#E5E9EB"]
#define kJMDetailViewLightTextColor                     [UIColor colorFromHexString:@"#8F8F8F"]
#define kJMSearchBarBackgroundColor                     [UIColor colorFromHexString:@"#26282D"]

#define kJMMainNavigationBarBackgroundColor             [UIColor colorFromHexString:@"#343841"]
#define kJMMainCollectionViewBackgroundColor            [UIColor colorWithPatternImage:[UIImage imageNamed:@"list_background_pattern"]]

#define kJMResourcePreviewBackgroundColor               [UIColor colorFromHexString:@"#428EC0"]

#define kJMMasterResourceCellDefaultBackgroundColor     [UIColor colorFromHexString:@"#2E3138"]
#define kJMMasterResourceCellSelectedBackgroundColor    [UIColor colorFromHexString:@"#484F59"]
