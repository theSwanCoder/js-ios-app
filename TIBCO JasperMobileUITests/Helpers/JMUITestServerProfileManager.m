//
// Created by Aleksandr Dakhno on 11/3/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMUITestServerProfileManager.h"
#import "JMUITestServerProfile.h"

@interface JMUITestServerProfileManager()

@end

@implementation JMUITestServerProfileManager

+ (instancetype)sharedManager
{
    static JMUITestServerProfileManager *sharedManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [JMUITestServerProfileManager new];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _testProfile = [self configurableFromCommandLineProfileWithoutOrganization];
    }
    return self;
}

- (void)switchToDemoProfile
{
    self.testProfile = [self mobileDemoProfile];
}

#pragma mark - Profiles

- (JMUITestServerProfile *)mobileDemoProfile
{
    return [[JMUITestServerProfile alloc] initWithAlias:@"Demo Profile"
                                                    URL:@"https://mobiledemo.jaspersoft.com/jasperserver-pro"
                                               username:@"phoneuser"
                                               password:@"phoneuser"
                                           organization:@"organization_1"];
}

- (JMUITestServerProfile *)localInstanceProfile
{
    return [[JMUITestServerProfile alloc] initWithAlias:@"Test Profile"
                                                    URL:@"http://192.168.88.55:8090/jasperserver-pro-630"
                                               username:@"superuser"
                                               password:@"superuser"
                                           organization:@""];
}

- (JMUITestServerProfile *)remoteAccessLocalInstanceProfile
{
    return [[JMUITestServerProfile alloc] initWithAlias:@"Test Profile"
                                                    URL:@"http://194.29.62.80:8092/jasperserver-pro-630-ui-tests"
                                               username:@"superuser"
                                               password:@"superuser"
                                           organization:@""];
}

- (JMUITestServerProfile *)configurableFromCommandLineProfile
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *path = [bundle pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [[JMUITestServerProfile alloc] initWithAlias:infoDict[@"JMUITestsServerProfileName"]
                                                    URL:infoDict[@"JMUITestsServerProfileURL"]
                                               username:infoDict[@"JMUITestsServerProfileUsername"]
                                               password:infoDict[@"JMUITestsServerProfilePassword"]
                                           organization:infoDict[@"JMUITestsServerProfileOrganization"]];
}

// TODO: remove this after updating parameters on CI
- (JMUITestServerProfile *)configurableFromCommandLineProfileWithoutOrganization
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *path = [bundle pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];

    return [[JMUITestServerProfile alloc] initWithAlias:infoDict[@"JMUITestsServerProfileName"]
                                                    URL:infoDict[@"JMUITestsServerProfileURL"]
                                               username:infoDict[@"JMUITestsServerProfileUsername"]
                                               password:infoDict[@"JMUITestsServerProfilePassword"]
                                           organization:@""];
}

@end
