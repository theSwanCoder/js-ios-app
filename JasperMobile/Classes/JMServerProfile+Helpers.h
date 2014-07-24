/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  Jaspersoft Corporation
//

#import "JMServerProfile.h"

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMServerProfile (Helpers)

/**
 Creates encoded (as SHA1) profile from provided server url, username and organization
 
 @param url The URL of JasperReports Server
 @param username The username, must be a valid account on JasperReports Server
 @param organization The name of organization
 @return profile id
 */
+ (NSString *)profileIDByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization;

/**
 Stores profile password in Keychain for profile
 
 @param profileID The Profile id
 @return YES if password was successfully saved, otherwise returns NO
 */
+ (BOOL)storePasswordInKeychain:(NSString *)password profileID:(NSString *)profileID;

/**
 Returns password from Keychain for profile
 
 @param profileID The Profile id
 @return password
 */
+ (NSString *)passwordFromKeychain:(NSString *)profileID;

/**
 Removes password from Keychain for profile
 
 @param profileID The Profile id
 @return YES if password was successfully removed, otherwise returns NO
 */
+ (BOOL)deletePasswordFromKeychain:(NSString *)profileID;

/**
 Returns an id of last selected server profile
 
 @return An id of active server profile
 */
+ (NSManagedObjectID *)activeServerID;

/**
 Returns an active server profile
 
 @return A server profile instance
 */
+ (JMServerProfile *)activeServerProfile;

/**
 Returns encoded profile id
 */
- (NSString *)profileID;

/**
 Sets in the receiver's private internal storage the value of a password.
 This method does not invoke the change notification methods (willChangeValueForKey: and didChangeValueForKey:)
 
 @param password A new password value
 */
- (void)setPasswordAsPrimitive:(NSString *)password;

@end
