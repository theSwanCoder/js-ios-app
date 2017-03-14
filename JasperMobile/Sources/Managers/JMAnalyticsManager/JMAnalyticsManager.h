/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Olexandr Dahno odahno@tibco.com
 @since 2.5
 */

#import <Foundation/Foundation.h>

@interface JMAnalyticsManager : NSObject
+ (instancetype __nullable)sharedManager;
- (void)sendAnalyticsEventWithInfo:(NSDictionary *__nonnull)eventInfo;
- (void)sendAnalyticsEventAboutLoginSuccess:(BOOL)success additionInfo:(NSDictionary *__nonnull)additionInfo;
- (void)sendAnalyticsEventAboutLogout;
- (void)sendThumbnailEventIfNeed;

- (NSString * __nonnull)mapClassNameToReadableName:(NSString * __nonnull)className;
@end
