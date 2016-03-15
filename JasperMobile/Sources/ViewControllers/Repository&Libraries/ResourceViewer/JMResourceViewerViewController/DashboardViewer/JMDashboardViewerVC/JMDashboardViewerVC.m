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
#import "JSResourceLookup+Helpers.h"
#import "JMDashboardLoader.h"
#import "JMReportViewerVC.h"
#import "JMDashboard.h"
#import "JMWebViewManager.h"
#import "JMExternalWindowDashboardControlsVC.h"
#import "JMDashlet.h"
#import "JMDashboardParameter.h"
#import "JSResourceDashboardUnit.h"
#import "JSDashboardResource.h"
#import "JMInputControlsViewController.h"
#import "JMDashboardInputControlsVC.h"
#import "JSRESTBase+JSRESTDashboard.h"
#import "JSDashboardComponent.h"
#import "JMWebEnvironment.h"

NSString * const kJMDashboardViewerPrimaryWebEnvironmentIdentifier = @"kJMDashboardViewerPrimaryWebEnvironmentIdentifier";

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate, JMExternalWindowDashboardControlsVCDelegate>
@property (nonatomic, copy) NSArray *rightButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftButtonItem;

@property (nonatomic, strong, readwrite) JMDashboard *dashboard;
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
@property (nonatomic) JMExternalWindowDashboardControlsVC *controlsViewController;
@property (nonatomic, strong) JMWebEnvironment *webEnvironment;
@end


@implementation JMDashboardViewerVC

#pragma mark - UIViewController LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configViewport];
}

#pragma mark - Print
- (void)printResource
{
    [super printResource];

    [self imageFromWebViewWithCompletion:^(UIImage *image) {
        if (image) {
            [self printItem:image
                   withName:self.dashboard.resourceLookup.label
                 completion:nil];
        }
    }];
}

- (void)imageFromWebViewWithCompletion:(void(^)(UIImage *image))completion
{
    [JMCancelRequestPopup presentWithMessage:@"status.loading"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Screenshot rendering from webView
        UIView *resourceView = [self resourceView];
        UIGraphicsBeginImageContextWithOptions(resourceView.bounds.size, resourceView.opaque, 0.0);
        [resourceView.layer renderInContext:UIGraphicsGetCurrentContext()];

        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [JMCancelRequestPopup dismiss];
            if (completion) {
                completion(viewImage);
            }
        });
    });
}

#pragma mark - Custom Accessors

- (JMDashboard *)dashboard
{
    if (!_dashboard) {
        _dashboard = [self.resourceLookup dashboardModel];
    }
    return _dashboard;
}

- (UIView *)resourceView
{
    return self.webEnvironment.webView;
}

- (void)setupSubviews
{
    self.webEnvironment = [self primaryWebEnvironment];
    self.configurator = [JMDashboardViewerConfigurator configuratorWithDashboard:self.dashboard
                                                                  webEnvironment:self.webEnvironment];

    [self.configurator updateReportLoaderDelegateWithObject:self];

    [super setupSubviews];
}

- (JMWebEnvironment *)primaryWebEnvironment
{
    JMWebEnvironment *webEnvironment = [[JMWebViewManager sharedInstance] webEnvironmentForId:kJMDashboardViewerPrimaryWebEnvironmentIdentifier]              ;
    return webEnvironment;
}

- (id<JMDashboardLoader>)dashboardLoader
{
    return [self.configurator dashboardLoader];
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
        self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                                   target:self
                                                                   action:@selector(minimizeDashlet)];
    } else {
        [super setupLeftBarButtonItems];
    }
}

- (void)setupRightBarButtonItems
{
    if (![self isDashletShown]) {
        [super setupRightBarButtonItems];
        self.rightButtonItems = self.navigationItem.rightBarButtonItems;
    }
}

- (void)resetSubViews
{
    [self.dashboardLoader destroy];
    [self.webEnvironment resetZoom];
}


- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if ([self isContentOnTV]) {
        [self switchFromTV];
        [self hideExternalWindowWithCompletion:nil];
        [super cancelResourceViewingAndExit:exit];
    } else {
        [super cancelResourceViewingAndExit:exit];
    }
}

#pragma mark - Actions
- (void)minimizeDashlet
{
    [self.webEnvironment resetZoom];
    [self.dashboardLoader minimizeDashlet];
    self.navigationItem.leftBarButtonItem = self.leftButtonItem;
    self.navigationItem.rightBarButtonItems = self.rightButtonItems;
    self.navigationItem.title = [self resourceLookup].label;
    self.leftButtonItem = nil;
}

