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

#import "JMReportViewerVC.h"
#import "JMBaseResourceView.h"
#import "JMReportViewerConfigurator.h"
#import "JMSavingReportViewController.h"
#import "ALToastView.h"
#import "JMInputControlsViewController.h"
#import "JMReportViewerToolBar.h"
#import "JMScheduleVC.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMBookmarksVC.h"
#import "JMReportPartViewToolbar.h"
#import "JMReportViewerStateManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerShareManager.h"
#import "PopoverView.h"
#import "JMFiltersVCResult.h"
#import "JMResourceViewerSessionManager.h"
#import "JMFiltersNetworkManager.h"
#import "JMRestReportLoader.h"
#import "JMVisualizeReportLoader.h"
#import "NSObject+Additions.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import "UIAlertController+Additions.h"
#import "JMReportChartType.h"
#import "JMReportChartTypesVC.h"
#import "JasperMobileAppDelegate.h"
#import "JMReportViewerExternalScreenManager.h"

@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMReportPartViewToolbarDelegate, JMResourceViewerStateManagerDelegate>
@property (nonatomic, strong) JMResourceViewerSessionManager * __nonnull sessionManager;
// TODO: temporary solution, remove in the next release
@property (nonatomic, strong) JMFiltersNetworkManager *filtersNetworkManager;
@property (nonatomic, assign) BOOL shouldShowFiltersPage;
@property (nonatomic, copy) void(^runReportCompletion)(BOOL success, NSError *error);
@property (nonatomic, copy) NSString *warningMessage;
@end

@implementation JMReportViewerVC
@synthesize resource = _resource;

#pragma mark - Lifecycle
- (void)dealloc
{
    [self removeAllObservers];
}

#pragma mark - UIViewController LifeCycle

- (void)loadView
{
    JMBaseResourceView *resourceView = [[[NSBundle mainBundle] loadNibNamed:@"JMBaseResourceView"
                                                                      owner:self
                                                                    options:nil] firstObject];
    self.view = resourceView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.filtersNetworkManager = [JMFiltersNetworkManager managerWithRestClient:self.restClient];
    self.warningMessage = JMLocalizedString(@"report_viewer_filters_not_applyed_title");
    [self setupSessionManager];

    [self.configurator setup];
    [[self reportLoader] setDelegate:self];
    [self addObservers];
    [self setupStateManager];
    [self setupExternalScreenManager];

    __weak typeof(self)weakSelf = self;
    self.runReportCompletion = ^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        if (success) {
            // Analytics
            NSString *label = [JMUtils isSupportVisualize] ? kJMAnalyticsResourceLabelReportVisualize : kJMAnalyticsResourceLabelReportREST;
            [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                    kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                    kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                    kJMAnalyticsLabelKey    : label
            }];
            [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
        } else {
            [strongSelf handleError:error];
        }
    };

    [self startResourceViewing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self stateManager] setupPageForState:JMReportViewerStateNotVisible];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:nil completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [[self stateManager] updatePageForChangingSizeClass];
        if ([[self reportLoader] respondsToSelector:@selector(fitReportViewToScreen)]) {
            [[self reportLoader] fitReportViewToScreen];
        }
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        JMSavingReportViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.report = [self report];
        destinationViewController.delegate = self;
        __weak __typeof(self) weakSelf = self;
        destinationViewController.sessionExpiredBlock = ^{
            __weak __typeof(self) strongSelf = weakSelf;
            [strongSelf.sessionManager handleSessionDidChangeWithAlert:YES];
        };
    }
}

#pragma mark - Setups

- (void)setupSessionManager
{
    self.sessionManager = [self createSessionManager];
    self.sessionManager.controller = self;

    __weak typeof(self) weakSelf = self;
    self.sessionManager.cleanAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator reset];
    };
    self.sessionManager.executeAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [[strongSelf reportLoader] resetWithCompletion:^{
            [strongSelf.configurator setup];
            [[strongSelf reportLoader] setDelegate:strongSelf];
            [strongSelf setupStateManager];

            [strongSelf startResourceViewing];
        }];
    };
    self.sessionManager.exitAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    };
}

