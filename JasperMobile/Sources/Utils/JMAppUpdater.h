/*
 * Tibco JasperMobile for iOS
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
//  JMAppUpdater.h
//  Tibco JasperMobile
//

#import <Foundation/Foundation.h>

/**
 This class automatically updates/moves NSUserDefaults or/and Core Data if 
 application was updated from App Store. Idea is to store version of application 
 inside NSUserDefaults, and if that version was changed then perform update.
 Example: if old app was 1.0 version, and there was some major changes (i.e.
 changed database structure), after updating to 1.2 updates 1.1 and 1.2 will
 be performed (which adapts and move data from old to new database structure)

 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMAppUpdater : NSObject <UIAlertViewDelegate>

/**
 Performs all migrations and updates app to latest version
 */
+ (void)update;

/**
 Updates app to specific version
 */
+ (void)updateAppVersionTo:(NSNumber *)appVersion;

/**
 Returns current version of app structure (from user defaults)
 */
+ (NSNumber *)currentAppVersion;

/**
 Returns latest version of app (from bundles)
 */
+ (NSNumber *)latestAppVersion;

/**
 Returns string representation for latest version of app (from bundles)
 */
+ (NSString *)latestAppVersionAsString;

/**
 Indicates if app is running for the first time
 */
+ (BOOL)isRunningForTheFirstTime;

/**
 Checks if update has any errors
 */
+ (BOOL)hasErrors;

@end
