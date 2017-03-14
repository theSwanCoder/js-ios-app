/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import <Foundation/Foundation.h>

/**
 This class automatically updates/moves NSUserDefaults or/and Core Data if 
 application was updated from App Store. Idea is to store version of application 
 inside NSUserDefaults, and if that version was changed then perform update.
 Example: if old app was 1.0 version, and there was some major changes (i.e.
 changed database structure), after updating to 1.2 updates 1.1 and 1.2 will
 be performed (which adapts and move data from old to new database structure)
 */
@interface JMAppUpdater : NSObject 

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

@end