- (void)reloadDashboard
{
    [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)
                               cancelBlock:^(void) {
                                   [self.dashboardLoader cancel];
                                   [super cancelResourceViewingAndExit:YES];
                               }];
    __weak typeof(self)weakSelf = self;
    [self.dashboardLoader reloadDashboardWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];

        if (!success) {
            JMLog(@"error of refreshing dashboard: %@", error);
            if (error.code == JMJavascriptNativeBridgeErrorAuthError) {
                __weak typeof(self)weakSelf = strongSelf;
                [strongSelf handleAuthErrorWithCompletion:^(void) {
                    __weak typeof(self)strongSelf = weakSelf;
                    [strongSelf startShowDashboard];
                }];
            } else {
                [JMUtils presentAlertControllerWithError:error
                                              completion:nil];
            }
        }
    }];
}

- (void)reloadDashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {

        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)];

        [self.dashboardLoader reloadMaximizedDashletWithCompletion:^(BOOL success, NSError *error){
            __weak typeof(self)strongSelf = weakSelf;
            [strongSelf stopShowLoader];
            if (!success) {
                if (error.code == JMJavascriptNativeBridgeErrorAuthError) {
                    __weak typeof(self)weakSelf = strongSelf;
                    [strongSelf handleAuthErrorWithCompletion:^(void) {
                        __weak typeof(self)strongSelf = weakSelf;
                        [strongSelf startShowDashboard];
                    }];
                } else {
                    [JMUtils presentAlertControllerWithError:error
                                                  completion:nil];
                }
            }
        }];

    } else {
        [self minimizeDashlet];
        [self reloadDashboard];
    }
}