- (void)setupStateManager
{
    [self stateManager].controller = self;
    [self stateManager].delegate = self;
    [[self stateManager] setupPageForState:JMReportViewerStateInitial];
}

- (void)setupExternalScreenManager
{
    [self externalScreenManager].controller = self;
}

#pragma mark - Custom accessors

- (JSReportDestination *)initialDestination
{
    if (!_initialDestination) {
        _initialDestination = [JSReportDestination new];
        _initialDestination.page = 1;
    }
    return _initialDestination;
}

#pragma mark - Observe Notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidSetReport:)
                                                 name:JSReportLoaderDidSetReportNotification
                                               object:nil];
}

- (void)removeAllObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addReportPropertiesObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidUpdateCountOfPages)
                                                 name:JSReportCountOfPagesDidChangeNotification
                                               object:[self report]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(multipageNotification)
                                                 name:JSReportIsMutlipageDidChangedNotification
                                               object:[self report]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidUpdateBookmarks)
                                                 name:JSReportBookmarksDidUpdateNotification
                                               object:[self report]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidUpdateParts)
                                                 name:JSReportPartsDidUpdateNotification
                                               object:[self report]];
}

- (void)removeReportPropertiesObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportCountOfPagesDidChangeNotification
                                                  object:[self report]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportIsMutlipageDidChangedNotification
                                                  object:[self report]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportBookmarksDidUpdateNotification
                                                  object:[self report]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportPartsDidUpdateNotification
                                                  object:[self report]];
}

- (void)reportDidUpdateCountOfPages
{
    if ([self report].countOfPages == 0) {
        [[self stateManager] setupPageForState:JMReportViewerStateResourceNotExist];
    }
}

- (void)multipageNotification
{
    if ([self report].isMultiPageReport) {
        [[self stateManager] updatePageForToolbarState:JMResourceViewerToolbarStateBottomVisible];
    }
}

- (void)reportDidUpdateBookmarks
{
    if ([self reportHasBookmarks]) {
        [self addBookmarkBarButton];
    }
}

- (void)reportDidUpdateParts
{
    if ([self reportHasParts]) {
        [[self stateManager] updatePageForToolbarState:JMResourceViewerToolbarStateTopVisible];
    }
}

- (void)reportLoaderDidSetReport:(NSNotification *)notification
{
    [self addReportPropertiesObservers];
}

#pragma mark - JMResourceViewProtocol
- (UIView *)contentView
{
    return [self webEnvironment].webView;
}

- (UIView *)topToolbarView
{
    JMReportPartViewToolbar *reportPartToolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportPartViewToolbar" owner:self options:nil] firstObject];
    reportPartToolbar.delegate = self;
    return reportPartToolbar;
}

- (UIView *)bottomToolbarView
{
    JMReportViewerToolBar *toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerToolBar" owner:self options:nil] firstObject];
    toolbar.toolbarDelegate = self;
    return toolbar;
}

