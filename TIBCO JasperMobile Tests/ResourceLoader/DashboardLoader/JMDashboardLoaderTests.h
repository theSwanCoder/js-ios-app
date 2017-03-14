/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMResourceLoaderBaseTests.h"

@protocol JMDashboardLoader;
@class JMDashboard;

@interface JMDashboardLoaderTests : JMResourceLoaderBaseTests
@property (nonatomic, strong, nullable) id<JMDashboardLoader> loader;

- (JMDashboard *__nonnull)sampleDashboard;

@end
