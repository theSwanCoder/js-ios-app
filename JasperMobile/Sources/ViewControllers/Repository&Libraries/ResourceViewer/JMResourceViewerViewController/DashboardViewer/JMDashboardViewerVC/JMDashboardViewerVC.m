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
//  JMDashboardViewerVC.m
//  TIBCO JasperMobile
//

#import "JMDashboardViewerVC.h"
#import "JMDashboardViewerConfigurator.h"
#import "JMDashboardLoader.h"
#import "JMReportViewerVC.h"
#import "JMDashboard.h"
#import "JMWebViewManager.h"
#import "JMExternalWindowDashboardControlsVC.h"
#import "JMDashboardParameter.h"
#import "JMInputControlsViewController.h"
#import "JMDashboardInputControlsVC.h"
#import "JSRESTBase+JSRESTDashboard.h"
#import "JSDashboardComponent.h"
#import "JMWebEnvironment.h"

#import "UIView+Additions.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMJavascriptNativeBridge.h"


NSString * const kJMDashboardViewerPrimaryWebEnvironmentIdentifier = @"kJMDashboardViewerPrimaryWebEnvironmentIdentifier";
NSString * const kJMDashboardViewerLegacyDashboardsWebEnvironmentIdentifier = @"kJMDashboardViewerLegacyDashboardsWebEnvironmentIdentifier";

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate, JMExternalWindowDashboardControlsVCDelegate>
@property (nonatomic, copy) NSArray *rightButtonItems;

@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
@property (nonatomic) JMExternalWindowDashboardControlsVC *controlsViewController;
@property (nonatomic, weak) UIBarButtonItem *currentBackButton;
@end


@implementation JMDashboardViewerVC

#pragma mark - Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configViewport];
}

#pragma mark - Rotation
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if (![self isContentOnTV] && [self.dashboardLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        // TODO: fix this
//        CGFloat initialScaleViewport = 0.75;
//        BOOL isCompactWidth = newCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
//        if (isCompactWidth) {
//            initialScaleViewport = 0.25;
//        }
//        [self.webEnvironment updateViewportScaleFactorWithValue:initialScaleViewport];
    }
}

#pragma mark - Print
- (void)printResource
{
    [super printResource];
    [self printItem:[self.contentView renderedImage] withName:self.dashboard.resource.resourceLookup.label completion:nil];
}

#pragma mark - Custom Accessors

- (JMDashboard *)dashboard
{
    if (!_dashboard) {
        _dashboard = [self.resource modelOfResource];
    }
    return _dashboard;
}

- (JMWebEnvironment *)currentWebEnvironment
{
    return [[JMWebViewManager sharedInstance] reusableWebEnvironmentWithId:[self currentWebEnvironmentIdentifier]];
}

- (NSString *)currentWebEnvironmentIdentifier
{
    NSString *webEnvironmentIdentifier;
    if (self.dashboard.resource.type != JMResourceTypeLegacyDashboard) {
        webEnvironmentIdentifier = kJMDashboardViewerPrimaryWebEnvironmentIdentifier;
    } else {
        webEnvironmentIdentifier = kJMDashboardViewerLegacyDashboardsWebEnvironmentIdentifier;
    }
    return webEnvironmentIdentifier;
}

- (id<JMDashboardLoader>)dashboardLoader
{
    return [self.configurator dashboardLoader];
}

- (JMDashboardViewerConfigurator *)configurator
{
    if (!_configurator) {
        _configurator = [JMDashboardViewerConfigurator configuratorWithDashboard:self.dashboard
                                                                  webEnvironment:self.webEnvironment];
        [_configurator updateReportLoaderDelegateWithObject:self];
    }
    return _configurator;
}

#pragma mark - Setups
- (void)configViewport
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webEnvironment resetZoom];
    });
}

- (void)setupLeftBarButtonItems
{
    if ([self isDashletShown]) {
        if (!self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                                       target:self
                                                                       action:@selector(minimizeDashlet)];
        }
    } else {
        [super setupLeftBarButtonItems];
    }
}

- (void)setupRightBarButtonItems
{
    if (![self isDashletShown]) {
        [super setupRightBarButtonItems];
    }
}

- (void)resetSubViews
{
    [self.dashboardLoader destroy];
    [self.webEnvironment resetZoom];
    [self.webEnvironment.webView removeFromSuperview];

    self.webEnvironment = nil;
}


- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if ([self isContentOnTV]) {
        [self switchFromTV];
    }
    [super cancelResourceViewingAndExit:exit];
}

#pragma mark - Actions
- (void)minimizeDashlet
{
    [self.webEnvironment resetZoom];

    if ([self isContentOnTV]) {
        [self.controlsViewController markComponentAsMinimized:self.dashboard.maximizedComponent];
    }

    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status_loading"];
    [self.dashboardLoader minimizeDashletWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        if (error) {
            [strongSelf handleError:error];
        } else {
            strongSelf.navigationItem.title = strongSelf.resource.resourceLookup.label;
            [strongSelf setupLeftBarButtonItems];
            strongSelf.navigationItem.rightBarButtonItems = strongSelf.rightButtonItems;
        }
    }];
}

- (void)reloadDashboard
{
    [self startShowLoaderWithMessage:@"status_loading"];
    [self hideDashboardView];
    __weak typeof(self)weakSelf = self;
    [self.dashboardLoader reloadDashboardWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        [strongSelf showDashboardView];
        if (error) {
            [strongSelf handleError:error];
        }
    }];
}

- (void)reloadDashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {

        [self startShowLoaderWithMessage:@"status_loading"];
        __weak typeof(self)weakSelf = self;
        [self.dashboardLoader reloadMaximizedDashletWithCompletion:^(BOOL success, NSError *error){
            __weak typeof(self)strongSelf = weakSelf;
            [strongSelf stopShowLoader];
            if (error) {
                [strongSelf handleError:error];
            }
        }];
    } else {
        [self minimizeDashlet];
        [self reloadDashboard];
    }
}

- (void)backActionInWebView
{
    [self startShowLoaderWithMessage:@"status_loading"];
    __weak typeof(self) weakSelf = self;
    [self.dashboardLoader loadDashboardWithCompletion:^(BOOL success, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        strongSelf.navigationItem.leftBarButtonItem = strongSelf.currentBackButton;
    }];
}

#pragma mark - Overriden methods
- (void)startResourceViewing
{
    [super setupSubviews];
    if (self.resource.type != JMResourceTypeLegacyDashboard && [JMUtils isSupportVisualize]) {
        [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources_loading_msg", nil)
                                   cancelBlock:^(void) {
                                       [self.dashboardLoader cancel];
                                       [super cancelResourceViewingAndExit:YES];
                                   }];

        __weak __typeof(self) weakSelf = self;
        [self fetchDashboardMetaDataWithCompletion:^(NSArray *components, NSArray *inputControls, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf stopShowLoader];

            if (error) {
                [JMUtils presentAlertControllerWithError:error
                                              completion:^{
                                                  [strongSelf cancelResourceViewingAndExit:YES];
                                              }];
            } else {
                strongSelf.dashboard.components = components;
                strongSelf.dashboard.inputControls = inputControls;
                [strongSelf startShowDashboard];
            }
        }];
    } else {
        [self startShowDashboard];
    }
}

- (void)startShowDashboard
{
    [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources_loading_msg", nil)
                               cancelBlock:^(void) {
                                   [self.dashboardLoader cancel];
                                   [super cancelResourceViewingAndExit:YES];
                               }];
    [self hideDashboardView];
    __weak typeof(self)weakSelf = self;
    [self.dashboardLoader loadDashboardWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        [strongSelf showDashboardView];
        if (success) {
            // Analytics
            NSString *label = ([JMUtils isServerProEdition] && [JMUtils isServerVersionUpOrEqual6]) ? kJMAnalyticsResourceLabelDashboardVisualize : kJMAnalyticsResourceLabelDashboardFlow;
            [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                    kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                    kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                    kJMAnalyticsLabelKey    : label
            }];

            if ([strongSelf isContentOnTV]) {
                strongSelf.controlsViewController.components = strongSelf.dashboard.components;
            }
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction menuActions = [super availableAction] | JMMenuActionsViewAction_Refresh;

    if ([self isExternalScreenAvailable]) {
        menuActions |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }

    if ([self isInputControlsAvailable]) {
        menuActions |= JMMenuActionsViewAction_EditFilters;
    }
    return menuActions;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];

    switch (action) {
        case JMMenuActionsViewAction_Refresh: {
            [self reloadDashboard];
            break;
        }
        case JMMenuActionsViewAction_ShowExternalDisplay: {
            [self showExternalWindowWithCompletion:^(BOOL success) {
                if (success) {
                    [self addControlsForExternalWindow];
                } else {
                    // TODO: add handling this situation
                    JMLog(@"error of showing on tv");
                }
            }];
            break;
        }
        case JMMenuActionsViewAction_HideExternalDisplay: {
            [self switchFromTV];
            break;
        }
        case JMMenuActionsViewAction_EditFilters: {
            [self showInputControlsVC];
            break;
        }
        default:{break;}
    }
}