- (UIView *)warningsView
{
    UILabel *label = [UILabel new];
    label.text = self.warningMessage;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

#pragma mark - JMResourceViewerStateManagerDelegate

- (void)stateManagerWillExit:(JMResourceViewerStateManager *)stateManager
{
    [self exitAction];
}

- (void)stateManagerWillCancel:(JMResourceViewerStateManager *)stateManager
{
    [self exitAction];
}

- (void)stateManagerWillBackFromNestedResource:(JMResourceViewerStateManager *)stateManager
{
    [self backActionInWebView];
}

#pragma mark - Actions
- (void)exitAction
{
    [self.filtersNetworkManager reset];
    [[self stateManager] setupPageForState:JMReportViewerStateDestroy];
    if ([[self reportLoader] respondsToSelector:@selector(destroyWithCompletion:)]) {
        [[self reportLoader] destroyWithCompletion:nil];
    } else {
        [[self reportLoader] reset];
    }
    [[self webEnvironment] reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backActionInWebView
{
    [[self webEnvironment].webView goBack];
    [self runReportWithDestination:self.initialDestination];
    [self.configurator.hyperlinksManager reset];
}

#pragma mark - Network methods

- (void)fetchReportMetadataWithCompletion:(void(^)(JSResourceReportUnit *reportUnit, NSError *error))completion
{
    __weak typeof(self) weakSelf = self;
    [self.restClient resourceLookupForURI:self.resource.resourceLookup.uri
                             resourceType:kJS_WS_TYPE_REPORT_UNIT
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:^(JSOperationResult *result) {
                              typeof(self) strongSelf = weakSelf;
                              if (result.error) {
                                  completion(nil, result.error);
                              } else {
                                  JSResourceReportUnit *reportUnit = result.objects.firstObject;
                                  if (reportUnit) {
                                      completion(reportUnit, nil);
                                  } else {
                                      NSDictionary *userInfo = @{NSURLErrorFailingURLErrorKey : @"Report Unit Loading Error"};
                                      NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:JSClientErrorCode userInfo:userInfo];
                                      __weak typeof(self) weakSelf = strongSelf;
                                      [JMUtils presentAlertControllerWithError:error completion:^{
                                          __strong typeof(self) strongSelf = weakSelf;
                                          [strongSelf exitAction];
                                      }];
                                  }
                              }
                          }];
}

- (void)loadInputControlsWithCompletion:(void(^)(NSArray *inputControls, NSError *error))completion
{
    [self.filtersNetworkManager loadInputControlsWithResourceURI:self.resource.resourceLookup.uri
                                               completion:^(NSArray *inputControls, NSError *error) {
                                                   if (error) {
                                                       completion(nil, error);
                                                   } else {
                                                       NSMutableArray *visibleInputControls = [NSMutableArray array];
                                                       for (JSInputControlDescriptor *inputControl in inputControls) {
                                                           if (inputControl.visible.boolValue) {
                                                               [visibleInputControls addObject:inputControl];
                                                           }
                                                       }
                                                       completion(visibleInputControls, nil);
                                                   }
                                               }];
}

#pragma mark - Resource Viewing methods
- (void)startResourceViewing
{
    [[self stateManager] setupPageForState:JMReportViewerStateLoading];
    __weak typeof(self) weakSelf = self;
    [self fetchReportMetadataWithCompletion:^(JSResourceReportUnit *reportUnit, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf handleError:error];
        } else {
            // TODO: temporary solution, remove in the next release
            // the main reason for this - we don't have ideal UX solution for case, when 'always prompt' enabled
            // but there are any visible filters.
            BOOL isAlwaysPrompt = reportUnit.alwaysPromptControls;
            __weak typeof(self) weakSelf = strongSelf;
            [strongSelf loadInputControlsWithCompletion:^(NSArray *inputControls, NSError *error) {
                typeof(self) strongSelf = weakSelf;
                if (error) {
                    [strongSelf handleError:error];
                } else {
                    [[strongSelf stateManager] setupPageForState:JMReportViewerStateInitial];
                    if (inputControls.count > 0) {
                        strongSelf.shouldShowFiltersPage = YES;
                    }
                    if (isAlwaysPrompt && inputControls.count > 0) {
                        [strongSelf showFiltersVCWithInitialParameters:strongSelf.initialReportParameters];
                    } else {
                        [strongSelf runReportWithDestination:strongSelf.initialDestination];
                    }
                }
            }];
        }
    }];
}

