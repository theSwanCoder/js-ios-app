//
//  JMUITestProfile.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/3/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMUITestServerProfile.h"

@interface JMUITestServerProfile()
@property(nonatomic, copy, readwrite) NSString *name;
@property(nonatomic, copy, readwrite) NSString *url;
@property(nonatomic, copy, readwrite) NSString *username;
@property(nonatomic, copy, readwrite) NSString *password;
@property(nonatomic, copy, readwrite) NSString *organization;
@end

@implementation JMUITestServerProfile

- (instancetype)initWithName:(NSString *)name
                         URL:(NSString *)url
                    username:(NSString *)username
                    password:(NSString *)password
                organization:(NSString *)organization
{
    self = [super init];
    if (self) {
        _name = name;
        _url = url;
        _username = username;
        _password = password;
        _organization = organization;
    }
    return self;
}

@end
