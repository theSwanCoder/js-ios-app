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
//  JMResourceViewerMenuHelper.m
//  TIBCO JasperMobile
//

#import "JMResourceViewerMenuHelper.h"
#import "PopoverView.h"
#import "JMMenuActionsView.h"

@interface JMResourceViewerMenuHelper() <PopoverViewDelegate>
@property (nonatomic, weak) PopoverView *popoverView;
@end

@implementation JMResourceViewerMenuHelper

#pragma mark - Custom Accessors

- (BOOL)isMenuVisible
{
    return self.popoverView != nil;
}

#pragma mark - Public API

- (void)showMenuWithAvailableActions:(JMMenuActionsViewAction)availableActions disabledActions:(JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self.controller;
    [actionsView setAvailableActions:availableActions
                     disabledActions:disabledActions];
    CGPoint point = CGPointMake(CGRectGetWidth(self.controller.view.frame), -10);

    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.controller.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
    actionsView.popoverView = self.popoverView;
}

- (void)hideMenu
{
    [self.popoverView dismiss:NO];
}

#pragma mark - PopoverViewDelegate

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

@end