- (void)runReportWithDestination:(JSReportDestination *)destination
{
    // here we'll have a new instance of report
    [self removeReportPropertiesObservers];

    [[self stateManager] setupPageForState:JMReportViewerStateLoading];
    JSReport *report = [self.resource modelOfResource];
    if ([[self reportLoader] respondsToSelector:@selector(runReport:initialDestination:initialParameters:completion:)]) {
        [[self reportLoader] runReport:report
                  initialDestination:destination
                   initialParameters:self.initialReportParameters
                          completion:self.runReportCompletion];
    } else {
        [[self reportLoader] runReport:report
                         initialPage:@(destination.page)
                   initialParameters:self.initialReportParameters
                          completion:self.runReportCompletion];
    }
}

- (void)runReportWithReportURI:(NSString *)reportURI
{
    // here we'll have a new instance of report
    [self removeReportPropertiesObservers];

    [[self stateManager] setupPageForState:JMReportViewerStateLoading];
    [[self reportLoader] runReportWithReportURI:reportURI
                                    initialPage:nil
                              initialParameters:nil
                                     completion:self.runReportCompletion];
}

- (void)updateReportWithParameters:(NSArray <JSReportParameter *> *)reportParameters
{
    BOOL isReportOptionReportActive = ![[self report].reportURI isEqualToString:self.resource.resourceLookup.uri];
    if (isReportOptionReportActive) {
        self.initialReportParameters = reportParameters;
        [self runReportWithDestination:self.initialDestination];
    } else {
        if ([self reportLoader].state == JSReportLoaderStateReady) {
            [[self stateManager] setupPageForState:JMReportViewerStateLoading];
            __weak typeof(self)weakSelf = self;
            [[self reportLoader] applyReportParameters:reportParameters
                                          completion:^(BOOL success, NSError *error) {
                                              __strong typeof(self)strongSelf = weakSelf;
                                              if (success) {
                                                  [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
                                              } else {
                                                  [strongSelf handleError:error];
                                              }
                                          }];
        } else if ([self reportLoader].state == JSReportLoaderStateInitial || [self reportLoader].state == JSReportLoaderStateFailed) {
            self.initialReportParameters = reportParameters;
            [self runReportWithDestination:self.initialDestination];
        }
    }

    // TODO: investigate other cases
}

- (void)navigateToPage:(NSInteger)page completion:(void(^ __nonnull)(BOOL success))completion
{
    NSAssert(completion != nil, @"Completion is nil");
    if ([[self reportLoader] respondsToSelector:@selector(shouldDisplayLoadingView)] && [[self reportLoader] shouldDisplayLoadingView]) {
        [[self stateManager] setupPageForState:JMReportViewerStateLoading];
    }
    __weak typeof(self)weakSelf = self;
    [[self reportLoader] fetchPage:@(page)
                      completion:^(BOOL success, NSError *error) {
                          __strong typeof(self)strongSelf = weakSelf;
                          if (success) {
                              completion(YES);
                              if ([[self reportLoader] respondsToSelector:@selector(shouldDisplayLoadingView)] && [[self reportLoader] shouldDisplayLoadingView]) {
                                  [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
                              }
                          } else {
                              [strongSelf handleError:error];
                          }
                      }];
}

- (void)navigateToBookmark:(JSReportBookmark *__nonnull)bookmark
{
    if ([[self reportLoader] respondsToSelector:@selector(navigateToBookmark:completion:)]) {
        [[self stateManager] setupPageForState:JMReportViewerStateLoading];
        __weak __typeof(self) weakSelf = self;
        [[self reportLoader] navigateToBookmark:bookmark completion:^(BOOL success, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
            }
        }];
    }
}

- (void)refreshReport
{
    [[self stateManager] setupPageForState:JMReportViewerStateLoading];

    __weak typeof(self)weakSelf = self;
    [[self reportLoader] refreshReportWithCompletion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        if (success) {
            [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

#pragma mark - JMReportLoaderDelegate
- (void)reportLoader:(id<JMReportLoaderProtocol>)loader didReceiveEventWithHyperlink:(JMHyperlink *)hyperlink
{
    self.configurator.hyperlinksManager.controller = self;
    self.configurator.hyperlinksManager.errorBlock = ^(NSError *error) {
        [JMUtils presentAlertControllerWithError:error completion:nil];
    };
    [self.configurator.hyperlinksManager handleHyperlink:hyperlink];
}

- (void)reportLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMReportLoaderProtocol> __nonnull)loader
{
    // TODO: translate
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Visualize Message"
                                                                                      message:@"The hyperlink could not be processed"
                                                                            cancelButtonTitle:@"dialog_button_ok"
                                                                      cancelCompletionHandler:nil];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Helpers
- (id<JMReportLoaderProtocol>)reportLoader
{
    return self.configurator.reportLoader;
}

- (JSReport *)report
{
    return [self reportLoader].report;
}

- (JMWebEnvironment *)webEnvironment
{
    return self.configurator.webEnvironment;
}

- (JMReportViewerStateManager *)stateManager
{
    return self.configurator.stateManager;
}

- (JMReportViewerExternalScreenManager *)externalScreenManager
{
    return self.configurator.externalScreenManager;
}

- (JMResourceViewerSessionManager *)createSessionManager
{
    return [JMResourceViewerSessionManager new];
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar changeFromPage:(NSInteger)fromPage toPage:(NSInteger)toPage
{
    toolbar.enable = NO;
    [[self webEnvironment] resetZoom];

    [self navigateToPage:toPage completion:^(BOOL success) {
        if (success) {
            toolbar.enable = YES;
        }
    }];
}

#pragma mark - JMReportPartViewToolbarDelegate
- (void)reportPartViewToolbarDidChangePart:(JMReportPartViewToolbar *)toolbar
{
    if ([[self reportLoader] respondsToSelector:@selector(navigateToPart:completion:)]) {

        [[self stateManager] setupPageForState:JMReportViewerStateLoading];

        __weak typeof(self)weakSelf = self;
        [[self reportLoader] navigateToPart:toolbar.currentPart completion:^(BOOL success, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                [[strongSelf stateManager] setupPageForState:JMReportViewerStateResourceReady];
            }
        }];
    }
}

#pragma mark - Handler Errors

- (void)handleError:(NSError *)error
{
    [[self stateManager] setupPageForState:JMReportViewerStateResourceFailed];

    switch (error.code) {
        case JSReportLoaderErrorTypeSessionDidExpired: {
            [self.sessionManager handleSessionDidExpire];
            break;
        }
        case JSReportLoaderErrorTypeSessionDidRestore: {
            [self.sessionManager handleSessionDidChangeWithAlert:YES];
            break;
        }
        case JSReportLoaderErrorTypeEmtpyReport:
            // TODO: this isn't an error
            break;
        case JSInvalidCredentialsErrorCode: {
            [JMUtils showLoginViewAnimated:YES completion:^{
                [self exitAction];
            }];
            break;
        }
        default: {
            __weak typeof(self) weakSelf = self;
            [JMUtils presentAlertControllerWithError:error completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf exitAction];
            }];
            break;
        }
    }
}

#pragma mark - JMMenuActionsViewProtocol

- (JMMenuActionsViewAction)availableActions
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;

    if (self.shouldShowFiltersPage) {
        availableAction |= JMMenuActionsViewAction_Edit;
    }

    if ([self stateManager].state != JMReportViewerStateInitial) {
        availableAction |= JMMenuActionsViewAction_Refresh;
    }
    availableAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule;
    availableAction |= JMMenuActionsViewAction_Share | JMMenuActionsViewAction_Print;

    // TODO: For now use for show chart types, but there could be other components
    if ([self report].reportComponents.count) {
        availableAction |= JMMenuActionsViewAction_ShowReportChartTypes;
    }
    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate isExternalScreenAvailable]) {
        // TODO: extend by considering other states
        availableAction |= ([self stateManager].state == JMReportViewerStateResourceOnWExternalWindow) ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }

    return availableAction;
}

