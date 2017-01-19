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
//  JMContentResourceViewerStateManager.m
//  TIBCO JasperMobile
//


#import "JMContentResourceViewerStateManager.h"
#import "JMContentResourceViewerVC.h"
#import "JMResource.h"
#import "JMResourceViewerMenuHelper.h"


@implementation JMContentResourceViewerStateManager
#pragma mark - Public API

- (void)setupPageForState:(JMResourceViewerState)state
{
    [super setupPageForState:state];
    
    [self setupNavigationItemForState:state];
    [self setupMainViewForState:state];
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
        case JMResourceViewerStateResourceReady: {
            [self setupNavigationItems];
            break;
        }
        case JMResourceViewerStateDestroy:
        case JMResourceViewerStateMaximizedDashlet:
        case JMResourceViewerStateLoading:
        case JMResourceViewerStateLoadingForPrint:
        case JMResourceViewerStateResourceFailed:
        case JMResourceViewerStateResourceNotExist:
        case JMResourceViewerStateNotVisible:
        case JMResourceViewerStateNestedResource:
        case JMResourceViewerStateResourceOnWExternalWindow: {
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
        case JMResourceViewerStateLoading: {
            [self showProgress];
            [self hideResourceNotExistView];
            [self hideMainView];
            break;
        }
        case JMResourceViewerStateResourceReady: {
            [self showMainView];
            [self hideProgress];
            [self hideResourceNotExistView];
            break;
        }
        case JMResourceViewerStateResourceFailed: {
            [self hideProgress];
            break;
        }
        case JMResourceViewerStateDestroy: {
            [self reset];
            break;
        }
        case JMResourceViewerStateMaximizedDashlet:
        case JMResourceViewerStateLoadingForPrint:
        case JMResourceViewerStateResourceNotExist:
        case JMResourceViewerStateResourceOnWExternalWindow:
        case JMResourceViewerStateNotVisible:
        case JMResourceViewerStateNestedResource: {
            break;
        }
    }
}

@end
