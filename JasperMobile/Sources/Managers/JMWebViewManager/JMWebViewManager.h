/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */

/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

@import Foundation;
@class JMWebEnvironment;

typedef NS_ENUM(NSInteger, JMResourceFlowType) {
    JMResourceFlowTypeUndefined,
    JMResourceFlowTypeREST,
    JMResourceFlowTypeVIZ
};

@interface JMWebViewManager : NSObject
@property (nonatomic, strong, readonly) NSArray *__nullable cookies;
+ (instancetype __nonnull)sharedInstance;
- (JMWebEnvironment * __nonnull)reusableWebEnvironmentWithId:(NSString * __nonnull)identifier
                                                    flowType:(JMResourceFlowType)flowType;
- (JMWebEnvironment * __nonnull)webEnvironmentForFlowType:(JMResourceFlowType)flowType;
- (JMWebEnvironment * __nonnull)webEnvironment;
- (void)reset;
// USE FOR TESTS ONLY
- (void)updateCookiesWithCookies:(NSArray <NSHTTPCookie *>*__nonnull)cookies;
@end