- (JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsViewAction disabledAction = JMMenuActionsViewAction_None;
    if ([self stateManager].state == JMReportViewerStateResourceNotExist) {
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule | JMMenuActionsViewAction_Print;
    }
    return disabledAction;
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
        case JMMenuActionsViewAction_Refresh:
            [self refreshReport];
            break;
        case JMMenuActionsViewAction_Edit: {
            [self showFiltersVCWithInitialParameters:[self report].reportParameters];
            break;
        }
        case JMMenuActionsViewAction_Save: {
            [self performSegueWithIdentifier:kJMSaveReportViewControllerSegue sender:nil];
            break;
        }
        case JMMenuActionsViewAction_Schedule: {
            [self scheduleReport];
            break;
        }
        case JMMenuActionsViewAction_Print: {
            JMReportViewerState currentState = [self stateManager].state;
            [[self stateManager] setupPageForState:JMReportViewerStateLoading];
            self.configurator.printManager.controller = self;
            [self.configurator.printManager printResource:self.resource completion:^{
                [[self stateManager] setupPageForState:currentState];
            }];
            break;
        }
        case JMMenuActionsViewAction_Share:{
            self.configurator.shareManager.controller = self;
            [self.configurator.shareManager shareContentView:[self contentView]];
            break;
        }
        case JMMenuActionsViewAction_ShowReportChartTypes: {
            [self showReportChartTypesVC];
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
        default:
            break;
    }
}