#pragma mark - Overriden methods
- (void)startResourceViewing
{
    if ([JMUtils isServerAmber2OrHigher] && ![self.resourceLookup isLegacyDashboard]) {
        [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)
                                   cancelBlock:^(void) {
                                       [super cancelResourceViewingAndExit:YES];
                                   }];

        __weak __typeof(self) weakSelf = self;
        [self fetchDashboardMetaDataWithCompletion:^(NSArray *components, NSArray *inputControls, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf stopShowLoader];

            if (error) {
                if (error.code == JSSessionExpiredErrorCode) {
                    __weak typeof(self)weakSelf = self;
                    [strongSelf handleAuthErrorWithCompletion:^(void) {
                        __weak typeof(self)strongSelf = weakSelf;
                        [strongSelf startResourceViewing];
                    }];
                } else {
                    [JMUtils presentAlertControllerWithError:error
                                                  completion:nil];
                }
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
    [self startShowLoaderWithMessage:JMCustomLocalizedString(@"resources.loading.msg", nil)
                               cancelBlock:^(void) {
                                   [self.dashboardLoader cancel];
                                   [super cancelResourceViewingAndExit:YES];
                               }];

    __weak typeof(self)weakSelf = self;
    [self.dashboardLoader loadDashboardWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];

        if (success) {
            // Analytics
            NSString *label = ([JMUtils isSupportVisualize] && [JMUtils isServerAmber2OrHigher]) ? kJMAnalyticsResourceEventLabelDashboardVisualize : kJMAnalyticsResourceEventLabelDashboardFlow;
            [JMUtils logEventWithInfo:@{
                    kJMAnalyticsCategoryKey      : kJMAnalyticsResourceEventCategoryTitle,
                    kJMAnalyticsActionKey        : kJMAnalyticsResourceEventActionOpenTitle,
                    kJMAnalyticsLabelKey         : label
            }];

            if ([strongSelf isContentOnTV]) {
                strongSelf.controlsViewController.components = strongSelf.dashboard.dashlets;
            }
        } else {
            if (error.code == JMJavascriptNativeBridgeErrorAuthError) {
                __weak typeof(self)weakSelf = strongSelf;
                [strongSelf handleAuthErrorWithCompletion:^(void) {
                    __weak typeof(self)strongSelf = weakSelf;
                    [strongSelf startShowDashboard];
                }];
            } else {
                [JMUtils presentAlertControllerWithError:error
                                              completion:nil];
            }
        }
    }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction menuActions = [super availableActionForResource:resource] | JMMenuActionsViewAction_Refresh;

    // TODO: enable in next releases
    if ([JMUtils isServerAmber2OrHigher]) {
        if ([self isExternalScreenAvailable]) {
            menuActions |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
        }
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
            [self hideExternalWindowWithCompletion:^(void) {
                [self configViewport];
            }];
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
- (void)dashboardLoader:(id <JMDashboardLoader>)loader didStartMaximazeDashletWithTitle:(NSString *)title
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

    self.leftButtonItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:self.title
                                                               target:self
                                                               action:@selector(minimizeDashlet)];
    self.navigationItem.title = title;
}

- (void)dashboardLoader:(id <JMDashboardLoader>)loader didReceiveHyperlinkWithType:(JMHyperlinkType)hyperlinkType
         resourceLookup:(JSResourceLookup *)resourceLookup
             parameters:(NSArray *)parameters
{
    if (hyperlinkType == JMHyperlinkTypeReportExecution) {
        NSString *reportURI = resourceLookup.uri;
        __weak typeof(self)weakSelf = self;
        [self loadInputControlsWithReportURI:reportURI completion:^(NSArray *inputControls, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            if (error) {
                __weak typeof(self) weakSelf = strongSelf;
                [JMUtils presentAlertControllerWithError:error completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            } else {
                JMReportViewerVC *reportViewController = (JMReportViewerVC *) [strongSelf.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
                reportViewController.resourceLookup = resourceLookup;
                [reportViewController.report generateReportOptionsWithInputControls:inputControls];
                [reportViewController.report updateReportParameters:parameters];
                reportViewController.isChildReport = YES;

                [strongSelf.navigationController pushViewController:reportViewController animated:YES];
            }
        }];
    } else if (hyperlinkType == JMHyperlinkTypeReference) {
        NSURL *URL = parameters.firstObject;
        if (URL) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

- (void)dashboardLoaderDidReceiveAuthRequest:(id <JMDashboardLoader>)loader
{
    if ([self isDashletShown]) {
        [self minimizeDashlet];
    }

    if ([JMUtils isServerAmber2OrHigher]) {
        [self startResourceViewing];
    } else {
        [self reloadDashboard];
    }
}

#pragma mark - Report Options (Input Controls)
- (void)loadInputControlsWithReportURI:(NSString *)reportURI completion:(void (^)(NSArray *inputControls, NSError *error))completion
{
    __weak typeof(self)weakSelf = self;
    [self.restClient inputControlsForReport:reportURI
                                        ids:nil
                             selectedValues:nil
                            completionBlock:^(JSOperationResult *result) {
                                __strong typeof(self)strongSelf = weakSelf;
                                if (result.error) {
                                    if (result.error.code == JSSessionExpiredErrorCode) {
                                        [JMUtils showLoginViewAnimated:YES completion:^{
                                            [strongSelf cancelResourceViewingAndExit:YES];
                                        }];
                                    } else {
                                        if (completion) {
                                            completion(nil, result.error);
                                        }
                                    }
                                } else {

                                    NSMutableArray *invisibleInputControls = [NSMutableArray array];
                                    for (JSInputControlDescriptor *inputControl in result.objects) {
                                        if (!inputControl.visible.boolValue) {
                                            [invisibleInputControls addObject:inputControl];
                                        }
                                    }

                                    if (result.objects.count - invisibleInputControls.count == 0) {
                                        completion(nil, nil);
                                    } else {
                                        NSMutableArray *inputControls = [result.objects mutableCopy];
                                        if (invisibleInputControls.count) {
                                            [inputControls removeObjectsInArray:invisibleInputControls];
                                        }
                                        completion([inputControls copy], nil);
                                    }
                                }

                            }];
}

#pragma mark - Helpers
- (BOOL)isDashletShown
{
    return self.leftButtonItem != nil;
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

- (void)handleAuthErrorWithCompletion:(void(^ __nonnull)(void))completion
{
    [self.restClient deleteCookies];
    [self resetSubViews];

    __weak typeof(self)weakSelf = self;
    [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
        __weak typeof(self)strongSelf = weakSelf;
        if (strongSelf.restClient.keepSession && isSessionAuthorized) {
            [[JMWebViewManager sharedInstance] reset];
            [self setupSubviews];
            [self configViewport];

            completion();
        } else {
            __weak typeof(self)weakSelf = strongSelf;
            [JMUtils showLoginViewAnimated:YES completion:^{
                __weak typeof(self)strongSelf = weakSelf;
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
        }
    }];
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
    self.controlsViewController.components = self.dashboard.dashlets;
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
}

#pragma mark - JMExternalWindowDashboardControlsVCDelegate
- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMaximizeDashlet:(JMDashlet *)dashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(maximizeDashlet:)]) {
        [self.dashboardLoader maximizeDashlet:dashlet];

        // TODO: move to separate method
        self.navigationItem.rightBarButtonItems = nil;
        if ([self.dashboardLoader respondsToSelector:@selector(reloadMaximizedDashletWithCompletion:)]) {
            UIBarButtonItem *refreshDashlet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_action"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(reloadDashlet)];
            self.navigationItem.rightBarButtonItem = refreshDashlet;
        }

        self.leftButtonItem = self.navigationItem.leftBarButtonItem;
        self.navigationItem.title = dashlet.name;
    }
}

- (void)externalWindowDashboardControlsVC:(JMExternalWindowDashboardControlsVC *)dashboardControlsVC didAskMinimizeDashlet:(JMDashlet *)dashlet
{
    if ([self.dashboardLoader respondsToSelector:@selector(maximizeDashlet:)]) {
        [self.dashboardLoader minimizeDashlet:dashlet];

        // TODO: move to separate method
        self.navigationItem.leftBarButtonItem = self.leftButtonItem;
        self.navigationItem.rightBarButtonItems = self.rightButtonItems;
        self.navigationItem.title = [self resourceLookup].label;
        self.leftButtonItem = nil;
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
                parameters[componentID] = values;
            }
            [strongSelf.dashboardLoader applyParameters:parameters];
        }
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

@end