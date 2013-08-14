/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  Jaspersoft Corporation
//

#import "JMServerProfile+Helpers.h"
#import "SSKeychain.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import <jaspersoft-sdk/JSProfile.h>

@implementation JMServerProfile (Helpers)

static NSString * const kJMKeychainServiceName = @"JasperMobilePasswordStorage";

+ (NSString *)profileIDByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization
{
    NSString *profileID = [NSString stringWithFormat:@"%@|%@|%@", url, username, organization];
    
    const char *cstr = [profileID cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:profileID.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
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

- (NSString *)profileID
{
    return [self.class profileIDByServerURL:self.serverUrl username:self.username organization:self.organization];
}

- (BOOL)isEqualToProfile:(JMServerProfile *)profile
{
    return [self.profileID isEqualToString:profile.profileID];
}

- (BOOL)isEqualToProfileByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization
{
    return [self.profileID isEqualToString:[JMServerProfile profileIDByServerURL:url username:username organization:organization]];
}

- (void)setPasswordAsPrimitive:(NSString *)password
{
    [self setPrimitiveValue:password forKey:@"password"];
}

@end