#pragma mark - JMDashboardLoaderDelegate
- (void)dashboardLoaderDidStartMaximizeDashlet:(id<JMDashboardLoader> __nonnull)loader
{
    self.rightButtonItems = self.navigationItem.rightBarButtonItems;
    [self startShowLoaderWithMessage:@"status_loading"];
}

- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didEndMaximazeDashletWithTitle:(NSString * __nonnull)title
{
    [self.webEnvironment resetZoom];

    self.navigationItem.rightBarButtonItems = nil;
    if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {
        UIBarButtonItem *refreshDashlet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_action"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(reloadDashlet)];
        self.navigationItem.rightBarButtonItem = refreshDashlet;
    }

    self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                               target:self
                                                               action:@selector(minimizeDashlet)];
    self.navigationItem.title = title;
    [self stopShowLoader];
}

- (void)dashboardLoader:(id <JMDashboardLoader>)loader didReceiveHyperlinkWithType:(JMHyperlinkType)hyperlinkType
         resource:(JMResource *)resource
             parameters:(NSArray *)parameters
{
    NSLog(@"Parameters = %@", parameters);

    switch (hyperlinkType) {
        case JMHyperlinkTypeLocalPage: {
            break;
        }
        case JMHyperlinkTypeLocalAnchor: {
            break;
        }
        case JMHyperlinkTypeRemotePage: {
            break;
        }
        case JMHyperlinkTypeRemoteAnchor: {
            break;
        }
        case JMHyperlinkTypeReference: {
            NSURL *URL = parameters.firstObject;

            NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
            if ([URL.host isEqualToString:serverURL.host]) {
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                [self.webEnvironment.webView loadRequest:request];

                UIBarButtonItem *backButton = [self backButtonWithTitle:JMCustomLocalizedString(@"back_button_title", nil)
                                                                 target:self
                                                                 action:@selector(backActionInWebView)];
                self.currentBackButton = self.navigationItem.leftBarButtonItem;
                self.navigationItem.leftBarButtonItem = backButton;
            } else {
                // TODO: open in safari view controller
                if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
                    [[UIApplication sharedApplication] openURL:URL];
                }
            }
            break;
        }
        case JMHyperlinkTypeReportExecution: {

            JMReportViewerVC *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
            reportViewController.resource = resource;
            reportViewController.initialReportParameters = parameters;
            reportViewController.isChildReport = YES;
            [self.navigationController pushViewController:reportViewController animated:YES];

            break;
        }
        case JMHyperlinkTypeAdHocExecution: {
            // This case appears for JRS 6.0 - 6.0.1
            // For JRS > 6.1 - in javascript wrapper will be a visualize handler
            NSURL *URL = parameters.firstObject;
            // TODO: open in safari view controller
            if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
            break;
        }
    }
}

- (void)dashboardLoaderDidReceiveAuthRequest:(id <JMDashboardLoader>)loader
{
    if ([self isDashletShown]) {
        [self minimizeDashlet];
    }

    if ([self isContentOnTV]) {
        [self switchFromTV];
    }

    [self handleAuthError];
}

#pragma mark - Helpers
- (BOOL)isDashletShown
{
    return self.dashboard.maximizedComponent != nil;
}

