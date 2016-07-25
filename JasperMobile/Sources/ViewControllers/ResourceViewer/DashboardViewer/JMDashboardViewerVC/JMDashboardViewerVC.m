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
#import "JMJavascriptRequest.h"
#import "JMHyperlink.h"
#import "JMDashboardViewerStateManager.h"
#import "PopoverView.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerSessionManager.h"

@interface JMDashboardViewerVC() <JMDashboardLoaderDelegate, JMResourceViewerStateManagerDelegate>
@end


@implementation JMDashboardViewerVC
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
    [self dashboardLoader].delegate = self;
    [self setupSessionManager];
    [self setupStateManager];

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
    __weak typeof(self)weakSelf = self;
    [self stateManager].minimizeDashletActionBlock = ^{
        [weakSelf minimizeDashlet];
    };
    [[self stateManager] setupPageForState:JMDashboardViewerStateInitial];
}

- (void)setupSessionManager
{
    self.configurator.sessionManager.controller = self;

    __weak typeof(self) weakSelf = self;
    self.configurator.sessionManager.cleanAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator reset];
        if ([strongSelf isDashletShown]) {
            [strongSelf dashboard].maximizedComponent = nil;
            strongSelf.navigationItem.title = strongSelf.resource.resourceLookup.label;
        }
    };
    self.configurator.sessionManager.executeAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.resource.type == JMResourceTypeLegacyDashboard) {
            JMDashboardViewerConfigurator *configurator = [JMDashboardViewerConfigurator configuratorWithWebEnvironment:[[JMWebViewManager sharedInstance] webEnvironmentForFlowType:JMResourceFlowTypeREST]];
            strongSelf.configurator = configurator;
        }
        [strongSelf.configurator setup];
        [[strongSelf dashboardLoader] setDelegate:strongSelf];
        [strongSelf setupStateManager];

        [strongSelf startResourceViewing];
    };
    self.configurator.sessionManager.exitAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    };
}

#pragma mark - Helpers

- (id<JMDashboardLoader>)dashboardLoader
{
    return self.configurator.dashboardLoader;
}

- (JMWebEnvironment *)webEnvironment
{
    return self.configurator.webEnvironment;
}

- (JMDashboard *)dashboard
{
    return [self dashboardLoader].dashboard;
}

