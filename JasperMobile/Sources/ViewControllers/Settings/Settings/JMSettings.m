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


#import "JMSettings.h"
#import "JMSettingsItem.h"
#import "JMServerProfile+Helpers.h"

NSString * const kJMTextCellIdentifier = @"TextCellIdentifier";
NSString * const kJMLabelCellIdentifier = @"LabelCellIdentifier";
NSString * const kJMBooleanCellIdentifier = @"BooleanCellIdentifier";

NSInteger const kJMFeedbackSettingValue = 100;
NSInteger const kJMPrivacyPolicySettingValue = 101;
NSInteger const kJMOnboardIntroSettingValue = 102;
NSInteger const kJMEULASettingValue = 103;

@interface JMSettings ()
@property (nonatomic, readwrite, strong) NSArray *itemsArray;

@end


@implementation JMSettings

- (id)init{
    self = [super init];
    if (self) {
        [self createItemsArray];
    }
    return self;
}

- (void)createItemsArray
{
    NSMutableArray *itemsArray = [NSMutableArray array];
    NSArray *itemsSourceArray =
    @[
//      @{@"title" : JMCustomLocalizedString(@"settings.item.connection.timeout", nil), @"value" : @(self.restClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier},
//      @{@"title" : JMCustomLocalizedString(@"settings.crashtracking.title", nil), @"value" : @([JMUtils crashReportsSendingEnable]), @"cellIdentifier" : kJMBooleanCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.feedback", nil), @"value" : @(kJMFeedbackSettingValue), @"cellIdentifier" : kJMLabelCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.privacy.policy.title", nil), @"value" : @(kJMPrivacyPolicySettingValue), @"cellIdentifier" : kJMLabelCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.privacy.EULA.title", nil), @"value" : @(kJMEULASettingValue), @"cellIdentifier" : kJMLabelCellIdentifier},
      // used for test purpose
//      @{@"title" : JMCustomLocalizedString(@"settings.item.intro", nil), @"value" : @(kJMOnboardIntroSettingValue), @"cellIdentifier" : kJMLabelCellIdentifier},
//      @{@"title" : @"Use Visualize", @"value" : @([JMUtils shouldUseVisualize]), @"cellIdentifier" : kJMBooleanCellIdentifier}
      ];
    
    for (NSDictionary *itemData in itemsSourceArray) {
        JMSettingsItem *item = [[JMSettingsItem alloc] init];
        item.titleString = itemData[@"title"];
        if ([itemData[@"value"] isKindOfClass:[NSNumber class]]) {
            item.valueSettings = [NSString stringWithFormat:@"%.0f", [itemData[@"value"] doubleValue]];
        } else {
            item.valueSettings = itemData[@"value"];
        }
        item.cellIdentifier = itemData[@"cellIdentifier"];
        [itemsArray addObject:item];
    }
    
    self.itemsArray = itemsArray;
}

- (void) saveSettings
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:[self.itemsArray[0] valueSettings] forKey:kJMDefaultRequestTimeout];
//    [defaults setObject:[self.itemsArray[1] valueSettings] forKey:kJMDefaultSendingCrashReport];
    // used for test purpose
//    [defaults setObject:[[self.itemsArray objectAtIndex:4] valueSettings] forKey:kJMDefaultUseVisualize];
//    [defaults synchronize];
    
//    self.restClient.timeoutInterval = [[self.itemsArray[0] valueSettings] doubleValue];
//    [JMUtils activateCrashReportSendingIfNeeded];
}

@end
