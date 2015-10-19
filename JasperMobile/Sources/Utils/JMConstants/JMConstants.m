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
//  JMConstants.m
//  TIBCO JasperMobile
//

#import "JMConstants.h"

// Constants for NSUserDefaults
NSString * const kJMDefaultsCurrentVersion = @"jaspersoft.mobile.current.version";
NSString * const kJMDefaultsIntroDidApear = @"JMDefaultsIntroDidApear";

// Notifications
NSString * const kJMResetApplicationNotification = @"resetApplication";
NSString * const kJMFavoritesDidChangedNotification = @"JMFavoritesDidChangedNotification";
NSString * const kJMSavedResourcesDidChangedNotification = @"JMSavedResourcesDidChangedNotification";

// Shared keys for NSDictionary
NSString * const kJMTitleKey = @"title";
NSString * const kJMValueKey = @"value";
NSString * const kJMServerProfileKey = @"serverProfile";
NSString * const kJMResourceLookup = @"resourceLookup";
NSString * const kJMInputControls = @"inputControls";
NSString * const kJMLoadRecursively = @"loadRecursively";
NSString * const kJMResourcesTypes = @"resourcesTypes";
NSString * const kJMSearchQuery = @"searchQuery";
NSString * const kJMSortBy = @"sortBy";
NSString * const kJMFilterByTag = @"filterByTag";
NSString * const kJMReportKey = @"reportKey";
NSString * const kJMDashboardKey = @"dashboardKey";

// Settings keys
NSString * const kJMDefaultRequestTimeout = @"defaultRequestTimeout";
NSString * const kJMDefaultSendingCrashReport = @"jaspersoft.crashreportsending.enabled";
NSString * const kJMDefaultUseVisualize = @"jaspersoft.use.visualize";
NSString * const kJMUserAcceptAgreement = @"kJMUserAcceptAgreement";

// Demo server parameters
NSString * const kJMDemoServerAlias = @"Jaspersoft Mobile Demo";
NSString * const kJMDemoServerUrl = @"http://mobiledemo2.jaspersoft.com/jasperserver-pro";
NSString * const kJMDemoServerOrganization = @"organization_1";
NSString * const kJMDemoServerUsername = @"phoneuser";
NSString * const kJMDemoServerPassword = @"phoneuser";

// Directory to store downloaded reports
NSString * const kJMReportsDirectory = @"reports";

// Saved Items ws types
NSString * const kJMSavedReportUnit = @"savedReportUnit";


// Name of the main report file (outputResource)
NSString * const kJMReportFilename = @"report";

// Name of the thumbnail image file for saved reports
NSString * const kJMThumbnailImageFileName = @"_jaspersoftMobileThumbnailImageFile";

// Error domain for report loader
NSString * const kJMReportLoaderErrorDomain = @"JMReportLoaderErrorDomain";

// Privacy Policy Link
NSString * const kJMPrivacyPolicyURI = @"http://www.tibco.com/company/privacy-cma";

// Limit of pages for saving report to HTML format
NSInteger  const kJMSaveReportMaxRangePages = 500;

// Limit of resource for loading from JRS
NSInteger  const kJMResourceLimit = 100;
NSInteger  const kJMRecentResourcesLimit = 10;


// Name of the default theme file
NSString * const kJMDefaultThemeFileName = @"DefaultTheme";
NSString * const kJMThemesFileFormat= @"plist";
NSString * const kJMCurrentThemeFileName = @"CurrentTheme";

