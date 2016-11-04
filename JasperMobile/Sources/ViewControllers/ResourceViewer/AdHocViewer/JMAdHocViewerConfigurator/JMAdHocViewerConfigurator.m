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
//  JMAdHocViewerConfigurator.h
//  TIBCO JasperMobile
//

#import "JMAdHocViewerConfigurator.h"
#import "JMAdHocLoader.h"
#import "JMLegacyDashboardLoader.h"
#import "JMVisDashboardLoader.h"
#import "JMWebViewManager.h"
#import "JMVisualizeManager.h"
#import "JMAdHoc.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMVIZWebEnvironment.h"
#import "JMAdHocViewerStateManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerHyperlinksManager.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMResourceViewerSessionManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMAdHocViewerExternalScreenManager.h"

@interface JMAdHocViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMAdHocLoader> adHocLoader;
@property (nonatomic, strong, readwrite) JMWebEnvironment *webEnvironment;
@end

@implementation JMAdHocViewerConfigurator

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
    [self.stateManager setupPageForState:JMAdHocViewerState_Destroy];
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
            NSAssert(false, @"Should not be REST flow type");
            break;
        }
        case JMResourceFlowTypeVIZ: {
            _adHocLoader = [JMAdHocLoader loaderWithRESTClient:self.restClient
                                                webEnvironment:webEnvironment];
            ((JMVIZWebEnvironment *)webEnvironment).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
            break;
        }
    }
    _stateManager = [self createStateManager];
    _infoPageManager = [self createInfoPageManager];
    _printManager = [self createPrintManager];
    _shareManager = [self createShareManager];
    _documentManager = [self createDocumentManager];
    _sessionManager = [self createSessionManager];
    _externalScreenManager = [self createExternalScreenManager];
}

- (JMAdHocViewerStateManager *)createStateManager
{
    return [JMAdHocViewerStateManager new];
}

- (JMResourceViewerInfoPageManager *)createInfoPageManager
{
    return [JMResourceViewerInfoPageManager new];
}

- (JMResourceViewerPrintManager *)createPrintManager
{
    return [JMResourceViewerPrintManager new];
}

- (JMResourceViewerShareManager *)createShareManager
{
    return [JMResourceViewerShareManager new];
}

- (JMResourceViewerHyperlinksManager *)createHyperlinksManager
{
    return [JMResourceViewerHyperlinksManager new];
}

- (JMResourceViewerDocumentManager *)createDocumentManager
{
    return [JMResourceViewerDocumentManager new];
}

- (JMResourceViewerSessionManager *)createSessionManager
{
    return [JMResourceViewerSessionManager new];
}

- (JMAdHocViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMAdHocViewerExternalScreenManager new];
}

@end
