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
//  JSProfile+Serialization.h
//  TIBCO JasperMobile
//

#import "JSProfile+Serialization.h"
#import "KeychainItemWrapper.h"
#import "JSEncryptionManager+Helpers.h"

NSString * const kJSProfileAliasKey = @"kJSProfileAliasKey";
NSString * const kJSProfileServerURLKey = @"kJSProfileServerURLKey";
NSString * const kJSProfileUsernameKey = @"kJSProfileUsernameKey";
NSString * const kJSProfilePasswordKey = @"kJSProfilePasswordKey";
NSString * const kJSProfileOrganizationKey = @"kJSProfileOrganizationKey";
NSString * const kJSProfileServerInfoKey = @"kJSProfileServerInfoKey";

@implementation JSProfile (Serialization)

+ (JSProfile *)profileFromDictionary:(NSDictionary*)dictionary
{
    NSString *alias = dictionary[kJSProfileAliasKey];

    NSString *username;
    NSString *password;
    KeychainItemWrapper *wrapper;
    @try {
        wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:[JSConstants keychainIdentifier] accessGroup:nil];
        JSEncryptionManager *encryptionManager = [JSEncryptionManager new];
        username = [encryptionManager decryptText:[wrapper objectForKey:(__bridge id)kSecAttrAccount]
                                    withKeyString:[NSString stringWithFormat:@"%@.%@", kJSProfileUsernameKey, alias]];
        password = [encryptionManager decryptText:[wrapper objectForKey:(__bridge id)kSecValueData]
                                    withKeyString:[NSString stringWithFormat:@"%@.%@", kJSProfilePasswordKey, alias]];
    }
    @catch (NSException *exception) {
        NSLog(@"\nException name: %@\nException reason: %@", exception.name, exception.reason);
        return nil;
    }

    if (!username || !password) {
        return nil;
    }

    NSString *serverURL = dictionary[kJSProfileServerURLKey];
    NSString *organization = dictionary[kJSProfileOrganizationKey];

    JSProfile *profile = [[JSProfile alloc] initWithAlias:alias
                                                serverUrl:serverURL
                                             organization:organization
                                                 username:username
                                                 password:password];

    NSData *serverInfoData = dictionary[kJSProfileServerInfoKey];
    JSServerInfo *serverInfo = [NSKeyedUnarchiver unarchiveObjectWithData:serverInfoData];
    profile.serverInfo = serverInfo;

    return profile;
}

- (NSDictionary *)convertToDictionary
{
    KeychainItemWrapper *wrapper;
    @try {
        wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:[JSConstants keychainIdentifier] accessGroup:nil];
        JSEncryptionManager *encryptionManager = [JSEncryptionManager new];
        NSString *encryptedUsername = [encryptionManager encryptText:self.username
                                                       withKeyString:[NSString stringWithFormat:@"%@.%@", kJSProfileUsernameKey, self.alias]];
        NSString *encryptedPassword = [encryptionManager encryptText:self.password
                                                       withKeyString:[NSString stringWithFormat:@"%@.%@", kJSProfilePasswordKey, self.alias]];
        [wrapper setObject:encryptedUsername forKey:(__bridge id)kSecAttrAccount];
        [wrapper setObject:encryptedPassword forKey:(__bridge id)kSecValueData];
    }
    @catch (NSException *exception) {
        NSLog(@"\nException name: %@\nException reason: %@", exception.name, exception.reason);
        return nil;
    }

    NSData *serverInfoData = [NSKeyedArchiver archivedDataWithRootObject:self.serverInfo];
    NSDictionary *dictionary = @{
            kJSProfileAliasKey        : self.alias,
            kJSProfileServerURLKey    : self.serverUrl,
            kJSProfileOrganizationKey : self.organization,
            kJSProfileServerInfoKey   : serverInfoData,
    };
    return dictionary;
}

@end