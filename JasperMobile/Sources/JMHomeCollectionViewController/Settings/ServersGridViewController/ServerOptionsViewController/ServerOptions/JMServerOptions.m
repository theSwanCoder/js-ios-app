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


#import "JMServerOptions.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
static NSString * const kJMTextCellIdentifier = @"TextEditCell";
static NSString * const kJMSecureTextCellIdentifier = @"SecureTextEditCell";
static NSString * const kJMMakeActiveCellIdentifier = @"MakeActiveCell";

@interface JMServerOptions ()
@property (nonatomic, readwrite, strong) NSArray *optionsArray;
@property (nonatomic, assign) BOOL isExistingServerProfile;
@end

@implementation JMServerOptions
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
        [self.serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:self.serverProfile.profileID]];
    }
    return self;
}

- (void)saveChanges
{
    if ([self.managedObjectContext hasChanges]) {
        [JMServerProfile storePasswordInKeychain:self.serverProfile.password profileID:self.serverProfile.profileID];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
    }
    if (self.serverProfile.serverProfileIsActive) {
        [self setServerProfileActive];
    }
}

- (BOOL)isValidData
{
    JMServerOption *serverOption = [self.optionsArray objectAtIndex:0];
    if (serverOption.optionValue && [[serverOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        JMServerProfile *serverProfile = [JMServerProfile serverProfileForname:serverOption.optionValue];
        if (serverProfile && ![serverProfile isEqual:self.serverProfile]) {
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

    self.serverProfile.organization = [[self.optionsArray objectAtIndex:2] optionValue];
    self.serverProfile.askPassword  = [[self.optionsArray objectAtIndex:5] optionValue];

    for (JMServerOption *option in self.optionsArray) {
        if (option.errorString) {
            return NO;
        }
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

- (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

@end
