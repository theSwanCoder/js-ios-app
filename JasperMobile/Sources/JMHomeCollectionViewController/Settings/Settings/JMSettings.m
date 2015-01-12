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


#import "JMSettings.h"
#import "JMSettingsItem.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMReportClientHolder.h"
#import "JMResourceClientHolder.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMBaseCellIdentifier = @"BaseCellIdentifier";
static NSString * const kJMTextCellIdentifier = @"TextCellIdentifier";
static NSString * const kJMServerCellIdentifier = @"ServerCellIdentifier";
static NSString * const kJMBooleanCellIdentifier = @"BooleanCellIdentifier";


@interface JMSettings () <JMReportClientHolder, JMResourceClientHolder>
@property (nonatomic, readwrite, strong) NSArray *itemsArray;

@end


@implementation JMSettings
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize reportClient = _reportClient;

- (id)init{
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
        [self createItemsArray];
    }
    return self;
}

- (void)createItemsArray
{
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSString *serverString = activeServerProfile ? activeServerProfile.alias : @"";
    
    NSMutableArray *itemsArray = [NSMutableArray array];
    NSArray *itemsSourceArray =
    @[@{@"title" : JMCustomLocalizedString(@"detail.settings.item.server", nil), @"value" : serverString, @"cellIdentifier" : kJMServerCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.item.connection.timeout", nil), @"value" : @(self.resourceClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.item.data.read.timeout", nil), @"value" : @(self.reportClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.crashtracking.title", nil), @"value" : @([JMUtils crashReportsSendingEnable]), @"cellIdentifier" : kJMBooleanCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"detail.settings.feedback", nil), @"value" : @"", @"cellIdentifier" : kJMBaseCellIdentifier}];
    
    for (NSDictionary *itemData in itemsSourceArray) {
        JMSettingsItem *item = [[JMSettingsItem alloc] init];
        item.titleString = [itemData objectForKey:@"title"];
        if ([[itemData objectForKey:@"value"] isKindOfClass:[NSNumber class]]) {
            item.valueSettings = [NSString stringWithFormat:@"%.0f", [[itemData objectForKey:@"value"] doubleValue]];
        } else {
            item.valueSettings = [itemData objectForKey:@"value"];
        }
        item.cellIdentifier = [itemData objectForKey:@"cellIdentifier"];
        [itemsArray addObject:item];
    }
    
    self.itemsArray = itemsArray;
}

- (void) saveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[self.itemsArray objectAtIndex:1] valueSettings] forKey:kJMDefaultRequestTimeout];
    [defaults setObject:[[self.itemsArray objectAtIndex:2] valueSettings] forKey:kJMReportRequestTimeout];
    [defaults setObject:[[self.itemsArray objectAtIndex:3] valueSettings] forKey:kJMDefaultSendingCrashReport];
    [defaults synchronize];
    
    self.resourceClient.timeoutInterval = [[[self.itemsArray objectAtIndex:1] valueSettings] doubleValue];
    self.reportClient.timeoutInterval   = [[[self.itemsArray objectAtIndex:2] valueSettings] doubleValue];
    [JMUtils activateCrashReportSendingIfNeeded];
}

@end
