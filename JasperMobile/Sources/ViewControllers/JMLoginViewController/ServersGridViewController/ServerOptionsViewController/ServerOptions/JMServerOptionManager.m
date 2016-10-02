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


#import "JMServerOptionManager.h"
#import "JMServerProfile+Helpers.h"
#import "JMCoreDataManager.h"
#import "JMSessionManager.h"
#import "JMLocalization.h"
#import "JMConstants.h"

NSString * const kJMBooleanCellIdentifier = @"BooleanCell";
NSString * const kJMTextCellIdentifier = @"TextEditCell";

NSString *const JMCacheReportsOptionDidChangeNotification = @"JMCacheReportsOptionDidChangeNotification";

@interface JMServerOptionManager ()
@property (nonatomic, readwrite) NSDictionary <NSNumber *, JMServerOption *>*availableOptions;
@end

@implementation JMServerOptionManager
- (id)initWithServerProfile:(JMServerProfile *)serverProfile
{
    self = [super init];
    if (self) {
        self.isExistingServerProfile = serverProfile != nil;
        if (serverProfile) {
            self.serverProfile = serverProfile;
        } else {
            self.serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile"
                                                                                   inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        }
    }
    return self;
}

- (void)saveChanges
{
    BOOL isActiveServerProfile = [self.serverProfile isActiveServerProfile];
    
    self.serverProfile.alias        = [self.availableOptions[@(JMServerOptionTypeAlias)] optionValue];
    self.serverProfile.serverUrl    = [self.availableOptions[@(JMServerOptionTypeURL)] optionValue];
    self.serverProfile.organization = [self.availableOptions[@(JMServerOptionTypeOrganization)] optionValue];
    self.serverProfile.askPassword  = [self.availableOptions[@(JMServerOptionTypeAskPassword)] optionValue];
    self.serverProfile.keepSession  = [self.availableOptions[@(JMServerOptionTypeKeepSession)] optionValue];
#ifndef  __RELEASE__
    self.serverProfile.useVisualize = [self.availableOptions[@(JMServerOptionTypeUseVisualize)] optionValue];
    BOOL cacheReportsNewValue = ((NSNumber *)[self.availableOptions[@(JMServerOptionTypeCacheReports)] optionValue]).boolValue;
    BOOL cacheReportsCurrentValue = self.serverProfile.cacheReports.boolValue;
    self.serverProfile.cacheReports = @(cacheReportsNewValue);
    if (cacheReportsCurrentValue != cacheReportsNewValue) {
        // POST notification
//        [[NSNotificationCenter defaultCenter] postNotificationName:JMCacheReportsOptionDidChangeNotification
//                                                            object:self.serverProfile];
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
    BOOL isValidData = YES;
    JMServerOption *serverOption = self.availableOptions[@(JMServerOptionTypeAlias)];
    if (serverOption.optionValue && [[serverOption.optionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        // Check if alias is unique
        if (!self.isExistingServerProfile && ![self.serverProfile isValidNameForServerProfile:serverOption.optionValue]) {
            isValidData = NO;
            serverOption.errorString = JMLocalizedString(@"servers_name_errmsg_exists");
        }
    } else {
        isValidData = NO;
        serverOption.errorString = JMLocalizedString(@"servers_name_errmsg_empty");
    }
    
    serverOption = self.availableOptions[@(JMServerOptionTypeURL)];
    if (serverOption.optionValue && [serverOption.optionValue length]) {
        NSURL *url = [NSURL URLWithString:serverOption.optionValue];
        if (!url || !url.scheme || !url.host) {
            isValidData = NO;
            serverOption.errorString = JMLocalizedString(@"servers_url_errmsg");;
        }
    } else {
        isValidData = NO;
        serverOption.errorString = JMLocalizedString(@"servers_url_errmsg");
    }
    
    return isValidData;
}

- (NSString *)urlSchemeForServerProfile
{
    if ([self isValidData]) {
        NSString *urlString = [self.availableOptions[@(JMServerOptionTypeURL)] optionValue];
        NSString *scheme = [NSURL URLWithString:urlString].scheme;
        return scheme;
    }
    return nil;
}


- (void)discardChanges
{
    [[JMCoreDataManager sharedInstance].managedObjectContext reset];
}

- (NSDictionary  *)availableOptions{
    if (!_availableOptions) {
        _availableOptions = [self createAvailableOptions];
    }
    return _availableOptions;
}

- (NSDictionary  *)createAvailableOptions
{
    NSDictionary *availableOptions = @{
                                       @(JMServerOptionTypeAlias) : [JMServerOption optionWithTitle:@"servers_name_label"
                                                                                        optionValue:self.serverProfile.alias ? : @""
                                                                                     cellIdentifier:kJMTextCellIdentifier
                                                                                           editable:YES
                                                                             elementPageAccessibilityId:JMNewServerProfilePageNameAccessibilityId
                                                                                          mandatory:YES],
                                       @(JMServerOptionTypeURL) : [JMServerOption optionWithTitle:@"servers_url_label"
                                                                                      optionValue:self.serverProfile.serverUrl ? : @""
                                                                                   cellIdentifier:kJMTextCellIdentifier
                                                                                         editable:self.editable
                                                                           elementPageAccessibilityId:JMNewServerProfilePageServerURLAccessibilityId
                                                                                        mandatory:YES],
                                       @(JMServerOptionTypeOrganization) : [JMServerOption optionWithTitle:@"servers_orgid_label"
                                                                                               optionValue:self.serverProfile.organization ? : @""
                                                                                            cellIdentifier:kJMTextCellIdentifier
                                                                                                  editable:self.editable
                                                                                    elementPageAccessibilityId:JMNewServerProfilePageOrganizationAccessibilityId
                                                                                                 mandatory:NO],
                                       @(JMServerOptionTypeAskPassword) : [JMServerOption optionWithTitle:@"servers_askpassword_label"
                                                                                              optionValue:self.serverProfile.askPassword ? : @(NO)
                                                                                           cellIdentifier:kJMBooleanCellIdentifier
                                                                                                 editable:YES
                                                                                   elementPageAccessibilityId:JMNewServerProfilePageAskPasswordAccessibilityId
                                                                                                mandatory:NO],
                                       @(JMServerOptionTypeKeepSession) : [JMServerOption optionWithTitle:@"servers_keepSession_label"
                                                                                              optionValue:self.serverProfile.keepSession  ? : @(NO)
                                                                                           cellIdentifier:kJMBooleanCellIdentifier
                                                                                                 editable:YES
                                                                                   elementPageAccessibilityId:JMNewServerProfilePageKeepSessionAccessibilityId
                                                                                                mandatory:NO],
                                       @(JMServerOptionTypeUseVisualize) : [JMServerOption optionWithTitle:@"servers_useVisualize_label"
                                                                                               optionValue:self.serverProfile.useVisualize  ? : @(NO)
                                                                                            cellIdentifier:kJMBooleanCellIdentifier
                                                                                                  editable:YES
                                                                                    elementPageAccessibilityId:JMNewServerProfilePageUseVisualizeAccessibilityId
                                                                                                 mandatory:NO],
                                       @(JMServerOptionTypeCacheReports) : [JMServerOption optionWithTitle:@"servers_cacheReport_label"
                                                                                               optionValue:self.serverProfile.cacheReports  ? : @(NO)
                                                                                            cellIdentifier:kJMBooleanCellIdentifier
                                                                                                  editable:YES
                                                                                    elementPageAccessibilityId:JMNewServerProfilePageUseCacheReportAccessibilityId
                                                                                                 mandatory:NO],
                                       };
    return availableOptions;
}

@end
