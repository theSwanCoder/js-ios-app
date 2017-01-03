/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMReportViewerStateManager.m
//  TIBCO JasperMobile
//

#import "JMReportViewerStateManager.h"
#import "JMReportViewerVC.h"
#import "JMReportViewerConfigurator.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMResourceViewerMenuHelper.h"
#import "NSObject+Additions.h"

@implementation JMReportViewerStateManager

#pragma mark - Public API

- (void)setupPageForState:(JMResourceViewerState)state
{
    [super setupPageForState:state];
    
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    [self setupToolbarsForState:state];
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
        case JMResourceViewerStateDestroy: {
            break;
        }
        case JMResourceViewerStateMaximizedDashlet: {
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
        case JMResourceViewerStateResourceOnWExternalWindow: {
            break;
        }
        case JMResourceViewerStateNotVisible: {
            if (self.menuHelper.isMenuVisible) {
                [self.menuHelper hideMenu];
            }
            break;
        }
        case JMResourceViewerStateNestedResource: {
            self.needFavoriteButton = NO;
            [self setupNavigationItemsForNestedResource];
            break;
        }
    }
}

- (void)setupMainViewForState:(JMResourceViewerState)state
{
    switch (state) {
        case JMResourceViewerStateInitial: {
            self.controller.title = self.controller.resource.resourceLookup.label;
            [self showResourceNotExistView];
            [self hideProgress];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateDestroy: {
            [self reset];
            break;
        }
        case JMResourceViewerStateMaximizedDashlet: {
            break;
        }
        case JMResourceViewerStateLoading: {
            [self showProgress];
            [self hideResourceNotExistView];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateLoadingForPrint: {
            [self showProgress];
            [self hideResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self showMainView];
            [self hideProgress];
            [self hideResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceOnWExternalWindow: {
            break;
        }
        case JMResourceViewerStateNotVisible: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateNestedResource: {
            [self hideResourceNotExistView];
            [self hideProgress];
            break;
        }
    }
}

- (void)setupToolbarsForState:(JMResourceViewerState)state
{
    switch (state) {
        case JMResourceViewerStateInitial: {
            [self.toolbarsHelper updatePageForToolbarState:JMResourceViewerToolbarStateInitial];
            break;
        }
        case JMResourceViewerStateDestroy: {
            break;
        }
        case JMResourceViewerStateMaximizedDashlet: {
            break;
        }
        case JMResourceViewerStateLoading: {
            break;
        }
        case JMResourceViewerStateLoadingForPrint: {
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            break;
        }
        case JMResourceViewerStateResourceNotExist: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            break;
        }
        case JMResourceViewerStateResourceOnWExternalWindow: {
            break;
        }
        case JMResourceViewerStateNotVisible: {
            break;
        }
        case JMResourceViewerStateNestedResource: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            break;
        }
    }
}

#pragma mark - JMResourceViewerHyperlinksManagerDelegate

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenURL:(NSURL *__nullable)URL
{
    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
    if ([URL.host isEqualToString:serverURL.host]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [((JMReportViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
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
    ((JMReportViewerVC *)self.controller).configurator.stateManager.openDocumentActionBlock = ^{
        __typeof(self) strongSelf = weakSelf;
        ((JMReportViewerVC *)strongSelf.controller).configurator.documentManager.controller = strongSelf.controller;
        [((JMReportViewerVC *)strongSelf.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
    };

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [((JMReportViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
    [self setupPageForState:JMResourceViewerStateNestedResource];
}

- (void)hyperlinksManagerNeedShowLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMResourceViewerStateLoading];
}

- (void)hyperlinksManagerNeedHideLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMResourceViewerStateResourceReady];
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager needShowOpenInMenuForLocalResourceFromURL:(NSURL *__nullable)URL
{
    ((JMReportViewerVC *)self.controller).configurator.documentManager.controller = self.controller;
    [((JMReportViewerVC *)self.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
}

@end
