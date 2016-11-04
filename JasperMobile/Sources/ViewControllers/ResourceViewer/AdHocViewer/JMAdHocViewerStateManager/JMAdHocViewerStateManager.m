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
//  JMAdHocViewerStateManager.m
//  TIBCO JasperMobile
//

#import "JMAdHocViewerStateManager.h"
#import "JMAdHocViewerVC.h"
#import "JMFavorites+Helpers.h"
#import "JMResourceViewerFavoritesHelper.h"
#import "JMBaseResourceView.h"
#import "UIView+Additions.h"
#import "JMResource.h"
#import "JMAdHocViewerConfigurator.h"
#import "JMWebEnvironment.h"
#import "JMResourceViewerDocumentManager.h"
#import "JMUtils.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"

@interface JMAdHocViewerStateManager()
@property (nonatomic, assign, readwrite) JMAdHocViewerState state;
@end

@implementation JMAdHocViewerStateManager

#pragma mark - Public API

- (void)setupPageForState:(JMAdHocViewerState)state
{
    self.state = state;
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
    switch(state) {
        case JMAdHocViewerState_Initial: {
            [self.toolbarsHelper updatePageForToolbarState:JMResourceViewerToolbarStateInitial];
        }
        default: {
            break;
        }
    }
}

#pragma mark - Helpers

- (void)setupNavigationItemForState:(JMAdHocViewerState)state
{
    self.needFavoriteButton = YES;
    switch (state) {
        case JMAdHocViewerState_Initial: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMAdHocViewerState_Loading: {
            break;
        }
        case JMAdHocViewerState_ResourceFailed: {
            break;
        }
        case JMAdHocViewerState_ResourceReady: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMAdHocViewerState_ResourceNotExist: {
            break;
        }
        case JMAdHocViewerState_ResourceOnWExternalWindow: {
            [self initialSetupNavigationItems];
            break;
        }
        case JMAdHocViewerState_Destroy: {
            break;
        }
    }
}

- (void)setupMainViewForState:(JMAdHocViewerState)state
{
    switch (state) {
        case JMAdHocViewerState_Initial: {
            self.controller.title = self.controller.resource.resourceLookup.label;
            [self hideProgress];
            break;
        }
        case JMAdHocViewerState_Loading: {
            [self showProgress];
            [self hideMainView];
            break;
        }
        case JMAdHocViewerState_ResourceFailed: {
            [self hideProgress];
            break;
        }
        case JMAdHocViewerState_ResourceReady: {
            [self hideProgress];
            [self showMainView];
            break;
        }
        case JMAdHocViewerState_ResourceNotExist: {
            break;
        }
        case JMAdHocViewerState_ResourceOnWExternalWindow: {
            break;
        }
        case JMAdHocViewerState_Destroy: {
            [self hideProgress];
            break;
        }
    }
}

@end
