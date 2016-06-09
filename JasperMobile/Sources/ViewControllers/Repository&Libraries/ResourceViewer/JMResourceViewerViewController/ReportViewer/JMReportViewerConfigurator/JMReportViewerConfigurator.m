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
#import "JMReport.h"
#import "JMVisualizeManager.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"

@implementation JMReportViewerConfigurator

#pragma mark - Public API

- (instancetype)initWithReport:(JMReport *)report webEnvironment:(JMWebEnvironment *)webEnvironment {
    self = [super init];
    if (self) {
        BOOL needVisualizeFlow = NO;
        JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
        if (activeServerProfile && activeServerProfile.useVisualize.boolValue) {
            needVisualizeFlow = YES;
        }
        if (needVisualizeFlow) {
            JMLog(@"run with VIZ");
            _reportLoader = [JMVisualizeReportLoader loaderWithReport:report
                                                           restClient:self.restClient
                                                       webEnvironment:webEnvironment];
            ((JMVisualizeReportLoader *)_reportLoader).visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
        } else {
            JMLog(@"run with REST");
            _reportLoader = (id <JMReportLoaderProtocol>) [JMRestReportLoader loaderWithReport:report
                                                                                    restClient:self.restClient
                                                                                webEnvironment:webEnvironment];
        }
    }
    return self;
}

+ (instancetype)configuratorWithReport:(JMReport *)report webEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithReport:report webEnvironment:webEnvironment];
}

- (void)updateReportLoaderDelegateWithObject:(id <JMReportLoaderDelegate>)delegate
{
    [[self reportLoader] setDelegate:delegate];
}

@end