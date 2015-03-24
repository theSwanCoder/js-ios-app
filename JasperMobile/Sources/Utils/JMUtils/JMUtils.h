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
//  JMUtils.h
//  TIBCO JasperMobile
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"
#import "JMServerProfile.h"
#import "JMLoginViewController.h"

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.6
 */
@interface JMUtils : NSObject

/**
 Validates report name and directory to store report

 @param reportName A report name to validate. It needs to be unique, without /: characters, not empty, and less or equals than 250 symbols (last 5 are reserved for extension)
 @param extension A report file extension. Optional, can be provided to validate uniqueness in file system
 @return YES if report name is valid, otherwise returns NO
 */
+ (BOOL)validateReportName:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage;

/**
 Returns full path of NSDocumentDirectory directory for NSUserDomainMask domain

 @return full path of document directory
*/
+ (NSString *)applicationDocumentsDirectory;

/**
 Shows network activity indicator
 */
+ (void)showNetworkActivityIndicator;

/**
 Hides network activity indicator
 */
+ (void)hideNetworkActivityIndicator;

/**
 Checks if current device is iPhone
 
 @return YES if current device is iPhone
 */
+ (BOOL)isIphone;

/**
 Returns used in application NSManagedObjectContext
 
 @return used in application NSManagedObjectContext
 */
+ (NSManagedObjectContext *)managedObjectContext;

/**
 Returns YES if crash reports sending is available
 
 @return YES if crash reports sending is available
 */
+ (BOOL)crashReportsSendingEnable;

/**
 Update sending of crash reports
 */
+ (void)activateCrashReportSendingIfNeeded;

+ (NSArray *)supportedFormatsForReportSaving;

/**
 Build Version
 */
+ (NSString *)buildVersion;

+ (void)showLoginViewAnimated:(BOOL)animated completion:(LoginCompletionBlock)completion;

+ (void)showAlertViewWithError:(NSError *)error;

/**
 Returns YES if User want to use Visualize for watching reports and dashboards
 
 @return YES if User want to use Visualize for watching reports and dashboards
 */
+ (BOOL)shouldUseVisualize;

/**
 Returns YES if JRS instance has version equal 6.0 or upper
 
 @return YES if JRS instance has version equal 6.0 or upper
 */
+ (BOOL)isServerVersionUpOrEqual6;

/**
 Returns YES if visualize is supported on current JRS instance
 
 @return YES if visualize is supported on current JRS instance
 */
+ (BOOL)isSupportVisualize;

/**
 Returns YES if JRS instance has Pro Edition
 
 @return YES if JRS instance has Pro Edition
 */
+ (BOOL)isServerProEdition;

@end
