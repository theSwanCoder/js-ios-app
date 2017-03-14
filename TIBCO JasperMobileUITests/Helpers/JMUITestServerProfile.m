/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMUITestServerProfile.h"

@interface JMUITestServerProfile()
@property(nonatomic, copy, readwrite) NSString *alias;
@property(nonatomic, copy, readwrite) NSString *url;
@property(nonatomic, copy, readwrite) NSString *username;
@property(nonatomic, copy, readwrite) NSString *password;
@property(nonatomic, copy, readwrite) NSString *organization;
@end

@implementation JMUITestServerProfile

- (instancetype)initWithAlias:(NSString *)alias
                          URL:(NSString *)url
                     username:(NSString *)username
                     password:(NSString *)password
                 organization:(NSString *)organization
{
    self = [super init];
    if (self) {
        _alias = alias;
        _url = url;
        _username = username;
        _password = password;
        _organization = organization;
    }
    return self;
}

@end
