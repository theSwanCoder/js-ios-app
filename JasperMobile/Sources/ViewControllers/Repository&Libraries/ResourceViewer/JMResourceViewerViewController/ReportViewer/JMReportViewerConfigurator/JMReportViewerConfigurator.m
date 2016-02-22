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
#import "JMJavascriptNativeBridge.h"
#import "JMVisualizeReportLoader.h"
#import "JMRestReportLoader.h"
#import "JMReport.h"
#import "JMVisualizeManager.h"
#import "JMWebViewManager.h"

@interface JMReportViewerConfigurator()
@property (nonatomic, weak) JMReport *report;
@property (nonatomic, strong) id <JMReportLoaderProtocol> reportLoader;
@end

@implementation JMReportViewerConfigurator

#pragma mark - Public API

- (instancetype)initWithReport:(JMReport *)report {
    self = [super init];
    if (self) {
        _report = report;
    }
    return self;
}

+ (instancetype)configuratorWithReport:(JMReport *)report
{
    return [[self alloc] initWithReport:report];
}

- (WKWebView *)webViewAsSecondary:(BOOL)asSecondary
{
    if (!_webView) {
        _webView = [[JMWebViewManager sharedInstance] webViewAsSecondary:asSecondary];
        [[JMWebViewManager sharedInstance] injectCookiesInWebView:_webView];
    }
    return _webView;
}

- (id <JMReportLoaderProtocol>)reportLoader
{
    if (!_reportLoader) {
        if ([JMUtils isSupportVisualize]) {
            _reportLoader = [JMVisualizeReportLoader loaderWithReport:self.report restClient:self.restClient];
            JMVisualizeManager *visualizeManager = [JMVisualizeManager new];
            visualizeManager.viewportScaleFactor = self.viewportScaleFactor;
            ((JMVisualizeReportLoader *)_reportLoader).visualizeManager = visualizeManager;
        } else {
            _reportLoader = [JMRestReportLoader loaderWithReport:self.report restClient:self.restClient];
        }
        JMJavascriptNativeBridge *bridge = [JMJavascriptNativeBridge bridgeWithWebView:self.webView];
        _reportLoader.bridge = bridge;
    }

    return _reportLoader;
}

- (void)updateReportLoaderDelegateWithObject:(id <JMReportLoaderDelegate>)delegate
{
    [self reportLoader].delegate = delegate;
}

@end