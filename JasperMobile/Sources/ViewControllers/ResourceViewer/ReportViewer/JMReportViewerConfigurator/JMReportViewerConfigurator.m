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
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerHyperlinksManager.h"
#import "JMResourceViewerDocumentManager.h"

@interface JMReportViewerConfigurator()
@property (nonatomic, strong, readwrite) id <JMReportLoaderProtocol> reportLoader;
@property (nonatomic, strong, readwrite) JMWebEnvironment *webEnvironment;
@end

@implementation JMReportViewerConfigurator

#pragma mark - Public API

- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
}

- (instancetype)initWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    NSAssert(webEnvironment != nil, @"WebEnvironment is nil");
    self = [super init];
    if (self) {
        _webEnvironment = webEnvironment;
    }
    return self;
}

+ (instancetype)configuratorWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    return [[self alloc] initWithWebEnvironment:webEnvironment];
}

- (void)setup
{
    [self configWithWebEnvironment:self.webEnvironment];
}

- (void)reset
{
    [self.webEnvironment reset];
    [self.stateManager setupPageForState:JMReportViewerStateDestroy];
}

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    _webEnvironment = webEnvironment;
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
    NSAssert(_reportLoader != nil, @"Report Loader wasn't created");
    _stateManager = [self createStateManager];
    _printManager = [self createPrintManager];
    _infoPageManager = [self createInfoPageManager];
    _shareManager = [self createShareManager];
    _hyperlinksManager = [self createHyperlinksManager];
    _hyperlinksManager.delegate = self.stateManager;
    _documentManager = [self createDocumentManager];
}

- (JMReportViewerStateManager *)createStateManager
{
    return [JMReportViewerStateManager new];
}

- (JMResourceViewerPrintManager *)createPrintManager
{
    return [JMResourceViewerPrintManager new];
}

- (JMResourceViewerInfoPageManager *)createInfoPageManager
{
    return [JMResourceViewerInfoPageManager new];
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

@end