- (void)fetchDashboardMetaDataWithCompletion:(void(^)(NSArray <JSDashboardComponent *> *components, NSArray <JSInputControlDescriptor *> *inputControls, NSError *error))completion
{
    if (!completion) {
        return;
    }

    __weak __typeof(self) weakSelf = self;
    [self.restClient fetchDashboardComponentsWithURI:self.dashboard.resourceURI
                                          completion:^(JSOperationResult *result) {
                                              __typeof(self) strongSelf = weakSelf;

                                              if (result.error) {
                                                  completion(nil, nil, result.error);
                                              } else {
                                                  // Get components
                                                  NSArray <JSDashboardComponent *> *components = result.objects;

                                                  NSMutableArray <JSParameter *> *parameters = [NSMutableArray array];
                                                  for (JSDashboardComponent *component in components) {
                                                      if ([component.type isEqualToString:@"inputControl"]) {
                                                          NSString *URI = component.ownerResourceURI;
                                                          if ([URI hasPrefix:@"/temp"]) {
                                                              NSString *dashboardFilesURI = [NSString stringWithFormat:@"%@_files", strongSelf.dashboard.resourceURI];
                                                              URI = [URI stringByReplacingOccurrencesOfString:@"/temp" withString:dashboardFilesURI];
                                                          }
                                                          NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.name == %@", URI];
                                                          JSParameter *parameter = [[parameters filteredArrayUsingPredicate:filterPredicate] lastObject];
                                                          if (!parameter) {
                                                              parameter = [JSParameter parameterWithName:URI value:[NSMutableArray array]];
                                                              [parameters addObject:parameter];
                                                          }
                                                          [parameter.value addObject:component.ownerResourceParameterName];
                                                      }
                                                  }

                                                  JMLog(@"inputControlsURLs: %@", parameters);
                                                  // Get input controls
                                                  [strongSelf.restClient inputControlsForDashboardWithParameters:parameters
                                                                                                 completionBlock:^(JSOperationResult * _Nullable result) {
                                                                                                     if (result.error) {
                                                                                                         JMLog(@"error: %@", result.error);
                                                                                                     } else {
                                                                                                         NSArray *inputControls = result.objects;
                                                                                                         // Callback
                                                                                                         if (inputControls.count > 0) {
                                                                                                             NSMutableArray *visibleInputControls = [NSMutableArray array];
                                                                                                             for (JSInputControlDescriptor *inputControl in inputControls) {
                                                                                                                 if (inputControl.visible.boolValue) {
                                                                                                                     [visibleInputControls addObject:inputControl];
                                                                                                                 }
                                                                                                             }
                                                                                                             completion(components, visibleInputControls, nil);
                                                                                                         } else {
                                                                                                             completion(components, @[], nil);
                                                                                                         }
                                                                                                     }
                                                                                                 }];
                                              }
                                          }];
}

- (BOOL)isInputControlsAvailable
{
    return self.dashboard.inputControls.count > 0;
}

- (void)hideDashboardView
{
    [self contentView].hidden = YES;
}

- (void)showDashboardView
{
    [self contentView].hidden = NO;
}

#pragma mark - Error handling
- (void)handleError:(NSError *)error
{
    switch (error.code) {
        case JMJavascriptNativeBridgeErrorAuthError: {
            if ([self isDashletShown]) {
                self.dashboard.maximizedComponent = nil;
                self.navigationItem.title = self.resource.resourceLookup.label;
                [self setupLeftBarButtonItems];
                self.navigationItem.rightBarButtonItems = self.rightButtonItems;
                self.rightButtonItems = nil;
            }
            [self handleAuthError];
            break;
        }
        case JMJavascriptNativeBridgeErrorTypeUnexpected:
        case JMJavascriptNativeBridgeErrorTypeWindow:
        case JMJavascriptNativeBridgeErrorTypeOther: {
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
            break;
        }
        default:{
            break;
        }
    }
}

- (void)handleAuthError
{
    if ([self isContentOnTV]) {
        [self switchFromTV];
    }

    if (self.restClient.keepSession) {
        __weak typeof(self)weakSelf = self;
        [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult *_Nullable result) {
            __weak typeof(self)strongSelf = weakSelf;
            if (!result.error) {
                if (strongSelf.dashboard.resource.type == JMResourceTypeLegacyDashboard) {
                    // reset state
                    [strongSelf.webEnvironment reset];
                    strongSelf.webEnvironment = nil;
                    strongSelf.dashboard = nil;
                    strongSelf.configurator = nil;
                }
                [strongSelf showSessionExpiredAlert];
            } else {
                __weak typeof(self)weakSelf = strongSelf;
                [JMUtils showLoginViewAnimated:YES completion:^{
                    __weak typeof(self)strongSelf = weakSelf;
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            }
        }];
    } else {
        __weak typeof(self)weakSelf = self;
        [JMUtils showLoginViewAnimated:YES completion:^{
            __weak typeof(self)strongSelf = weakSelf;
            [strongSelf cancelResourceViewingAndExit:YES];
        }];
    }
}

- (void)showSessionExpiredAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Session was expired"
                                                                                      message:@"Reload?"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          [self cancelResourceViewingAndExit:YES];
                                                                      }];
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog_button_reload"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             [strongSelf startResourceViewing];
                                         }];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Work with external screen