#pragma mark - JMSaveReportControllerDelegate
- (void)reportDidSavedSuccessfully
{
    [ALToastView toastInView:self.navigationController.view
                    withText:JMLocalizedString(@"report_viewer_save_addedToQueue")];
}

#pragma mark - Input Controls

- (void)showFiltersVCWithInitialParameters:(NSArray <JSReportParameter *> *)initialParameters
{
    JMInputControlsViewController *inputControlsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMInputControlsViewController"];
    BOOL isReportOptionReportActive = ([self report].reportURI != nil) && ![[self report].reportURI isEqualToString:self.resource.resourceLookup.uri];
    inputControlsViewController.reportURI = self.resource.resourceLookup.uri;
    if (isReportOptionReportActive) {
        inputControlsViewController.initialReportOptionURI = [self report].reportURI;
    } else {
        inputControlsViewController.initialReportParameters = initialParameters;
    }

    __weak typeof(self) weakSelf = self;
    inputControlsViewController.completionBlock = ^(JMFiltersVCResult *result) {
        __strong typeof(self) strongSelf = weakSelf;
        switch(result.type) {
            case JMFiltersVCResultTypeNotChange : {
                break;
            }
            case JMFiltersVCResultTypeEmptyFilters : {
                self.warningMessage = JMLocalizedString(@"report_viewer_emptyreport_title");
                if ([strongSelf stateManager].state != JMReportViewerStateResourceReady) {
                    [strongSelf runReportWithDestination:strongSelf.initialDestination];
                }
                break;
            }
            case JMFiltersVCResultTypeReportParameters : {
                self.warningMessage = JMLocalizedString(@"report_viewer_emptyreport_title");
                [strongSelf updateReportWithParameters:result.reportParameters];
                break;
            }
            case JMFiltersVCResultTypeFilterOption : {
                self.warningMessage = JMLocalizedString(@"report_viewer_emptyreport_title");
                [strongSelf runReportWithReportURI:result.filterOptionURI];
                break;
            }
            case JMFiltersVCResultTypeSessionExpired: {
                [strongSelf.sessionManager handleSessionDidChangeWithAlert:NO];
                break;
            }
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];
}

#pragma mark - Scheduling

- (void)scheduleReport
{
    JMScheduleVC *newJobVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    [newJobVC createNewScheduleMetadataWithResourceLookup:self.resource];
    [self.navigationController pushViewController:newJobVC animated:YES];
}

#pragma mark - Bookmarks
- (BOOL)reportHasBookmarks
{
    return [self report].bookmarks != nil && [self report].bookmarks.count > 0;
}

- (void)showBookmarks
{
    JMBookmarksVC *bookmarksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMBookmarksVC"];
    bookmarksVC.bookmarks = [self report].bookmarks;
    __weak __typeof(self) weekSelf = self;
    bookmarksVC.exitBlock = ^(JSReportBookmark *selectedBookmark) {
        __typeof(self) strongSelf = weekSelf;
        [strongSelf.navigationController popToViewController:strongSelf animated:YES];
        JMLog(@"bookmark was selected: %@", selectedBookmark.isSelected ? @"YES" : @"NO");
        [strongSelf navigateToBookmark:selectedBookmark];
    };
    [self.navigationController pushViewController:bookmarksVC animated:YES];
}

#pragma mark - Bookmark Item Helpers
- (void)addBookmarkBarButton
{
    UIBarButtonItem *bookmarkItem = [self findBookmarkBarButton];
    if (bookmarkItem) {
        return;
    } else {
        NSMutableArray *rightNavItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [rightNavItems addObject:[self createBookmarkBarButton]];
        self.navigationItem.rightBarButtonItems = rightNavItems;
    }
}

- (UIBarButtonItem *__nullable)findBookmarkBarButton
{
    UIBarButtonItem *bookmarkItem;
    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
        if (item.action == @selector(showBookmarks)) {
            bookmarkItem = item;
            break;
        }
    }
    return bookmarkItem;
}

