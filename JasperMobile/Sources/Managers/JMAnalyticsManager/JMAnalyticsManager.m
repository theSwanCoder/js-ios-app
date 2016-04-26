/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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

//
//  JMAnalyticsManager.h
//  TIBCO JasperMobile
//

#import "JMAnalyticsManager.h"
@interface JMAnalyticsManager()
@property (nonatomic, assign, getter=isNeedSendThumbnailEvent) BOOL needSendThumbnailEvent;
@end

@implementation JMAnalyticsManager

#pragma mark - Initialize
+ (instancetype)sharedManager
{
    static JMAnalyticsManager *sharedManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [JMAnalyticsManager new];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _needSendThumbnailEvent = YES;
    }
    return self;
}

#pragma mark - Public API
- (void)sendAnalyticsEventWithInfo:(NSDictionary *)eventInfo
{
    NSString *version = self.restClient.serverInfo.version;
    NSString *edition = self.restClient.serverInfo.edition;
    if ([JMUtils isDemoAccount]) {
        version = [version stringByAppendingString:@"(Demo)"];
    }

    // Crashlytics - Answers
    NSMutableDictionary *extendedEventInfo = [eventInfo mutableCopy];
    extendedEventInfo[kJMAnalyticsServerVersionKey] = version;
    extendedEventInfo[kJMAnalyticsServerEditionKey] = edition;
    [Answers logCustomEventWithName:eventInfo[kJMAnalyticsCategoryKey]
                   customAttributes:extendedEventInfo];

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:eventInfo[kJMAnalyticsCategoryKey]                 // Event category (required)
                                                                           action:eventInfo[kJMAnalyticsActionKey]                   // Event action (required)
                                                                            label:eventInfo[kJMAnalyticsLabelKey]                    // Event label
                                                                            value:nil];
    // Event value
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerVersionIndex]
           value:version];
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerEditionIndex]
           value:edition];

    [tracker send:[builder build]];
}

- (void)sendAnalyticsEventAboutLoginSuccess:(BOOL)success additionInfo:(NSDictionary *)additionInfo
{
    NSString *version = self.restClient.serverInfo.version;
    NSString *edition = self.restClient.serverInfo.edition;
    if ([JMUtils isDemoAccount]) {
        version = [version stringByAppendingString:@"(Demo)"];
    }

    // Crashlytics - Answers
    NSMutableDictionary *extendedEventInfo = [additionInfo mutableCopy];
    extendedEventInfo[kJMAnalyticsServerVersionKey] = version;
    extendedEventInfo[kJMAnalyticsServerEditionKey] = edition;
    [Answers logLoginWithMethod:@"Digits"
                        success:@(success)
               customAttributes:extendedEventInfo];

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:additionInfo[kJMAnalyticsCategoryKey]                 // Event category (required)
                                                                           action:additionInfo[kJMAnalyticsActionKey]                   // Event action (required)
                                                                            label:additionInfo[kJMAnalyticsLabelKey]                    // Event label
                                                                            value:nil];
    [builder set:@"start" forKey:kGAISessionControl];
    // Event value
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerVersionIndex]
           value:version];
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerEditionIndex]
           value:edition];

#ifndef __RELEASE__
    // try track real profile count (not just users).
    NSString *combinedString = [NSString stringWithFormat:@"%@+%@+%@", self.restClient.serverProfile.username, self.restClient.serverProfile.organization, self.restClient.serverProfile.serverUrl];
    NSData *combinedStringData = [combinedString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *uuid = [combinedStringData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [tracker set:kGAIUserId
           value:uuid];
#endif

    [tracker send:[builder build]];
}

- (void)sendAnalyticsEventAboutLogout
{
    self.needSendThumbnailEvent = YES;
}

- (void)sendThumbnailEventIfNeed
{
    if (self.isNeedSendThumbnailEvent) {
        [self sendAnalyticsEventWithInfo:@{
                kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryOther,
                kJMAnalyticsActionKey   : kJMAnalyticsEventActionViewed,
                kJMAnalyticsLabelKey    : kJMAnalyticsLabelThumbnail
        }];
        self.needSendThumbnailEvent = NO;
    }
}

@end