/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import "JMServerProfile.h"
#import "JaspersoftSDK.h"

@interface JMServerProfile (Helpers)

/**
 Return demo server profile
 
 @return demo server profile
 */
+ (JMServerProfile *)demoServerProfile;

/**
 Return server profile by server name
 
 @param profile JSUserProfile Server profile
 @return server profile with required name
*/
+ (JMServerProfile *)serverProfileForJSProfile:(JSUserProfile *)profile;

/**
 Create clone for server profile.
 
 @param serverProfile for clonning
 @return Cloned server profile
 */
+ (JMServerProfile *) cloneServerProfile:(JMServerProfile *)serverProfile;

/**
 Delete server profile.
 
 @param serverProfile for deleting
 */
+ (void) deleteServerProfile:(JMServerProfile *)serverProfile;

/**
 Check name for server profile.
 
 @param name New name for checking
 @return YES if name is valid
 */
- (BOOL) isValidNameForServerProfile:(NSString *)name;

- (BOOL) isActiveServerProfile;

@end
