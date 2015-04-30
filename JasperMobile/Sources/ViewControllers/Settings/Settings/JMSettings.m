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
#import "JMResourceClientHolder.h"
#import "JMServerProfile+Helpers.h"

static NSString * const kJMTextCellIdentifier = @"TextCellIdentifier";
static NSString * const kJMBooleanCellIdentifier = @"BooleanCellIdentifier";
static NSString * const kJMFeedbackCellIdentifier = @"FeedbackCellIdentifier";
static NSString * const kJMIntroCellIdentifier = @"IntroCellIdentifier";



@interface JMSettings () <JMResourceClientHolder>
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
      @{@"title" : JMCustomLocalizedString(@"settings.item.connection.timeout", nil), @"value" : @(self.restClient.timeoutInterval), @"cellIdentifier" : kJMTextCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.crashtracking.title", nil), @"value" : @([JMUtils crashReportsSendingEnable]), @"cellIdentifier" : kJMBooleanCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.item.intro", nil), @"value" : @"", @"cellIdentifier" : kJMIntroCellIdentifier},
      @{@"title" : JMCustomLocalizedString(@"settings.feedback", nil), @"value" : @"", @"cellIdentifier" : kJMFeedbackCellIdentifier},
      // used for test purpose
      //@{@"title" : @"Use Visualize", @"value" : @([JMUtils shouldUseVisualize]), @"cellIdentifier" : kJMBooleanCellIdentifier}
      ];
    
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
    [defaults setObject:[[self.itemsArray objectAtIndex:0] valueSettings] forKey:kJMDefaultRequestTimeout];
    [defaults setObject:[[self.itemsArray objectAtIndex:1] valueSettings] forKey:kJMDefaultSendingCrashReport];
    // used for test purpose
    //[defaults setObject:[[self.itemsArray objectAtIndex:4] valueSettings] forKey:kJMDefaultUseVisualize];
    [defaults synchronize];
    
    self.restClient.timeoutInterval = [[[self.itemsArray objectAtIndex:0] valueSettings] doubleValue];
    [JMUtils activateCrashReportSendingIfNeeded];
}

@end
