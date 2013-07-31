/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  ServerProfile+Helpers.h
//  Jaspersoft Corporation
//

#import "JMServerProfile.h"

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
 Returns encoded profile id
 */
- (NSString *)profileID;

/**
 Returns a Boolean value that indicates whether a given profile is equal to the
 receiver by server url, username and organization
 
 @return YES if profile is equal to receiver, otherwise returns NO
 */
- (BOOL)isEqualToProfile:(JMServerProfile *)profile;

/**
 Returns a Boolean value that indicates whether a given profile is equal to the
 receiver by server url, username and organization
 
 @param url The URL of JasperReports Server
 @param username The username, must be a valid account on JasperReports Server
 @param organization The name of organization
 @return YES if profile is equal to receiver, otherwise returns NO
 */
- (BOOL)isEqualToProfileByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization;

@end
