/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboardViewerStateManager.h"
#import "JMDashboardViewerVC.h"
#import "JMFavorites+Helpers.h"
#import "JMResourceViewerFavoritesHelper.h"
#import "JMBaseResourceView.h"
#import "UIView+Additions.h"
#import "JMResource.h"
#import "JMDashboardViewerConfigurator.h"
#import "JMWebEnvironment.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"

@implementation JMDashboardViewerStateManager

#pragma mark - Public API

- (void)setupPageForState:(JMResourceViewerState)state
{
    [super setupPageForState:state];
    
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    switch(state) {
        case JMResourceViewerStateInitial: {
            [self.toolbarsHelper updatePageForToolbarState:JMResourceViewerToolbarStateInitial];
        }
        default: {
            break;
        }
    }
}

#pragma mark - Actions

- (void)minimizeDashletAction
{
    if (self.minimizeDashletActionBlock) {
        self.minimizeDashletActionBlock();
    }
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMResourceViewerState)state
{
    self.needFavoriteButton = YES;
    switch (state) {
        case JMResourceViewerStateInitial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMResourceViewerStateLoading: {
            break;
        }
        case JMResourceViewerStateLoadingForPrint: {
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            break;
        }
        case JMResourceViewerStateMaximizedDashlet: {
            [self setupNavigationItemsForMaximizedDashlet];
            break;
        }
        case JMResourceViewerStateNestedResource: {
            self.needFavoriteButton = NO;
            [self setupNavigationItemsForNestedResource];
            break;
        }
        case JMResourceViewerStateResourceOnWExternalWindow: {
            [self setupNavigationItems];
            break;
        }
        case JMResourceViewerStateDestroy: {
            break;
        }
        case JMResourceViewerStateNotVisible: {
            break;
        }
    }
}

- (void)setupMainViewForState:(JMResourceViewerState)state
{
    switch (state) {
        case JMResourceViewerStateInitial: {
            self.controller.title = self.controller.resource.resourceLookup.label;
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateLoading: {
            [self showProgress];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateLoadingForPrint: {
            [self showProgress];
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self hideProgress];
            [self showMainView];
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            break;
        }
        case JMResourceViewerStateMaximizedDashlet: {
            [self hideProgress];
            [self showMainView];
            break;
        }
        case JMResourceViewerStateNestedResource: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateResourceOnWExternalWindow: {
            break;
        }
        case JMResourceViewerStateDestroy: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateNotVisible: {
            break;
        }
    }
}

- (void)setupNavigationItems
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if ([self isNavigationItemsForMaximizedDashlet]) {
        [self initialSetupNavigationItems];
    }
}

#pragma mark - JMResourceViewerHyperlinksManagerDelegate

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenURL:(NSURL *__nullable)URL
{
    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
    if ([URL.host isEqualToString:serverURL.host]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [((JMDashboardViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
        [self setupPageForState:JMResourceViewerStateNestedResource];
    } else {
        if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenLocalResourceFromURL:(NSURL *__nullable)URL
{
    __weak __typeof(self) weakSelf = self;
    ((JMDashboardViewerVC *)self.controller).configurator.stateManager.openDocumentActionBlock = ^{
        __typeof(self) strongSelf = weakSelf;
        ((JMDashboardViewerVC *)strongSelf.controller).configurator.documentManager.controller = strongSelf.controller;
        [((JMDashboardViewerVC *)strongSelf.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
    };

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [((JMDashboardViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
    [self setupPageForState:JMResourceViewerStateNestedResource];
}

- (void)hyperlinksManagerNeedShowLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMResourceViewerStateLoading];
}

- (void)hyperlinksManagerNeedHideLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    // TODO: investigate, does it posible navigate to hyperlink not from dashlet?
    [self setupPageForState:JMResourceViewerStateMaximizedDashlet];
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager needShowOpenInMenuForLocalResourceFromURL:(NSURL *__nullable)URL
{
    ((JMDashboardViewerVC *)self.controller).configurator.documentManager.controller = self.controller;
    [((JMDashboardViewerVC *)self.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
}

#pragma mark - Helpers
- (void)setupNavigationItemsForMaximizedDashlet
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self setupBackButtonForMaximizedDashlet];
    [self removeMenuBarButton];
    [self.favoritesHelper removeFavoriteBarButton];

//    if (self.openDocumentActionBlock) {
//        [self setupOpenDocumentBarButton];
//    }
}

- (void)setupBackButtonForMaximizedDashlet
{
    UIBarButtonItem *backBarButton = [self backBarButtonForMaximizedDashlet];
    self.controller.navigationItem.leftBarButtonItem = backBarButton;
}

- (UIBarButtonItem *)backBarButtonForMaximizedDashlet
{
    UIBarButtonItem *item = [self backBarButtonWithTitle:JMLocalizedString(@"back_button_title")
                                                  action:@selector(minimizeDashletAction)];
    return item;
}

- (BOOL)isNavigationItemsForMaximizedDashlet
{
    BOOL isNavigationItemsForNestedResource = NO;

    // TODO: extend this logic
    BOOL isBackButtonForNestedResource = [self isBackButtonForMaximizedDashlet];
    if (isBackButtonForNestedResource) {
        isNavigationItemsForNestedResource = YES;
    }

    return isNavigationItemsForNestedResource;
}

- (BOOL)isBackButtonForMaximizedDashlet
{
    BOOL isBackButtonForMaximizedDashlet = NO;
    if (self.controller.navigationItem.leftBarButtonItem.action == @selector(minimizeDashletAction)) {
        isBackButtonForMaximizedDashlet = YES;
    }
    return isBackButtonForMaximizedDashlet;
}

@end
