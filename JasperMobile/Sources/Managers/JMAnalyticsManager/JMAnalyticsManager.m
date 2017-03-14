/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMAnalyticsManager.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
// Google Analitycs
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceProduct.h"
#import "GAIEcommerceProductAction.h"
#import "GAIEcommercePromotion.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"

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
    JSUserProfile *userServerProfile = [JMSessionManager sharedManager].serverProfile;

    NSString *combinedString = [NSString stringWithFormat:@"%@+%@+%@", userServerProfile.username, userServerProfile.organization, userServerProfile.serverUrl];
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

- (NSString *)mapClassNameToReadableName:(NSString *)className
{
    NSString *readableName = className;
    if ([className isEqualToString:@"JMReportViewerVC"]) {
        readableName = @"Report viewer screen";
    } else if ([className isEqualToString:@"JMDashboardViewerVC"]) {
        readableName = @"Dashboard viewer screen";
    } else if ([className isEqualToString:@"JMContentResourceViewerVC"]) {
        readableName = @"Saved files screen";
    } else if ([className isEqualToString:@"JMLibraryCollectionViewController"]) {
        readableName = @"Library Screen";
    } else if ([className isEqualToString:@"JMMultiSelectTableViewController"]) {
        readableName = @"Multi select IC screen";
    } else if ([className isEqualToString:@"JMSingleSelectTableViewController"]) {
        readableName = @"Single select IC screen";
    } else if ([className isEqualToString:@"JMRepositoryCollectionViewController"]) {
        readableName = @"Repository screen";
    } else if ([className isEqualToString:@"JMServersGridViewController"]) {
        readableName = @"Account screen";
    } else if ([className isEqualToString:@"JMShareViewController"]) {
        readableName = @"Annotation screen";
    } else if ([className isEqualToString:@"JMResourceInfoViewController"]) {
        readableName = @"Resource Info screen";
    } else if ([className isEqualToString:@"JMInputControlsViewController"]) {
        readableName = @"Input controls screen";
    } else if ([className isEqualToString:@"JMFavoritesCollectionViewController"]) {
        readableName = @"Favorite screen";
    } else if ([className isEqualToString:@"JMSchedulesCollectionViewController"]) {
        readableName = @"Jobs";
    } else if ([className isEqualToString:@"JMScheduleVC"]) {
        readableName = @"Schedule screen";
    } else if ([className isEqualToString:@"JMSavingReportViewController"]) {
        readableName = @"Saving report screen";
    } else if ([className isEqualToString:@"JMRecentViewsCollectionViewController"]) {
        readableName = @"Recently viewed screen";
    } else if ([className isEqualToString:@"JMScheduleInfoViewController"]) {
        readableName = @"Schedule info screen";
    }
    return readableName;
}

@end
