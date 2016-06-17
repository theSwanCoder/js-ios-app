/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
@end

@implementation JMServerOptions
- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        self.isExistingServerProfile = serverProfile != nil;
        if (serverProfile) {
            self.serverProfile = serverProfile;
        } else {
            self.serverProfile = (JMServerProfile *) [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile"
                                                                                   inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        }
    }
    return self;
}

- (void)saveChanges
{
    BOOL isActiveServerProfile = [self.serverProfile isActiveServerProfile];
    
    self.serverProfile.alias = [self.optionsArray[0] optionValue];
    self.serverProfile.serverUrl = [self.optionsArray[1] optionValue];
    self.serverProfile.organization = [self.optionsArray[2] optionValue];
    self.serverProfile.askPassword  = [self.optionsArray[3] optionValue];
    self.serverProfile.keepSession  = [self.optionsArray[4] optionValue];
#ifndef  __RELEASE__
    if (self.optionsArray.count == 6) {
        self.serverProfile.useVisualize  = [self.optionsArray[5] optionValue];        
    }
#endif
    
    if ([[JMCoreDataManager sharedInstance].managedObjectContext hasChanges]) {
        NSError *error = nil;
        [[JMCoreDataManager sharedInstance] save:&error];
        
        if (!error) {
            if (isActiveServerProfile) {
                // update current active server profile
                [[JMSessionManager sharedManager] updateSessionServerProfileWith:self.serverProfile];
            }
        }
    }
}

- (BOOL)isValidData
{
    JMServerOption *serverOption = self.optionsArray[0];
    if (serverOption.optionValue && [[serverOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        if (![self.serverProfile isValidNameForServerProfile:serverOption.optionValue]) {
            serverOption.errorString = JMCustomLocalizedString(@"servers_name_errmsg_exists", nil);
        }
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers_name_errmsg_empty", nil);
    }
    
    serverOption = self.optionsArray[1];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        NSURL *url = [NSURL URLWithString:serverOption.optionValue];
        if (!url || !url.scheme || !url.host) {
            serverOption.errorString = JMCustomLocalizedString(@"servers_url_errmsg", nil);;
        }
    } else {
        serverOption.errorString = JMCustomLocalizedString(@"servers_url_errmsg", nil);
    }
    
    for (JMServerOption *option in self.optionsArray) {
        if (option.errorString) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)urlSchemeForServerProfile
{
    if ([self isValidData]) {
        NSString *urlString = [self.optionsArray[1] optionValue];
        NSString *scheme = [NSURL URLWithString:urlString].scheme;
        return scheme;
    }
    return nil;
}


- (void)discardChanges
{
    [[JMCoreDataManager sharedInstance].managedObjectContext reset];
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
                                          @[@{@"title" : [self localizedString:@"servers_name_label" mandatory:YES],     @"value" : self.serverProfile.alias          ? : @"", @"cellIdentifier" : kJMTextCellIdentifier, @"editable" : @(YES)},
                                            @{@"title" : [self localizedString:@"servers_url_label" mandatory:YES],      @"value" : self.serverProfile.serverUrl      ? : @"", @"cellIdentifier" : kJMTextCellIdentifier, @"editable" : @(self.editable)},
                                            @{@"title" : [self localizedString:@"servers_orgid_label" mandatory:NO],      @"value" : self.serverProfile.organization   ? : @"", @"cellIdentifier" : kJMTextCellIdentifier, @"editable" : @(self.editable)},
                                            @{@"title" : [self localizedString:@"servers_askpassword_label" mandatory:NO], @"value" : self.serverProfile.askPassword  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier, @"editable" : @(YES)},
                                            @{@"title" : [self localizedString:@"servers_keepSession_label" mandatory:NO], @"value" : self.serverProfile.keepSession  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier, @"editable" : @(YES)}]];

#ifndef  __RELEASE__
    if ([JMUtils isSupportVisualize]) {
        [optionsSourceArray addObject:@{
                @"title" : [self localizedString:@"servers_useVisualize_label" mandatory:NO],
                @"value" : self.serverProfile.useVisualize  ? : @(0),
                @"cellIdentifier" : kJMBooleanCellIdentifier,
                @"editable" : @(YES)
        }];
    }
#endif

    for (NSDictionary *optionData in optionsSourceArray) {
        JMServerOption *option = [[JMServerOption alloc] init];
        option.titleString      = optionData[@"title"];
        option.optionValue      = optionData[@"value"];
        option.cellIdentifier   = optionData[@"cellIdentifier"];
        option.editable         = [optionData[@"editable"] boolValue];
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

@end
