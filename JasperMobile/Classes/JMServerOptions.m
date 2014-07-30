//
//  JMServerOptions.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptions.h"
#import <Objection-iOS/Objection.h>
#import "JMLocalization.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
static NSString * const kJMTextCellIdentifier = @"TextEditCell";
static NSString * const kJMSecureTextCellIdentifier = @"SecureTextEditCell";

@interface JMServerOptions ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSArray *optionsArray;

@end

@implementation JMServerOptions
objection_requires(@"managedObjectContext")

- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];

        if (serverProfile) {
            self.serverProfile = serverProfile;
        } else {
            self.serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
        }
    }
    return self;
}

- (BOOL)saveChanges
{
    self.serverProfile.alias        = [[self.optionsArray objectAtIndex:0] optionValue];
    self.serverProfile.serverUrl    = [[self.optionsArray objectAtIndex:1] optionValue];
    self.serverProfile.organization = [[self.optionsArray objectAtIndex:2] optionValue];
    self.serverProfile.username     = [[self.optionsArray objectAtIndex:3] optionValue];
    self.serverProfile.password     = [[self.optionsArray objectAtIndex:4] optionValue];
    self.serverProfile.askPassword  = [[self.optionsArray objectAtIndex:5] optionValue];

    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        [JMServerProfile storePasswordInKeychain:self.serverProfile.password profileID:self.serverProfile.profileID];
        return YES;
    }
    return NO;
}

- (void)discardChanges
{
    [self.managedObjectContext reset];
}

- (void) deleteServerProfile
{
    [self.managedObjectContext deleteObject:self.serverProfile];
}

- (void) setServerProfileActive
{
    
}

- (NSArray *)optionsArray{
    if (!_optionsArray) {
        [self createOptionsArray];
    }
    return _optionsArray;
}

- (void)createOptionsArray
{
    NSMutableArray *optionsArray = [NSMutableArray array];
    NSArray *optionsSourceArray =
    @[@{@"title" : JMCustomLocalizedString(@"servers.name.label", nil),         @"value" : self.serverProfile.alias         ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.url.label", nil),          @"value" : self.serverProfile.serverUrl     ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.orgid.label", nil),        @"value" : self.serverProfile.organization  ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.username.label", nil),     @"value" : self.serverProfile.username      ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.password.label", nil),     @"value" : self.serverProfile.password      ? : @"", @"cellIdentifier" : kJMSecureTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.askpassword.label", nil),  @"value" : self.serverProfile.askPassword   ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier}];
    
    for (NSDictionary *optionData in optionsSourceArray) {
        JMServerOption *option = [[JMServerOption alloc] init];
        option.titleString      = [optionData objectForKey:@"title"];
        option.optionValue      = [optionData objectForKey:@"value"];
        option.cellIdentifier   = [optionData objectForKey:@"cellIdentifier"];

        [optionsArray addObject:option];
    }
    
    self.optionsArray = optionsArray;
}

@end
