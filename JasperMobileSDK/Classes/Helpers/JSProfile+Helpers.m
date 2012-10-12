//
//  JSProfile+Helpers.m
//  JasperMobile
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
