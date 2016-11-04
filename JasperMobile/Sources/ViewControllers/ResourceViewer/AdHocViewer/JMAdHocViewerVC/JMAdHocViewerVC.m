/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMAdHocViewerVC.m
//  TIBCO JasperMobile
//

#import "JMAdHocViewerVC.h"
#import "JMAdHocViewerConfigurator.h"
#import "JMAdHocLoader.h"
#import "JMAdHoc.h"
#import "JMWebViewManager.h"
#import "JMWebEnvironment.h"
#import "UIView+Additions.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMJavascriptRequest.h"
#import "JMAdHocViewerStateManager.h"
#import "PopoverView.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerSessionManager.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import "UIAlertController+Additions.h"
#import "JasperMobileAppDelegate.h"
#import "JMAdHocViewerExternalScreenManager.h"

@interface JMAdHocViewerVC() <JMResourceViewerStateManagerDelegate>
@end


@implementation JMAdHocViewerVC
@synthesize resource;

#pragma mark - Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController LifeCycle

- (void)loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"JMBaseResourceView"
                                               owner:self
                                             options:nil] firstObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resource.resourceLookup.label;

    [self.configurator setup];
    [self setupSessionManager];
    [self setupStateManager];
    [self setupExternalScreenManager];

    [self startResourceViewing];
}

#pragma mark - Rotation
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:nil completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [[self stateManager] updatePageForChangingSizeClass];
    }];

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Setups

- (void)setupStateManager
{
    [self stateManager].controller = self;
    [self stateManager].delegate = self;
    [[self stateManager] setupPageForState:JMAdHocViewerState_Initial];
}

- (void)setupSessionManager
{
    self.configurator.sessionManager.controller = self;

    __weak typeof(self) weakSelf = self;
    self.configurator.sessionManager.cleanAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator reset];
    };
    self.configurator.sessionManager.executeAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator setup];
        [strongSelf setupStateManager];

        [strongSelf startResourceViewing];
    };
    self.configurator.sessionManager.exitAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    };
}

- (void)setupExternalScreenManager
{
    [self externalScreenManager].controller = self;
}

#pragma mark - Helpers

- (id<JMAdHocLoader>)adHocLoader
{
    return self.configurator.adHocLoader;
}

- (JMWebEnvironment *)webEnvironment
{
    return self.configurator.webEnvironment;
}

- (JMAdHoc *)adHoc
{
    return [self adHocLoader].adHoc;
}

- (JMAdHocViewerStateManager *)stateManager
{
    return self.configurator.stateManager;
}

- (JMAdHocViewerExternalScreenManager *)externalScreenManager
{
    return self.configurator.externalScreenManager;
}

#pragma mark - JMResourceViewProtocol
- (UIView *)contentView
{
    return [self webEnvironment].webView;
}

#pragma mark - JMResourceViewerStateManagerDelegate

- (void)stateManagerWillExit:(JMResourceViewerStateManager *)stateManager
{
    [self exitAction];
}

- (void)stateManagerWillCancel:(JMResourceViewerStateManager *)stateManager
{
    [self cancelAction];
}

#pragma mark - Actions
- (void)exitAction
{
    [[self adHocLoader] destroy];
    [self.webEnvironment reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [[self adHocLoader] cancel];
    [self.webEnvironment reset];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Resource Viewing methods

- (void)startResourceViewing
{
    JMAdHoc *adHoc = [self.resource modelOfResource];
    [[self stateManager] setupPageForState:JMAdHocViewerState_Loading];
    
    __weak typeof(self)weakSelf = self;
    [[self adHocLoader] runAdHoc:adHoc completion:^(BOOL success, NSError * _Nullable error) {
        __weak typeof(self)strongSelf = weakSelf;
        if (success) {
            [[strongSelf stateManager] setupPageForState:JMAdHocViewerState_ResourceReady];
            // Analytics
            [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                                                                             kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                                                                             kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                                                                             kJMAnalyticsLabelKey    : kJMAnalyticsResourceLabelAdHoc
                                                                             }];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)reloadAdHoc
{
    [[self stateManager] setupPageForState:JMAdHocViewerState_Loading];
    __weak typeof(self)weakSelf = self;
    [[self adHocLoader] reloadWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        if (success) {
            [[strongSelf stateManager] setupPageForState:JMAdHocViewerState_ResourceReady];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

#pragma mark - Overriden methods

- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info | JMMenuActionsViewAction_Refresh | JMMenuActionsViewAction_Share | JMMenuActionsViewAction_Print;

    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate isExternalScreenAvailable]) {
        // TODO: extend by considering other states
        availableAction |= ([self stateManager].state == JMAdHocViewerState_ResourceOnWExternalWindow) ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }

    return availableAction;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [view.popoverView dismiss];

    switch (action) {
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            // TODO: find other solution
            [[self stateManager] updateFavoriteState];
            break;
        case JMMenuActionsViewAction_Info: {
            self.configurator.infoPageManager.controller = self;
            [self.configurator.infoPageManager showInfoPageForResource:self.resource];
            break;
        }
        case JMMenuActionsViewAction_Refresh: {
            [self reloadAdHoc];
            break;
        }
        case JMMenuActionsViewAction_Print: {
            self.configurator.printManager.controller = self;
            UIImage *renderedImage = [[self contentView] renderedImage];
            self.configurator.printManager.prepareBlock = (id)^{
                return renderedImage;
            };
            [self.configurator.printManager printResource:self.resource
                                               completion:nil];
            break;
        }
        case JMMenuActionsViewAction_Share:{
            self.configurator.shareManager.controller = self;
            [self.configurator.shareManager shareContentView:[self contentView]];
            break;
        }
        case JMMenuActionsViewAction_ShowExternalDisplay: {
            [self showOnTV];
            break;
        }
        case JMMenuActionsViewAction_HideExternalDisplay: {
            [self switchFromTV];
            break;
        }
        default:{break;}
    }
}

#pragma mark - JMAdHocLoaderDelegate

- (void)adHocLoader:(id<JMAdHocLoader>)loader didRecieveError:(NSError *)error
{
    [self handleError:error];
}

#pragma mark - Error handling
- (void)handleError:(NSError *)error
{
    [[self stateManager] setupPageForState:JMAdHocViewerState_ResourceFailed];
    switch (error.code) {
        case JMJavascriptRequestErrorTypeAuth: {
            [self.configurator.sessionManager handleSessionDidExpire];
            break;
        }
        case JMJavascriptRequestErrorSessionDidRestore: {
            [self.configurator.sessionManager handleSessionDidChangeWithAlert:YES];
            break;
        }
        case JMJavascriptRequestErrorTypeUnexpected:
        case JMJavascriptRequestErrorTypeWindow:
        case JMJavascriptRequestErrorTypeOther: {
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
            break;
        }
        default:{
            break;
        }
    }
}

#pragma mark - Work with external window
- (void)showOnTV
{
    [[self stateManager] setupPageForState:JMAdHocViewerState_ResourceOnWExternalWindow];
    [[self externalScreenManager] showContentOnTV];
}

- (void)switchFromTV
{
    [[self stateManager] setupPageForState:JMAdHocViewerState_ResourceReady];
    [[self externalScreenManager] backContentOnDevice];
}

@end
