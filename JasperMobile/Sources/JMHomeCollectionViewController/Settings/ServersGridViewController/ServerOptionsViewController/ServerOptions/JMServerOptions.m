//
//  JMServerOptions.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptions.h"
#import <Objection-iOS/Objection.h>
#import "JMServerProfile+Helpers.h"

static NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
static NSString * const kJMTextCellIdentifier = @"TextEditCell";
static NSString * const kJMSecureTextCellIdentifier = @"SecureTextEditCell";
static NSString * const kJMMakeActiveCellIdentifier = @"MakeActiveCell";
@interface JMServerOptions ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSArray *optionsArray;
@property (nonatomic, assign) BOOL isExistingServerProfile;
@end

@implementation JMServerOptions
objection_requires(@"managedObjectContext")

- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        self.isExistingServerProfile = !!serverProfile;
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
    JMServerOption *serverOption = [self.optionsArray objectAtIndex:0];
    if (serverOption.optionValue && [[serverOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"alias", serverOption.optionValue]];
        NSArray *servers = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

        if (servers && [servers count] && ![[servers lastObject] isEqual:self.serverProfile]) {
            serverOption.errorString = JMCustomLocalizedString(@"servers.name.errmsg.exists", nil);
        } else {
            self.serverProfile.alias = serverOption.optionValue;
        }
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers.name.errmsg.empty", nil);
    }
    
    serverOption = [self.optionsArray objectAtIndex:1];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        NSURL *url = [NSURL URLWithString:serverOption.optionValue];
        if (!url || !url.scheme || !url.host) {
            serverOption.errorString = JMCustomLocalizedString(@"servers.url.errmsg", nil);;
        } else {
            self.serverProfile.serverUrl = serverOption.optionValue;
        }
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers.url.errmsg", nil);
    }
    
    serverOption = [self.optionsArray objectAtIndex:3];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        self.serverProfile.username = serverOption.optionValue;
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers.username.errmsg.empty", nil);
    }
    
    serverOption = [self.optionsArray objectAtIndex:4];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        self.serverProfile.password = serverOption.optionValue;
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers.password.errmsg.empty", nil);
    }
    
    for (JMServerOption *option in self.optionsArray) {
        if (option.errorString) {
            return NO;
        }
    }

    self.serverProfile.organization = [[self.optionsArray objectAtIndex:2] optionValue];
    self.serverProfile.askPassword  = [[self.optionsArray objectAtIndex:5] optionValue];

    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        [JMServerProfile storePasswordInKeychain:self.serverProfile.password profileID:self.serverProfile.profileID];
    }
    if (self.serverProfile.serverProfileIsActive) {
        [self setServerProfileActive];
    }

    return YES;
}

- (void)discardChanges
{
    [self.managedObjectContext reset];
}

- (void) deleteServerProfile
{
    [self.managedObjectContext deleteObject:self.serverProfile];
    [self.managedObjectContext save:nil];
}

- (void) setServerProfileActive
{
    [self.serverProfile setServerProfileIsActive:YES];
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
    NSMutableArray *optionsSourceArray = [NSMutableArray arrayWithArray:
    @[@{@"title" : JMCustomLocalizedString(@"servers.name.label", nil),         @"value" : self.serverProfile.alias         ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.url.label", nil),          @"value" : self.serverProfile.serverUrl     ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.orgid.label", nil),        @"value" : self.serverProfile.organization  ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.username.label", nil),     @"value" : self.serverProfile.username      ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.password.label", nil),     @"value" : self.serverProfile.password      ? : @"", @"cellIdentifier" : kJMSecureTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"servers.askpassword.label", nil),  @"value" : self.serverProfile.askPassword   ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier}]];
    
    if (self.isExistingServerProfile) {
        [optionsSourceArray addObject:
         @{@"title" : JMCustomLocalizedString(@"servers.activeserver.label", nil), @"value" : @(self.serverProfile.serverProfileIsActive), @"cellIdentifier" : kJMMakeActiveCellIdentifier}];
    }
    
    for (NSDictionary *optionData in optionsSourceArray) {
        JMServerOption *option = [[JMServerOption alloc] init];
        option.titleString      = [optionData objectForKey:@"title"];
        option.optionValue      = [optionData objectForKey:@"value"];
        option.cellIdentifier   = [optionData objectForKey:@"cellIdentifier"];
        [optionsArray addObject:option];
    }
    
    if (self.isExistingServerProfile) {
        [[optionsArray lastObject] setEditable:!self.serverProfile.serverProfileIsActive];
    }
    
    self.optionsArray = optionsArray;
}

@end
