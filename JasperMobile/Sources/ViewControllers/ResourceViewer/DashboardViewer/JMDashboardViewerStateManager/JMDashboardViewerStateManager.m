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
//  JMDashboardViewerStateManager.m
//  TIBCO JasperMobile
//

#import "JMDashboardViewerStateManager.h"
#import "JMDashboardViewerVC.h"
#import "JMFavorites+Helpers.h"
#import "JMResourceViewerFavoritesHelper.h"
#import "JMBaseResourceView.h"
#import "UIView+Additions.h"

@interface JMDashboardViewerStateManager()
@property (nonatomic, assign, readwrite) JMDashboardViewerState state;
@end

@implementation JMDashboardViewerStateManager

#pragma mark - Public API

- (void)setupPageForState:(JMDashboardViewerState)state
{
    self.state = state;
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    switch(state) {
        case JMDashboardViewerStateInitial: {
            [self.toolbarsHelper updatePageForToolbarState:JMResourceViewerToolbarStateInitial];
        }
        default: {
            break;
        }
    }
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMDashboardViewerState)state
{
    switch (state) {
        case JMDashboardViewerStateInitial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMDashboardViewerStateLoading: {
            break;
        }
        case JMDashboardViewerStateResourceFailed: {
            break;
        }
        case JMDashboardViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMDashboardViewerStateResourceNotExist: {
            break;
        }
        case JMDashboardViewerStateDashletActive: {
            break;
        }
        case JMDashboardViewerStateNestedResource: {
            [self setupNavigationItemsForNestedResource];
            break;
        }
        case JMDashboardViewerStateDestroy: {
            break;
        }
    }
}

- (void)setupMainViewForState:(JMDashboardViewerState)state
{
    [self hideResourceNotExistView];
    switch (state) {
        case JMDashboardViewerStateInitial: {
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMDashboardViewerStateLoading: {
            [self showProgress];
            [self hideMainView];
            break;
        }
        case JMDashboardViewerStateResourceFailed: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMDashboardViewerStateResourceReady: {
            [self hideProgress];
            [self showMainView];
            break;
        }
        case JMDashboardViewerStateResourceNotExist: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self showResourceNotExistView];
            break;
        }
        case JMDashboardViewerStateDashletActive: {
            break;
        }
        case JMDashboardViewerStateNestedResource: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            break;
        }
        case JMDashboardViewerStateDestroy: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            [self hideProgress];
            break;
        }
    }
}

#pragma mark - JMResourceViewerHyperlinksManagerDelegate

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenURL:(NSURL *__nullable)URL
{
//    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
//    if ([URL.host isEqualToString:serverURL.host]) {
//        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//        [((JMDashboardViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
//        [self setupPageForState:JMDashboardViewerStateNestedResource];
//    } else {
//        if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
//            [[UIApplication sharedApplication] openURL:URL];
//        }
//    }
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager willOpenLocalResourceFromURL:(NSURL *__nullable)URL
{
//    __weak __typeof(self) weakSelf = self;
//    ((JMDashboardViewerVC *)self.controller).configurator.stateManager.openDocumentActionBlock = ^{
//        __typeof(self) strongSelf = weakSelf;
//        ((JMDashboardViewerVC *)strongSelf.controller).configurator.documentManager.controller = weakSelf.controller;
//        [((JMDashboardViewerVC *)strongSelf.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
//    };
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    [((JMDashboardViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
//    [self setupPageForState:JMDashboardViewerStateNestedResource];
}

- (void)hyperlinksManagerNeedShowLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMDashboardViewerStateLoading];
}

- (void)hyperlinksManagerNeedHideLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMDashboardViewerStateResourceReady];
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager needShowOpenInMenuForLocalResourceFromURL:(NSURL *__nullable)URL
{
//    ((JMDashboardViewerVC *)self.controller).configurator.documentManager.controller = self.controller;
//    [((JMDashboardViewerVC *)self.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
}

@end