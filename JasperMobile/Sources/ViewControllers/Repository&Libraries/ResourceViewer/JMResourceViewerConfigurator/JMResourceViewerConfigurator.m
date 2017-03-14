/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
#import "JMResourceViewerSessionManager.h"

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

- (JMResourceViewerSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [self createSessionManager];
    }
    return _sessionManager;
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

- (JMResourceViewerSessionManager *)createSessionManager
{
    return [JMResourceViewerSessionManager new];
}

- (JMResourceViewerExternalScreenManager *)createExternalScreenManager
{
    return [JMResourceViewerExternalScreenManager new];
}

@end
