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
//  JMServerProfile+Helpers.m
//  TIBCO JasperMobile
//

#import "JMServerProfile+Helpers.h"
#import "JMConstants.h"
#import "SSKeychain.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation JMServerProfile (Helpers)

static NSString * const kJMKeychainServiceName = @"JasperMobilePasswordStorage";

+ (NSString *)profileIDByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization
{
    NSString *profileID = [NSString stringWithFormat:@"%@|%@|%@", url, username, organization];
    
    const char *cString = [profileID cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cString length:profileID.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* encodedProfileID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [encodedProfileID appendFormat:@"%02x", digest[i]];
    }
    
    return encodedProfileID;
}

+ (BOOL)storePasswordInKeychain:(NSString *)password profileID:(NSString *)profileID
{
    return [SSKeychain setPassword:password forService:kJMKeychainServiceName account:profileID];
}

+ (NSString *)passwordFromKeychain:(NSString *)profileID
{
    return [SSKeychain passwordForService:kJMKeychainServiceName account:profileID];
}

+ (BOOL)deletePasswordFromKeychain:(NSString *)profileID
{
    return [SSKeychain deletePasswordForService:kJMKeychainServiceName account:profileID];
}

+ (NSManagedObjectID *)activeServerID
{
    if (!self.managedObjectContext) return nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [defaults URLForKey:kJMDefaultsActiveServer];
    NSManagedObjectID *activeServerID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
    
    return activeServerID;
}

+ (JMServerProfile *)activeServerProfile
{
    NSManagedObjectID *activeServerID = [JMServerProfile activeServerID];
    if (!activeServerID || !self.managedObjectContext) return nil;
    
    JMServerProfile *serverProfile = (JMServerProfile *) [self.managedObjectContext existingObjectWithID:activeServerID error:nil];
    if (serverProfile) {
        [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
    }
    
    return serverProfile;
}

- (NSString *)profileID
{
    return [self.class profileIDByServerURL:self.serverUrl username:self.username organization:self.organization];
}

- (void)setPasswordAsPrimitive:(NSString *)password
{
    [self setPrimitiveValue:password forKey:@"password"];
}

- (BOOL)serverProfileIsActive
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSManagedObjectID *activeID = activeServerProfile.objectID;
    NSManagedObjectID *selfID = self.objectID;
    
    return [activeID isEqual:selfID];
}

- (void)setServerProfileIsActive:(BOOL)serverProfileIsActive
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[self.objectID URIRepresentation] forKey:kJMDefaultsActiveServer];
    [defaults synchronize];
    
    [JMUtils sendChangeServerProfileNotificationWithProfile:self withParams:nil];
}

+ (float) minSupportedServerVersion
{
    return [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_5_0;
}

#pragma mark - Private

+ (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

@end
