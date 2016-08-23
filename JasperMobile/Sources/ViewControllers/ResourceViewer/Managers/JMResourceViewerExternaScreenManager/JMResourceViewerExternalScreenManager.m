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
//  JMResourceViewerExternalScreenManager.m
//  TIBCO JasperMobile
//

#import "JMResourceViewerExternalScreenManager.h"
#import "JasperMobileAppDelegate.h"
#import "JMUtils.h"
#import "JMBaseResourceView.h"
#import "UIView+Additions.h"


@implementation JMResourceViewerExternalScreenManager

#pragma mark - Life Cycle

- (void)dealloc
{
    if ([self externalScreenWindow].subviews.count > 0) {
        UIView *contentView = [self externalScreenWindow].subviews.firstObject;
        [contentView removeFromSuperview];
        [self externalScreenWindow].backgroundColor = [UIColor blackColor];
    }
    [self removeObservers];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(externalScreenWindowWillBeDestroy:)
                                                     name:JMAppDelegateWillDestroyExternalWindowNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Public API

- (void)showContentOnTV
{
    [self showResourceViewOnTV];
}

- (void)backContentOnDevice
{
    [self removeResourceViewFromTV];
}

- (JMBaseResourceView *)resourceView
{
    return nil;
}

- (UIWindow *)externalScreenWindow
{
    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *externalScreenWindow = appDelegate.externalWindow;
    return externalScreenWindow;
}

- (void)handleExternalScreenWillBeDestroy
{
    //  override in childs if need
}

- (void)handleContentIsOnExternalScreen
{
    //  override in childs if need
}

- (void)handleContentIsOnDevice
{
    //  override in childs if need
}

#pragma mark - Helpers

- (void)showResourceViewOnTV
{
    JMBaseResourceView *resourceView = [self resourceView];
    NSAssert(resourceView != nil, @"Resource View doesnt set");
    UIView *contentView = resourceView.contentView;
    [self addObserverForContentViewDidAddToExternalWindow:contentView];
    [contentView removeFromSuperview];
}

- (void)removeResourceViewFromTV
{
    UIView *contentView = [self externalScreenWindow].subviews.firstObject;
    [self addObserverForContentViewDidAddToReportView:contentView];
    [contentView removeFromSuperview];
}

#pragma mark - Notifications

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)externalScreenWindowWillBeDestroy:(NSNotification *)notification
{
    [self handleExternalScreenWillBeDestroy];
}

#pragma mark - Notification Content View move into external window

- (void)addObserverForContentViewDidAddToExternalWindow:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentViewDidAddToExternalWindow:)
                                                 name:JMResourceContentViewDidMoveToSuperViewNotification
                                               object:contentView];
}

- (void)removeObserverForContentViewDidAddToExternalWindow:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JMResourceContentViewDidMoveToSuperViewNotification
                                                  object:contentView];
}

- (void)contentViewDidAddToExternalWindow:(NSNotification *)notification
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIView *contentView = notification.object;
    [self removeObserverForContentViewDidAddToExternalWindow:contentView];
    [[self externalScreenWindow] fillWithView:contentView];
    [self addObserverForContentViewDidLayoutInExternalWindow:contentView];
}

- (void)addObserverForContentViewDidLayoutInExternalWindow:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentViewDidLayoutInExternalWindow:)
                                                 name:JMResourceContentViewDidLayoutSubviewsNotification
                                               object:contentView];
}

- (void)removeObserverForContentViewDidLayoutInExternalWindow:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JMResourceContentViewDidLayoutSubviewsNotification
                                                  object:contentView];
}

- (void)contentViewDidLayoutInExternalWindow:(NSNotification *)notification
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIView *contentView = notification.object;
    [self removeObserverForContentViewDidLayoutInExternalWindow:contentView];

    // TODO: find other solution
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JMLog(@"Show external window");
        [self externalScreenWindow].backgroundColor = [UIColor whiteColor];
        [self externalScreenWindow].hidden = NO;
        [self handleContentIsOnExternalScreen];
    });
}

#pragma mark - Notification Content View move into report viewer

- (void)addObserverForContentViewDidAddToReportView:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentViewDidAddToReportView:)
                                                 name:JMResourceContentViewDidMoveToSuperViewNotification
                                               object:contentView];
}

- (void)removeObserverForContentViewDidAddToReportView:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JMResourceContentViewDidMoveToSuperViewNotification
                                                  object:contentView];
}

- (void)contentViewDidAddToReportView:(NSNotification *)notification
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIView *contentView = notification.object;
    [self removeObserverForContentViewDidAddToReportView:contentView];
    JMBaseResourceView *resourceView = [self resourceView];
    NSAssert(resourceView != nil, @"Resource View doesnt set");
    [resourceView.container fillWithView:contentView];
    [self addObserverForContentViewDidLayoutInReportView:contentView];
}

- (void)addObserverForContentViewDidLayoutInReportView:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentViewDidLayoutInReportView:)
                                                 name:JMResourceContentViewDidLayoutSubviewsNotification
                                               object:contentView];
}

- (void)removeObserverForContentViewDidLayoutInReportView:(UIView *)contentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JMResourceContentViewDidLayoutSubviewsNotification
                                                  object:contentView];
}

- (void)contentViewDidLayoutInReportView:(NSNotification *)notification
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    UIView *contentView = notification.object;
    [self removeObserverForContentViewDidLayoutInReportView:contentView];

    // TODO: find other solution
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JMLog(@"Hide external window");
        [self externalScreenWindow].hidden = YES;
        [self externalScreenWindow].backgroundColor = [UIColor blackColor];
        [self handleContentIsOnDevice];
    });
}

@end