- (JMDashboardViewerStateManager *)stateManager
{
    return self.configurator.stateManager;
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

- (void)stateManagerWillBackFromNestedResource:(JMResourceViewerStateManager *)stateManager
{
    [self backActionInWebView];
}

#pragma mark - Actions
- (void)exitAction
{
    [[self dashboardLoader] destroy];
    [self.webEnvironment reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [[self dashboardLoader] cancel];
    [self.webEnvironment reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backActionInWebView
{

}

#pragma mark - Network Helpers

- (void)fetchDashboardMetaDataWithCompletion:(void(^)(NSArray <JSDashboardComponent *> *components, NSArray <JSInputControlDescriptor *> *inputControls, NSError *error))completion
{
    if (!completion) {
        return;
    }

    __weak __typeof(self) weakSelf = self;
    [self.restClient fetchDashboardComponentsWithURI:self.resource.resourceLookup.uri
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
                                                              NSString *dashboardFilesURI = [NSString stringWithFormat:@"%@_files", strongSelf.resource.resourceLookup.uri];
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

#pragma mark - Resource Viewing methods

- (void)startResourceViewing
{
    JMDashboard *dashboard = [self.resource modelOfResource];
    if (self.resource.type != JMResourceTypeLegacyDashboard && [JMUtils isSupportVisualize]) {
        [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];

        __weak __typeof(self) weakSelf = self;
        [self fetchDashboardMetaDataWithCompletion:^(NSArray *components, NSArray *inputControls, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                [JMUtils presentAlertControllerWithError:error
                                              completion:^{
                                                  [strongSelf exitAction];
                                              }];
            } else {
                [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateInitial];
                dashboard.components = components;
                dashboard.inputControls = inputControls;
                [strongSelf startShowDashboard:dashboard];
            }
        }];
    } else {
        [self startShowDashboard:dashboard];
    }
}

- (void)startShowDashboard:(JMDashboard *)dashboard
{
    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
    __weak typeof(self)weakSelf = self;
    [[self dashboardLoader] runDashboard:dashboard completion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        if (success) {
            [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateResourceReady];
            // Analytics
            NSString *label = ([JMUtils isServerProEdition] && [JMUtils isServerVersionUpOrEqual6]) ? kJMAnalyticsResourceLabelDashboardVisualize : kJMAnalyticsResourceLabelDashboardFlow;
            [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                    kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                    kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                    kJMAnalyticsLabelKey    : label
            }];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)applyParameters
{
    NSMutableDictionary <NSString *, NSArray <NSString *>*> *parameters = [@{} mutableCopy];
    for (JSInputControlDescriptor *inputControlDescriptor in [self dashboard].inputControls) {
        NSString *componentID;
        for (JSDashboardComponent *component in [self dashboard].components) {
            if ([component.ownerResourceParameterName isEqualToString:inputControlDescriptor.uuid]) {
                componentID = component.identifier;
            }
        }
        NSArray <NSString *>*values = [inputControlDescriptor selectedValues];
        if (componentID) {
            parameters[componentID] = values;
        }
    }

    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
    __weak __typeof(self) weakSelf = self;
    [[self dashboardLoader] applyParameters:parameters completion:^(BOOL success, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf handleError:error];
        } else {
            [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateResourceReady];
        }
    }];
}

- (void)reloadDashboard
{
    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
    __weak typeof(self)weakSelf = self;
    [[self dashboardLoader] reloadWithCompletion:^(BOOL success, NSError *error) {
        __weak typeof(self)strongSelf = weakSelf;
        if (error) {
            [strongSelf handleError:error];
        } else {
            [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateResourceReady];
        }
    }];
}

- (void)reloadDashlet
{
    NSAssert([self dashboard].maximizedComponent != nil, @"Should be maximized component");
    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
    __weak typeof(self)weakSelf = self;
    [[self dashboardLoader] reloadDashboardComponent:[self dashboard].maximizedComponent
                                          completion:^(BOOL success, NSError *error) {
                                              __weak typeof(self)strongSelf = weakSelf;
                                              if (error) {
                                                  [strongSelf handleError:error];
                                              } else {
                                                  [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateResourceReady];
                                              }
                                          }];
}

- (void)minimizeDashlet
{
    [self.webEnvironment resetZoom];

    __weak typeof(self)weakSelf = self;
    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
    [[self dashboardLoader] minimizeDashboardComponent:[self dashboard].maximizedComponent
                                            completion:^(BOOL success, NSError *error) {
                                                __weak typeof(self)strongSelf = weakSelf;
                                                if (error) {
                                                    [strongSelf handleError:error];
                                                } else {
                                                    strongSelf.navigationItem.title = strongSelf.resource.resourceLookup.label;
                                                    [[strongSelf stateManager] setupPageForState:JMDashboardViewerStateResourceReady];
                                                }
                                            }];
}

#pragma mark - Overriden methods

- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (self.resource.type != JMResourceTypeLegacyDashboard) {
        availableAction |= JMMenuActionsViewAction_Refresh;
    }
    availableAction |= JMMenuActionsViewAction_Share | JMMenuActionsViewAction_Print;

//    if ([self isExternalScreenAvailable]) {
//        menuActions |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
//    }

    if ([self isFiltersAvailable]) {
        availableAction |= JMMenuActionsViewAction_EditFilters;
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
            [self reloadDashboard];
            break;
        }
        case JMMenuActionsViewAction_EditFilters: {
            [self showFiltersVC];
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
        default:{break;}
    }
}

#pragma mark - JMDashboardLoaderDelegate
- (void)dashboardLoaderDidStartMaximizeDashlet:(id<JMDashboardLoader> __nonnull)loader
{
    [[self stateManager] setupPageForState:JMDashboardViewerStateLoading];
}

- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didEndMaximazeDashboardComponent:(JSDashboardComponent *__nonnull)component
{
    [self.webEnvironment resetZoom];

    self.navigationItem.title = component.label;
    [[self stateManager] setupPageForState:JMDashboardViewerStateMaximizedDashlet];
}

- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didReceiveEventWithHyperlink:(JMHyperlink *__nonnull)hyperlink
{
    self.configurator.hyperlinksManager.controller = self;
    self.configurator.hyperlinksManager.errorBlock = ^(NSError *error) {
        [JMUtils presentAlertControllerWithError:error completion:nil];
    };
    [self.configurator.hyperlinksManager handleHyperlink:hyperlink];
}

- (void)dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMDashboardLoader> __nonnull)loader
{
    // TODO: translate
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Visualize Message"
                                                                                      message:@"The hyperlink could not be processed"
                                                                            cancelButtonTitle:@"dialog_button_ok"
                                                                      cancelCompletionHandler:nil];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didRecieveError:(NSError *__nonnull)error
{
    [self handleError:error];
}

#pragma mark - Helpers
- (BOOL)isDashletShown
{
    return [self dashboard].maximizedComponent != nil;
}

- (BOOL)isFiltersAvailable
{
    return [self dashboard].inputControls.count > 0;
}

#pragma mark - Error handling
- (void)handleError:(NSError *)error
{
    [[self stateManager] setupPageForState:JMDashboardViewerStateResourceFailed];
    switch (error.code) {
        case JMJavascriptRequestErrorTypeAuth: {
            [self.configurator.sessionManager handleSessionDidExpire];
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

#pragma mark - Dashboard Filters
- (void)showFiltersVC
{
    JMDashboardInputControlsVC *inputControlsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMDashboardInputControlsVC"];
    inputControlsViewController.dashboard = [self dashboard];

    __weak __typeof(self) weakSelf = self;
    inputControlsViewController.exitBlock = ^(BOOL inputControlsDidChanged) {
        __typeof(self) strongSelf = weakSelf;
        if (inputControlsDidChanged) {
            [strongSelf applyParameters];
        }
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

@end