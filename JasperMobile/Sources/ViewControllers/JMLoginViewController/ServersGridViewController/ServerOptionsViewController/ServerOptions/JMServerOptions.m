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

@interface JMServerOptions ()
@property (nonatomic, readwrite, strong) NSArray *optionsArray;
@property (nonatomic, assign) BOOL isExistingServerProfile;
@end

@implementation JMServerOptions
- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        self.isExistingServerProfile = !!serverProfile;
        if (serverProfile) {
            self.serverProfile = serverProfile;
        } else {
            self.serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
        }
    }
    return self;
}

- (void)saveChanges
{
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
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
    
    self.serverProfile.organization = [[self.optionsArray objectAtIndex:2] optionValue];
    self.serverProfile.askPassword  = [[self.optionsArray objectAtIndex:3] optionValue];
    self.serverProfile.keepSession  = [[self.optionsArray objectAtIndex:4] optionValue];
    
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
    @[@{@"title" : [self localizedString:@"servers.name.label" mandatory:YES],     @"value" : self.serverProfile.alias          ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : [self localizedString:@"servers.url.label" mandatory:YES],      @"value" : self.serverProfile.serverUrl      ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : [self localizedString:@"servers.orgid.label" mandatory:YES],    @"value" : self.serverProfile.organization   ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : [self localizedString:@"servers.askpassword.label" mandatory:NO], @"value" : self.serverProfile.askPassword  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier},
      @{@"title" : [self localizedString:@"servers.keepSession.label" mandatory:NO], @"value" : self.serverProfile.keepSession  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier}]];
    
    for (NSDictionary *optionData in optionsSourceArray) {
        JMServerOption *option = [[JMServerOption alloc] init];
        option.titleString      = [optionData objectForKey:@"title"];
        option.optionValue      = [optionData objectForKey:@"value"];
        option.cellIdentifier   = [optionData objectForKey:@"cellIdentifier"];
        [optionsArray addObject:option];
    }
    self.optionsArray = optionsArray;
}

- (NSString *)localizedString:(NSString *)key mandatory:(BOOL)mandatory
{
    if (mandatory) {
       return [NSString stringWithFormat:@"* %@",JMCustomLocalizedString(key, nil)];
    }
    return JMCustomLocalizedString(key, nil);
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

@end
