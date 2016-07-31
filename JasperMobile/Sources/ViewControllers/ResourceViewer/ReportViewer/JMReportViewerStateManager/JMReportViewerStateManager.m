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

@interface JMReportViewerStateManager()
@property (nonatomic, assign, readwrite) JMReportViewerState state;
@end

@implementation JMReportViewerStateManager

#pragma mark - Public API

- (void)setupPageForState:(JMReportViewerState)state
{
    self.state = state;
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    [self setupToolbarsForState:state];
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMReportViewerState)state
{
    self.needFavoriteButton = YES;
    switch (state) {
        case JMReportViewerStateInitial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMReportViewerStateDestroy: {
            break;
        }
        case JMReportViewerStateLoading: {
            break;
        }
        case JMReportViewerStateResourceFailed: {
            break;
        }
        case JMReportViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMReportViewerStateResourceNotExist: {
            break;
        }
        case JMReportViewerStateNotVisible: {
            if (self.menuHelper.isMenuVisible) {
                [self.menuHelper hideMenu];
            }
            break;
        }
        case JMReportViewerStateNestedResource: {
            self.needFavoriteButton = NO;
            [self setupNavigationItemsForNestedResource];
            break;
        }
    }
}

- (void)setupMainViewForState:(JMReportViewerState)state
{
    switch (state) {
        case JMReportViewerStateInitial: {
            self.controller.title = self.controller.resource.resourceLookup.label;
            [self showResourceNotExistView];
            [self hideProgress];
            [self hideMainView];
            break;
        }
        case JMReportViewerStateDestroy: {
            [self reset];
            break;
        }
        case JMReportViewerStateLoading: {
            [self showProgress];
            [self hideResourceNotExistView];
            [self hideMainView];
            break;
        }
        case JMReportViewerStateResourceFailed: {
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMReportViewerStateResourceReady: {
            [self showMainView];
            [self hideProgress];
            [self hideResourceNotExistView];
            break;
        }
        case JMReportViewerStateResourceNotExist: {
            [self hideProgress];
            [self showResourceNotExistView];
            break;
        }
        case JMReportViewerStateNotVisible: {
            [self hideProgress];
            break;
        }
        case JMReportViewerStateNestedResource: {
            [self hideResourceNotExistView];
            [self hideProgress];
            break;
        }
    }
}

- (void)setupToolbarsForState:(JMReportViewerState)state
{
    switch (state) {
        case JMReportViewerStateInitial: {
            [self.toolbarsHelper updatePageForToolbarState:JMResourceViewerToolbarStateInitial];
            break;
        }
        case JMReportViewerStateDestroy: {
            break;
        }
        case JMReportViewerStateLoading: {
            break;
        }
        case JMReportViewerStateResourceFailed: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            break;
        }
        case JMReportViewerStateResourceReady: {
            break;
        }
        case JMReportViewerStateResourceNotExist: {
            [self updatePageForToolbarState:JMResourceViewerToolbarStateBottomHidden];
            [self updatePageForToolbarState:JMResourceViewerToolbarStateTopHidden];
            break;
        }
        case JMReportViewerStateNotVisible: {
            break;
        }
        case JMReportViewerStateNestedResource: {
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
        [self setupPageForState:JMReportViewerStateNestedResource];
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
        ((JMReportViewerVC *)strongSelf.controller).configurator.documentManager.controller = weakSelf.controller;
        [((JMReportViewerVC *)strongSelf.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
    };

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [((JMReportViewerVC *)self.controller).configurator.webEnvironment.webView loadRequest:request];
    [self setupPageForState:JMReportViewerStateNestedResource];
}

- (void)hyperlinksManagerNeedShowLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMReportViewerStateLoading];
}

- (void)hyperlinksManagerNeedHideLoading:(JMResourceViewerHyperlinksManager *__nullable)manager
{
    [self setupPageForState:JMReportViewerStateResourceReady];
}

- (void)hyperlinksManager:(JMResourceViewerHyperlinksManager *__nullable)manager needShowOpenInMenuForLocalResourceFromURL:(NSURL *__nullable)URL
{
    ((JMReportViewerVC *)self.controller).configurator.documentManager.controller = self.controller;
    [((JMReportViewerVC *)self.controller).configurator.documentManager showOpenInMenuForResourceWithURL:URL];
}

@end