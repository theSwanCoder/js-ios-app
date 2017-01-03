//
// Created by Aleksandr Dakhno on 12/29/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//


#import "JMResourceLoaderBaseTests.h"

@protocol JMDashboardLoader;
@class JMDashboard;

@interface JMDashboardLoaderTests : JMResourceLoaderBaseTests
@property (nonatomic, strong, nullable) id<JMDashboardLoader> loader;

- (JMDashboard *__nonnull)sampleDashboard;

@end