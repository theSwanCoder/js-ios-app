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
//  JMResourceViewerToolbarsHelper.h
//  TIBCO JasperMobile
//

#import "JMResourceViewerToolbarsHelper.h"
#import "JMBaseResourceView.h"

@interface JMResourceViewerToolbarsHelper()
@property (nonatomic, assign, readwrite) JMResourceViewerToolbarState state;
@end

@implementation JMResourceViewerToolbarsHelper

#pragma mark - Public API

- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState
{
    switch(toolbarState) {
        case JMResourceViewerToolbarStateInitial: {
            [self hideTopToolbarAnimated:NO];
            [self hideBottomToolbarAnimated:NO];
            break;
        }
        case JMResourceViewerToolbarStateTopVisible: {
            [self showTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateTopHidden: {
            [self hideTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomVisible: {
            [self showBottomToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomHidden: {
            [self hideBottomToolbarAnimated:YES];
            break;
        }
    }
}

#pragma mark - Setup Toolbars

- (void)showTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:YES animated:animated];
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:NO animated:animated];
}

- (void)showBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:YES animated:animated];
}

- (void)hideBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:NO animated:animated];
}

#pragma mark - Toolbar Helpers
- (void)setTopToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    self.view.topViewTopConstraint.constant = visible ? 0 : - CGRectGetHeight(self.view.topView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

- (void)setBottomToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    self.view.bottomViewBottomConstraint.constant = visible ? 0 : -CGRectGetHeight(self.view.bottomView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

@end