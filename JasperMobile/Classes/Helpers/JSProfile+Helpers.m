/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSProfile+Helpers.m
//  Jaspersoft Corporation
//

#import "JSProfile+Helpers.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@implementation JSProfile (Helpers)

NSString * const kTempPassword = @"kTempPassword";
NSString * const kAlwaysAskPassword = @"kAlwaysAskPassword";
@dynamic tempPassword;
@dynamic alwaysAskPassword;

+ (NSString *)profileIDByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization {
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

- (BOOL)isEqualToProfile:(JSProfile *)profile {
    return [[self profileID] isEqualToString:[profile profileID]];
}

- (BOOL)isEqualToProfileByServerURL:(NSString *)url username:(NSString *)username organization:(NSString *)organization {
    JSProfile *tempProfile = [[JSProfile alloc] initWithAlias:nil
                                                     username:username 
                                                     password:nil 
                                                 organization:organization 
                                                    serverUrl:url];
    return [self isEqualToProfile:tempProfile];
}

- (NSString *)profileID {
    return [self.class profileIDByServerURL:self.serverUrl username:self.username organization:self.organization];
}

- (void)setTempPassword:(NSString *)tempPassword {
    objc_setAssociatedObject(self, &kTempPassword, tempPassword, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)tempPassword {
    return objc_getAssociatedObject(self, &kTempPassword);
}

- (void)setAlwaysAskPassword:(NSNumber *)alwaysAskPassword {
    objc_setAssociatedObject(self, &kAlwaysAskPassword, alwaysAskPassword, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)alwaysAskPassword {
    return objc_getAssociatedObject(self, &kAlwaysAskPassword);
}

@end
