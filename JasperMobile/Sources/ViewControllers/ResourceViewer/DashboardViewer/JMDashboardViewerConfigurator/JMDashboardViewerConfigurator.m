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


//
//  JMDashboardViewerConfigurator.h
//  TIBCO JasperMobile
//

#import "JMDashboardViewerConfigurator.h"
#import "JMDashboardLoader.h"
#import "JMBaseDashboardLoader.h"
#import "JMVisDashboardLoader.h"
#import "JMWebViewManager.h"
#import "JMVisualizeManager.h"
#import "JMDashboard.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMVIZWebEnvironment.h"
#import "JMDashboardViewerStateManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerPrintManager.h"

@interface JMDashboardViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMDashboardLoader> dashboardLoader;
@property (nonatomic, strong, readwrite) JMWebEnvironment *webEnvironment;
@end

@implementation JMDashboardViewerConfigurator

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - Initializers
- (instancetype __nullable)initWithWebEnvironment:(JMWebEnvironment *__nonnull)webEnvironment
{
    self = [super init];
    if (self) {
        _webEnvironment = webEnvironment;
    }
    return self;
}

+ (instancetype __nullable)configuratorWithWebEnvironment:(JMWebEnvironment *__nonnull)webEnvironment
{
    return [[self alloc] initWithWebEnvironment:webEnvironment];
}

#pragma mark - Public API
- (void)setup
{
    [self configWithWebEnvironment:self.webEnvironment];
}

- (void)reset
{
    [self.webEnvironment reset];
    [self.stateManager setupPageForState:JMDashboardViewerStateDestroy];
}

- (void)updateReportLoaderDelegateWithObject:(id <JMDashboardLoaderDelegate>)delegate
{
    [self dashboardLoader].delegate = delegate;
}

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    _webEnvironment = webEnvironment;
    JMResourceFlowType flowType = webEnvironment.flowType;
    switch(flowType) {
        case JMResourceFlowTypeUndefined: {
            NSAssert(false, @"Should not be undefined flow type");
            break;
        }
        case JMResourceFlowTypeREST: {
            _dashboardLoader = [JMBaseDashboardLoader loaderWithRESTClient:self.restClient
                                                            webEnvironment:webEnvironment];
            break;
        }
        case JMResourceFlowTypeVIZ: {
            _dashboardLoader = [JMVisDashboardLoader loaderWithRESTClient:self.restClient
                                                           webEnvironment:webEnvironment];
            ((JMVIZWebEnvironment *)webEnvironment).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
            break;
        }
    }
    _stateManager = [self createStateManager];
    _infoPageManager = [self createInfoPageManager];
    _printManager = [self createPrintManager];
}

- (JMDashboardViewerStateManager *)createStateManager
{
    return [JMDashboardViewerStateManager new];
}

- (JMResourceViewerInfoPageManager *)createInfoPageManager
{
    return [JMResourceViewerInfoPageManager new];
}

- (JMResourceViewerPrintManager *)createPrintManager
{
    return [JMResourceViewerPrintManager new];
}

@end