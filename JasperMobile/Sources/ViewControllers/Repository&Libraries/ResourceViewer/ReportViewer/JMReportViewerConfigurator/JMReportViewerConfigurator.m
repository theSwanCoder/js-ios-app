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
//  JMReportViewerConfigurator.m
//  TIBCO JasperMobile
//

#import "JMReportViewerConfigurator.h"
#import "JMReportLoaderProtocol.h"
#import "JMVisualizeReportLoader.h"
#import "JMRestReportLoader.h"
#import "JMVisualizeManager.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"
#import "JMVIZWebEnvironment.h"
#import "JMReportViewerStateManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMReportViewerExternalScreenManager.h"

@interface JMReportViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMReportLoaderProtocol> reportLoader;
@end

@implementation JMReportViewerConfigurator

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    [super configWithWebEnvironment:webEnvironment];
    
    if ([JMUtils flowTypeForReportViewer] == JMResourceFlowTypeVIZ) {
        JMLog(@"run with VIZ");
        _reportLoader = [JMVisualizeReportLoader loaderWithRestClient:self.restClient
                                                       webEnvironment:webEnvironment];
        ((JMVIZWebEnvironment *)webEnvironment).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
    } else {
        JMLog(@"run with REST");
        _reportLoader = (id <JMReportLoaderProtocol>) [JMRestReportLoader loaderWithRestClient:self.restClient
                                                                                webEnvironment:webEnvironment];
    }
}

- (JMReportViewerStateManager *)createStateManager
{
    return [JMReportViewerStateManager new];
}

- (JMReportViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMReportViewerExternalScreenManager new];
}

@end
