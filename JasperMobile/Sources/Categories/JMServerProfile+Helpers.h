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
//  JMServerProfile+Helpers.h
//  TIBCO JasperMobile
//

#import "JMServerProfile.h"

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.6
 */
@interface JMServerProfile (Helpers)

/**
 Return demo server profile
 
 @return demo server profile
 */
+ (JMServerProfile *)demoServerProfile;

/**
 Returns number of min supported server version
 
 @return number of min supported server version
 */
+ (float) minSupportedServerVersion;

/**
 Return server profile by server name
 
 @param profile JSProfile Server profile
 @return server profile with required name
*/
+ (JMServerProfile *)serverProfileForJSProfile:(JSProfile *)profile;

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
+ (BOOL) isValidNameForServerProfile:(NSString *)name;

/**
 Check if jasperserver exist and it version is supported by application.
 
 @param completionBlock block of code will be executed after checking. If server exist and supported error will be nil.
 */
- (void) checkServerProfileWithCompletionBlock:(void(^)(NSError *error))completionBlock;


@end
