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
//  JMResourceViewerConfigurator.m
//  TIBCO JasperMobile
//

#import "JMResourceViewerConfigurator.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"
#import "JMVIZWebEnvironment.h"
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerHyperlinksManager.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMResourceViewerExternalScreenManager.h"

@implementation JMResourceViewerConfigurator

#pragma mark - Public API

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    [self.stateManager setupPageForState:JMResourceViewerStateDestroy];
}

#pragma mark - Helpers

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment
{
    _webEnvironment = webEnvironment;
    // Here we can add common configuration
}

- (JMResourceViewerStateManager *)stateManager
{
    if (!_stateManager) {
        _stateManager = [self createStateManager];
    }
    return _stateManager;
}

- (JMResourceViewerPrintManager *)printManager
{
    if (!_printManager) {
        _printManager = [self createPrintManager];
    }
    return _printManager;
}

- (JMResourceViewerInfoPageManager *)infoPageManager
{
    if (!_infoPageManager) {
        _infoPageManager = [self createInfoPageManager];
    }
    return _infoPageManager;
}

- (JMResourceViewerShareManager *)shareManager
{
    if (!_shareManager) {
        _shareManager = [self createShareManager];
    }
    return _shareManager;
}

- (JMResourceViewerHyperlinksManager *)hyperlinksManager
{
    if (!_hyperlinksManager) {
        _hyperlinksManager = [self createHyperlinksManager];
    }
    return _hyperlinksManager;
}

- (JMResourceViewerDocumentManager *)documentManager
{
    if (!_documentManager) {
        _documentManager = [self createDocumentManager];
    }
    return _documentManager;
}

- (JMResourceViewerExternalScreenManager *)externalScreenManager
{
    if (!_externalScreenManager) {
        _externalScreenManager = [self createExternalScreenManager];
    }
    return _externalScreenManager;
}

#pragma mark - Private API

- (JMResourceViewerStateManager *)createStateManager
{
    return [JMResourceViewerStateManager new];
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

- (JMResourceViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMResourceViewerExternalScreenManager new];
}

@end
