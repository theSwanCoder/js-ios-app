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


#import "JMAccountOptions.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
static NSString * const kJMTextCellIdentifier = @"TextEditCell";

@interface JMAccountOptions ()
@property (nonatomic, readwrite, strong) NSArray *optionsArray;
@property (nonatomic, strong) JMServerProfile *serverProfile;
@end

@implementation JMAccountOptions

- (BOOL)saveChanges
{
    if ([[JMCoreDataManager sharedInstance].managedObjectContext hasChanges]) {
        [[JMCoreDataManager sharedInstance] save:nil];
#warning SHOULD APPLY THESE CHANGES TO RESTCLIENT
//        self.restClient.keepSession = self.serverProfile.keepSession;
//        self.restClient.serverProfile.alias = self.serverProfile.alias;
        
        return YES;
    }
    return NO;
}

- (JMServerProfile *)serverProfile
{
    if (!_serverProfile) {
        _serverProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
    }
    return _serverProfile;
}

- (BOOL)isValidData
{
    JMAccountOption *accountOption = self.optionsArray[0];
    if (accountOption.optionValue && [[accountOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        if ([self.serverProfile isValidNameForServerProfile:accountOption.optionValue]) {
            self.serverProfile.alias = accountOption.optionValue;
        } else {
            accountOption.errorString = JMCustomLocalizedString(@"servers.name.errmsg.exists", nil);
        }
    } else {
        accountOption.errorString = JMCustomLocalizedString(@"servers.name.errmsg.empty", nil);
    }
    
    self.serverProfile.askPassword  = [self.optionsArray[1] optionValue];
    self.serverProfile.keepSession  = [self.optionsArray[2] optionValue];
    
    for (JMAccountOption *option in self.optionsArray) {
        if (option.errorString) {
            return NO;
        }
    }
    
    return YES;
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
    NSMutableArray *optionsSourceArray = [@[@{@"title" : @"servers.name.label",         @"value" : self.serverProfile.alias        ? : @"", @"cellIdentifier" : kJMTextCellIdentifier},
                                            @{@"title" : @"servers.askpassword.label",  @"value" : self.serverProfile.askPassword  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier},
                                            @{@"title" : @"servers.keepSession.label",  @"value" : self.serverProfile.keepSession  ? : @(0), @"cellIdentifier" : kJMBooleanCellIdentifier}] mutableCopy];
    
    for (NSDictionary *optionData in optionsSourceArray) {
        JMAccountOption *option = [JMAccountOption new];
        option.titleString      = JMCustomLocalizedString(optionData[@"title"], nil);
        option.optionValue      = optionData[@"value"];
        option.cellIdentifier   = optionData[@"cellIdentifier"];
        [optionsArray addObject:option];
    }
    self.optionsArray = optionsArray;
}

@end