- (UIView *)viewToShowOnExternalWindow
{
    UIView *dashboardView = self.webEnvironment.webView;
    dashboardView.translatesAutoresizingMaskIntoConstraints = YES;
    return dashboardView;
}

- (void)addControlsForExternalWindow
{
    self.controlsViewController = [JMExternalWindowDashboardControlsVC new];
    self.controlsViewController.components = self.dashboard.components;
    [self.view addSubview:self.controlsViewController.view];

    self.controlsViewController.delegate = self;

    self.controlsViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controlsView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"controlsView": self.controlsViewController.view}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[controlsView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"controlsView": self.controlsViewController.view}]];


}

- (void)switchFromTV
{
    [super setupSubviews];

    [self.controlsViewController.view removeFromSuperview];
    self.controlsViewController = nil;

    [self hideExternalWindowWithCompletion:^(void) {
        [self configViewport];
        [self.webEnvironment.webView.scrollView setZoomScale:0.1 animated:YES];
    }];
}

#pragma mark - JMExternalWindowDashboardControlsVCDelegate
- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMaximizeDashlet:(JSDashboardComponent *)component
{
    if ([self.dashboardLoader respondsToSelector:@selector(maximizeDashletForComponent:completion:)]) {
        __weak __typeof(self) weakSelf = self;
        [self.dashboardLoader maximizeDashletForComponent:component completion:^(BOOL success, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                // TODO: move to separate method
                strongSelf.navigationItem.rightBarButtonItems = nil;
                if ([strongSelf.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {
                    UIBarButtonItem *refreshDashlet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_action"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:strongSelf
                                                                                      action:@selector(reloadDashlet)];
                    strongSelf.navigationItem.rightBarButtonItem = refreshDashlet;
                }

                strongSelf.navigationItem.leftBarButtonItem = [strongSelf backButtonWithTitle:strongSelf.title
                                                                                       target:strongSelf
                                                                                       action:@selector(minimizeDashlet)];
                strongSelf.navigationItem.title = component.name;
            }
        }];
    }
}

- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMinimizeDashlet:(JSDashboardComponent *)component
{
    if ([self.dashboardLoader respondsToSelector:@selector(minimizeDashletForComponent:completion:)]) {
        __weak __typeof(self) weakSelf = self;
        [self.dashboardLoader minimizeDashletForComponent:component completion:^(BOOL success, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                // TODO: move to separate method
                strongSelf.navigationItem.title = strongSelf.resource.resourceLookup.label;
                [strongSelf setupLeftBarButtonItems];
                strongSelf.navigationItem.rightBarButtonItems = strongSelf.rightButtonItems;
                strongSelf.rightButtonItems = nil;
            }
        }];
    }
}

#pragma mark - Input Controls
- (void)showInputControlsVC
{
    JMDashboardInputControlsVC *inputControlsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMDashboardInputControlsVC"];
    inputControlsViewController.dashboard = self.dashboard;

    __weak __typeof(self) weakSelf = self;
    inputControlsViewController.exitBlock = ^(BOOL inputControlsDidChanged) {
        if (inputControlsDidChanged) {
            __typeof(self) strongSelf = weakSelf;
            NSMutableDictionary *parameters = [@{} mutableCopy];
            for (JSInputControlDescriptor *inputControlDescriptor in strongSelf.dashboard.inputControls) {
                NSString *componentID;
                for (JSDashboardComponent *component in strongSelf.dashboard.components) {
                    if ([component.ownerResourceParameterName isEqualToString:inputControlDescriptor.uuid]) {
                        componentID = component.identifier;
                    }
                }
                NSArray *values = [inputControlDescriptor selectedValues];
                if (componentID) {
                    parameters[componentID] = values;                    
                }
            }
            [self startShowLoaderWithMessage:@"status_loading"];
            __weak __typeof(self) weakSelf = self;
            [strongSelf.dashboardLoader applyParameters:parameters completion:^(BOOL success, NSError *error) {
                __typeof(self) strongSelf = weakSelf;
                [strongSelf stopShowLoader];
                if (error) {
                    [strongSelf handleError:error];
                }
            }];
        }
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

@end