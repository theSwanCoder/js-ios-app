/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportViewerVC.h"
#import "JMBaseResourceView.h"
#import "JMReportViewerConfigurator.h"
#import "JMSaveReportViewController.h"
#import "ALToastView.h"
#import "JMInputControlsViewController.h"
#import "JMReportViewerToolBar.h"
#import "JMScheduleVC.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMBookmarksVC.h"
#import "JMReportPartViewToolbar.h"
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerInfoPageManager.h"
#import "JMResourceViewerShareManager.h"
#import "JMResourceViewerSessionManager.h"
#import "PopoverView.h"
#import "JMFiltersVCResult.h"
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
#import "JMResourceViewerHyperlinksManager.h"
#import "JMResourceViewerFavoritesHelper.h"
#import "JMReportViewerStateManager.h"

@interface JMReportViewerVC () <JMSaveResourceViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMReportPartViewToolbarDelegate, JMResourceViewerStateManagerDelegate>
// TODO: temporary solution, remove in the next release
@property (nonatomic, strong) JMFiltersNetworkManager *filtersNetworkManager;
@property (nonatomic, assign) BOOL shouldShowFiltersActionInMenu;
@property (nonatomic, copy) void(^runReportCompletion)(BOOL success, NSError *error);
@property (nonatomic, copy) NSString *warningMessage;
@end

@implementation JMReportViewerVC
@synthesize resource = _resource;

#pragma mark - Lifecycle
- (void)dealloc
{
    [self removeAllObservers];
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
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
            [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
        } else {
            [strongSelf handleError:error];
        }
    };

    [self startResourceViewing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self stateManager] setupPageForState:JMResourceViewerStateNotVisible];
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

#pragma mark - Setups

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
        [[strongSelf reportLoader] resetWithCompletion:^{
            [strongSelf.configurator setup];
            [[strongSelf reportLoader] setDelegate:strongSelf];
            [strongSelf setupStateManager];

            [strongSelf startResourceViewing];
        }];
    };
    self.configurator.sessionManager.exitAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    };
}

- (void)setupStateManager
{
    [self stateManager].controller = self;
    [self stateManager].delegate = self;
    [[self stateManager] setupPageForState:JMResourceViewerStateInitial];
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
        [[self stateManager] setupPageForState:JMResourceViewerStateResourceNotExist];
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

#pragma mark - JMResourceViewerProtocol
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
    if (stateManager.state == JMResourceViewerStateLoadingForPrint) {
        [self.configurator.printManager cancel];
    } else {
        // TODO: consider cases when these actions should be separated
        [self cancelAction];
        [self exitAction];
    }

}

- (void)stateManagerWillBackFromNestedResource:(JMResourceViewerStateManager *)stateManager
{
    [self backActionInWebView];
}

