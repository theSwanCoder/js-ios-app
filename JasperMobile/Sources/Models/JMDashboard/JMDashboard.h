/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

#import <Foundation/Foundation.h>

@class JMResource;

@interface JMDashboard : JSDashboard
// getters
@property (nonatomic, strong, readonly) JMResource *resource;
@property (nonatomic, copy) NSArray <JSDashboardComponent *>*components;
@property (nonatomic, weak) JSDashboardComponent *maximizedComponent;

#warning NEED CHECK USELESS FOR INITIALIZE WITH RESOURCE
- (instancetype)initWithResource:(JMResource *)resource;
+ (instancetype)dashboardWithResource:(JMResource *)resource;

@end