- (UIBarButtonItem *)createBookmarkBarButton
{
    UIBarButtonItem *bookmarkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmarks_item"]
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(showBookmarks)];
    return bookmarkItem;
}

#pragma mark - Report Parts Helpers
- (BOOL)reportHasParts
{
    return [self report].parts && [self report].parts.count > 0;
}

#pragma mark - Analytics


- (NSString *)additionalsToScreenName
{
    NSString *additinalString = @"";
    if ([[self reportLoader] isKindOfClass:[JMVisualizeReportLoader class]]) {
        additinalString = @" (VIZ)";
    } else if ([[self reportLoader] isKindOfClass:[JMRestReportLoader class]]) {
        additinalString = @" (REST)";
    }
    return additinalString;
}

#pragma mark - Report Chart Types

- (void)showReportChartTypesVC
{
    __weak __typeof(self) weakSelf = self;
    [[self reportLoader] fetchAvailableChartTypesWithCompletion:^(NSArray<JMReportChartType *> *chartTypes, NSError *error) {
        if (error) {
            [weakSelf handleError:error];
        } else {
            JMReportChartTypesVC *chartTypesVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"JMReportChartTypesVC"];
            chartTypesVC.chartTypes = chartTypes;
            JMReportChartType *selectedChartType = [JMReportChartType new];
            // TODO: extend to support several charts
            JSReportComponent *reportComponent = [weakSelf report].reportComponents.firstObject;
            JSReportComponentChartStructure *chartStructure = (JSReportComponentChartStructure *) reportComponent.structure;
            selectedChartType.name = chartStructure.charttype;
            chartTypesVC.selectedChartType = selectedChartType;
            chartTypesVC.exitBlock = ^(JMReportChartType *chartType) {
                [[weakSelf reportLoader] updateComponent:reportComponent
                                        withNewChartType:chartType
                                              completion:^(BOOL success, NSError *error) {
                                                  if (error) {
                                                      [weakSelf handleError:error];
                                                  } else {
                                                      JMLog(@"success of updating chart type");
                                                  }
                                              }];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            [weakSelf.navigationController pushViewController:chartTypesVC
                                                     animated:YES];
        }
    }];
}

#pragma mark - Work with external window
- (void)showOnTV
{
    [[self stateManager] setupPageForState:JMReportViewerStateResourceOnWExternalWindow];
    [[self externalScreenManager] showContentOnTV];
}

- (void)switchFromTV
{
    [[self stateManager] setupPageForState:JMReportViewerStateResourceReady];
    [[self externalScreenManager] backContentOnDevice];
}

@end
