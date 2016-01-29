/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMSavedResources+Helpers.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

#import "JMSavedResources.h"
#import "JSResourceLookup.h"

@class JMExportResource;

extern NSString * const kJMSavedResources;

@interface JMSavedResources (Helpers)

// Returns saved report from JSResourceLookup
+ (JMSavedResources *)savedReportsFromResourceLookup:(JSResourceLookup *)resource;

+ (JMSavedResources *)savedResourceWithReportName:(NSString *)reportName format:(NSString *)reportFormat;

// Adds saved resource with path to CoreData
+ (JMSavedResources *)addReport:(JSResourceLookup *)resource withName:(NSString *)name format:(NSString *)format sourcesURL:(NSURL *)sourcesURL;

// Returns YES if report with name reportName with format reportFormat is absent
+ (BOOL)isAvailableReportName:(NSString *)reportName format:(NSString *)reportFormat;

+ (NSArray *)allSavedItems;

+ (BOOL)moveSavedItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

// Rename saved resource
- (BOOL)renameReportTo:(NSString *)newName;

// Removes saved resource
- (void)removeReport;

// Returns thumbnail image for saved report
- (UIImage *)thumbnailImage;

// Returns wrapper from SavedReports. Wrapper is a JSResourceLookup
- (JSResourceLookup *)wrapperFromSavedReports;

// paths
+ (NSString *)uriForSavedReportWithName:(NSString *)name format:(NSString *)format;

+ (NSString *)pathToFolderForSavedReport:(JMSavedResources *)savedReport;
+ (NSString *)pathToTempFolderForSavedReport:(JMSavedResources *)savedReport;
+ (NSString *)absolutePathToSavedReport:(JMSavedResources *)savedReport;
+ (NSString *)absoluteTempPathToSavedReport:(JMSavedResources *)savedReport;

+ (NSString *)pathToTempReportsFolder;

+ (NSString *)oldPathForSavedReport:(JMSavedResources *)savedResource;
+ (NSString *)newURIForSavedReport:(JMSavedResources *)savedResource;
@end