#pragma mark - Actions
- (void)exitAction
{
    [self.filtersNetworkManager reset];
    [[self stateManager] setupPageForState:JMResourceViewerStateDestroy];
    if ([[self reportLoader] respondsToSelector:@selector(destroyWithCompletion:)]) {
        [[self reportLoader] destroyWithCompletion:nil];
    } else {
        [[self reportLoader] reset];
    }
    [[self webEnvironment] reset];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [[self reportLoader] cancel];
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
    [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
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
                    [[strongSelf stateManager] setupPageForState:JMResourceViewerStateInitial];
                    strongSelf.shouldShowFiltersActionInMenu = inputControls.count > 0;
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

    [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
    JSReport *report = [self.resource modelOfResource];
    [[self reportLoader] runReport:report
                initialDestination:destination
                 initialParameters:self.initialReportParameters
                        completion:self.runReportCompletion];
}

- (void)runReportWithReportURI:(NSString *)reportURI
{
    // here we'll have a new instance of report
    [self removeReportPropertiesObservers];

    [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
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
            [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
            __weak typeof(self)weakSelf = self;
            [[self reportLoader] applyReportParameters:reportParameters
                                          completion:^(BOOL success, NSError *error) {
                                              __strong typeof(self)strongSelf = weakSelf;
                                              if (success) {
                                                  [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
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
        [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
    }
    __weak typeof(self)weakSelf = self;
    [[self reportLoader] fetchPage:@(page)
                      completion:^(BOOL success, NSError *error) {
                          __strong typeof(self)strongSelf = weakSelf;
                          if (success) {
                              completion(YES);
                              if ([[self reportLoader] respondsToSelector:@selector(shouldDisplayLoadingView)] && [[self reportLoader] shouldDisplayLoadingView]) {
                                  [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
                              }
                          } else {
                              [strongSelf handleError:error];
                          }
                      }];
}

- (void)navigateToBookmark:(JSReportBookmark *__nonnull)bookmark
{
    if ([[self reportLoader] respondsToSelector:@selector(navigateToBookmark:completion:)]) {
        [[self stateManager] setupPageForState:JMResourceViewerStateLoading];
        __weak __typeof(self) weakSelf = self;
        [[self reportLoader] navigateToBookmark:bookmark completion:^(BOOL success, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
            }
        }];
    }
}

- (void)refreshReport
{
    [[self stateManager] setupPageForState:JMResourceViewerStateLoading];

    __weak typeof(self)weakSelf = self;
    [[self reportLoader] refreshReportWithCompletion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        if (success) {
            [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
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
    return (JMReportViewerStateManager *)self.configurator.stateManager;
}

- (JMReportViewerExternalScreenManager *)externalScreenManager
{
    return (JMReportViewerExternalScreenManager *)self.configurator.externalScreenManager;
}

- (BOOL)shouldWorkWithChartTypes
{
    return [JMUtils isServerProEdition] && [JMUtils isServerVersionUpOrEqual6];
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

        [[self stateManager] setupPageForState:JMResourceViewerStateLoading];

        __weak typeof(self)weakSelf = self;
        [[self reportLoader] navigateToPart:toolbar.currentPart completion:^(BOOL success, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (error) {
                [strongSelf handleError:error];
            } else {
                [[strongSelf stateManager] setupPageForState:JMResourceViewerStateResourceReady];
            }
        }];
    }
}

#pragma mark - Handler Errors

- (void)handleError:(NSError *)error
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceFailed];

    switch (error.code) {
        case JSReportLoaderErrorTypeSessionDidExpired: {
            [self.configurator.sessionManager handleSessionDidExpire];
            break;
        }
        case JSReportLoaderErrorTypeSessionDidRestore: {
            [self.configurator.sessionManager handleSessionDidRestore];
            break;
        }
        case JSReportLoaderErrorTypeEmtpyReport:
            // TODO: this isn't an error
            break;
        case JSReportLoaderErrorTypeUndefined:
            [JMUtils presentAlertControllerWithError:error
                                          completion:nil];
            break;
        // TODO: Does this case still work?
//        case JSInvalidCredentialsErrorCode: {
//            [JMUtils showLoginViewAnimated:YES completion:^{
//                [self exitAction];
//            }];
//            break;
//        }
        case JSReportLoaderErrorTypeLoadingCanceled: {
            // TODO: consider cases when these actions should be separated
            [self cancelAction];
            [self exitAction];
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

    if (self.shouldShowFiltersActionInMenu) {
        availableAction |= JMMenuActionsViewAction_Edit;
    }

    if ([self stateManager].state != JMResourceViewerStateInitial) {
        availableAction |= JMMenuActionsViewAction_Refresh;
    }
    availableAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule;
    availableAction |= JMMenuActionsViewAction_Share | JMMenuActionsViewAction_Print;

    if (![[self stateManager].favoritesHelper shouldShowFavoriteBarButton]) {
        availableAction |= ([[self stateManager].favoritesHelper isResourceInFavorites] ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite);
    }
    // TODO: For now use for show chart types, but there could be other components
    if ([self report].reportComponents.count && [self shouldWorkWithChartTypes]) {
        availableAction |= JMMenuActionsViewAction_ShowReportChartTypes;
    }
    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate isExternalScreenAvailable]) {
        // TODO: extend by considering other states
        availableAction |= ([self stateManager].state == JMResourceViewerStateResourceOnWExternalWindow) ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }

    return availableAction;
}

- (JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsViewAction disabledAction = JMMenuActionsViewAction_None;
    if ([self stateManager].state == JMResourceViewerStateResourceNotExist) {
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
            [self saveReport];
            break;
        }
        case JMMenuActionsViewAction_Schedule: {
            [self scheduleReport];
            break;
        }
        case JMMenuActionsViewAction_Print: {
            JMResourceViewerState currentState = [self stateManager].state;
            [[self stateManager] setupPageForState:JMResourceViewerStateLoadingForPrint];
            self.configurator.printManager.controller = self;
            [self.configurator.printManager printResource:self.resource
                                     prepearingCompletion:^{
                                         [[self stateManager] setupPageForState:currentState];
                                     } printCompletion:nil];
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

#pragma mark - JMSaveResourceViewControllerDelegate
- (void)resourceDidSavedSuccessfully
{
    [ALToastView toastInView:self.navigationController.view
                    withText:JMLocalizedString(@"resource_viewer_save_addedToQueue")];
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
                if ([strongSelf stateManager].state != JMResourceViewerStateResourceReady) {
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
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];
}
    
- (void)saveReport
{
    JMSaveReportViewController *saveReportVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMSaveReportViewController"];
    saveReportVC.report = self.report;
    saveReportVC.delegate = self;
    __weak __typeof(self) weakSelf = self;
    saveReportVC.sessionExpiredBlock = ^{
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.configurator.sessionManager handleSessionDidExpire];
    };

    [self.navigationController pushViewController:saveReportVC animated:YES];
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
        __strong __typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf handleError:error];
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
                [[strongSelf reportLoader] updateComponent:reportComponent
                                          withNewChartType:chartType
                                                completion:^(BOOL success, NSError *error) {
                                                    if (error) {
                                                        [strongSelf handleError:error];
                                                    } else {
                                                        JMLog(@"success of updating chart type");
                                                    }
                                              }];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            };
            [strongSelf.navigationController pushViewController:chartTypesVC
                                                       animated:YES];
        }
    }];
}

#pragma mark - Work with external window
- (void)showOnTV
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceOnWExternalWindow];
    [[self externalScreenManager] showContentOnTV];
}

- (void)switchFromTV
{
    [[self stateManager] setupPageForState:JMResourceViewerStateResourceReady];
    [[self externalScreenManager] backContentOnDevice];
}

@end
