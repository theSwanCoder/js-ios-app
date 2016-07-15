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
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerPrintManager.h"
#import "JMResourceViewerInfoPageManager.h"


@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMReportPartViewToolbarDelegate>
// TODO: move into separate managers
@property (nonatomic, assign) NSInteger lowMemoryWarningsCount;
@end

@implementation JMReportViewerVC
@synthesize resource = _resource;

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    self.title = self.resource.resourceLookup.label;

    [self addObservers];

    [self setupStateManager];
    [self startResourceViewing];
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
    }
}

#pragma mark - Setups
- (void)setupStateManager
{
    [self stateManager].controller = self;
    __weak __typeof(self) weakSelf = self;
    [self stateManager].backActionBlock = ^{
        [weakSelf exitAction];
    };
    [self stateManager].cancelOperationBlock = ^{
        [weakSelf exitAction];
    };
    [[self stateManager] setupPageForState:JMReportViewerStateInitial];
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
                                             selector:@selector(multipageNotification)
                                                 name:JSReportIsMutlipageDidChangedNotification
                                               object:[self report]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:JSReportCountOfPagesDidChangeNotification
                                               object:[self report]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:JSReportCurrentPageDidChangeNotification
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

- (void)multipageNotification
{
    if ([self report].isMultiPageReport) {
        [[self stateManager] updatePageForToolbarState:JMReportVieweToolbarStateBottomVisible];
    } else {
        [[self stateManager] updatePageForToolbarState:JMReportVieweToolbarStateBottomHidden];
    }
}

- (void)reportLoaderDidChangeCountOfPages:(NSNotification *)notification
{
    self.paginationToolbar.countOfPages = [self report].countOfPages;

    BOOL isReportReady = [self report].countOfPages != NSNotFound;
    if (isReportReady && [self report].isReportEmpty) {
        [[self stateManager] setupPageForState:JMReportViewerStateResourceNotExist];
    }
}

- (void)reportLoaderDidChangeCurrentPage:(NSNotification *)notification
{
    self.paginationToolbar.currentPage = [self report].currentPage;
    if ([self report].parts) {
        [self.reportPartToolbar updateCurrentPartForPage:[self report].currentPage];
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
        if (!self.reportPartToolbar.parts) {
            self.reportPartToolbar.parts = [self report].parts;
        }
        [[self stateManager] updatePageForToolbarState:JMReportVieweToolbarStateTopVisible];
    } else {
        [[self stateManager] updatePageForToolbarState:JMReportVieweToolbarStateTopHidden];
    }
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

- (UIView *)nonExistingResourceView
{
    UILabel *label = [UILabel new];
    label.text = JMCustomLocalizedString(@"report_viewer_emptyreport_title", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

#pragma mark - Actions
- (void)exitAction
{
    [[self stateManager] setupPageForState:JMReportViewerStateDestroy];
    [[self reportLoader] destroy];
    [self resetSubViews];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backActionInWebView
{
    [[self webEnvironment].webView goBack];

    self.initialDestination = nil;
    [self runReportWithDestination:self.initialDestination];
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
            [[strongSelf stateManager] setupPageForState:JMReportViewerStateInitial];
            BOOL isAlwaysPrompt = reportUnit.alwaysPromptControls;
            if (isAlwaysPrompt) {
                [strongSelf showAlwaysPromptAlert];
            } else {
                [strongSelf runReportWithDestination:strongSelf.initialDestination];
            }
        }
    }];
}

- (void)showAlwaysPromptAlert
{
    // TODO: translate
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Input Controls"
                                                                                      message:@"You must apply input values before the report can be displayed."
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          [self exitAction];
                                                                      }];
    __weak typeof(self) weakSelf = self;
    [alertController addActionWithLocalizedTitle:@"dialog_button_ok"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                             __strong typeof(self) strongSelf = weakSelf;
                                             [strongSelf showInputControlsViewControllerWithInitialParameters:nil];
                                         }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)runReportWithDestination:(JSReportDestination *)destination
{
    __weak typeof(self)weakSelf = self;
    void(^completion)(BOOL , NSError *) = ^(BOOL success, NSError *error) {
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

    [[self stateManager] setupPageForState:JMReportViewerStateLoading];

    JSReport *report = [self.resource modelOfResource];
    if ([[self reportLoader] respondsToSelector:@selector(runReport:initialDestination:initialParameters:completion:)]) {
        [[self reportLoader] runReport:report
                  initialDestination:destination
                   initialParameters:self.initialReportParameters
                          completion:completion];
    } else {
        [[self reportLoader] runReport:report
                         initialPage:@(destination.page)
                   initialParameters:self.initialReportParameters
                          completion:completion];
    }
}

- (void)runReportWithReportURI:(NSString *)reportURI
{
    [[self stateManager] setupPageForState:JMReportViewerStateLoading];

    __weak typeof(self)weakSelf = self;
    [[self reportLoader] runReportWithReportURI:reportURI
                                  initialPage:nil
                            initialParameters:nil
                                   completion:^(BOOL success, NSError *error) {
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
                                   }];
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

- (JMResourceViewerStateManager *)stateManager
{
    return self.configurator.stateManager;
}

#pragma mark - Handle Low Memory
- (void)didReceiveMemoryWarning
{
    // Skip first warning.
    // TODO: Consider replace this approach.
    //
    if (self.lowMemoryWarningsCount++ >= 1) {
        [self handleLowMemory];
    }

    [super didReceiveMemoryWarning];
}

- (void)handleLowMemory
{
    [self.restClient cancelAllRequests];

    // TODO: move into separate manager
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self resetSubViews];

    NSString *errorMessage = JMCustomLocalizedString(@"resource_viewer_memory_warning", nil);
    NSError *error = [NSError errorWithDomain:@"dialod_title_attention" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    __weak typeof(self) weakSelf = self;
    [JMUtils presentAlertControllerWithError:error completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf exitAction];
    }];
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
        case JSReportLoaderErrorTypeAuthentification:
        case JSSessionExpiredErrorCode: {
            if (self.restClient.keepSession) {
                __weak typeof(self) weakSelf = self;
                JMLog(@"Handle session expired");
                if (![JMUtils isSupportVisualize]) {
                    // TODO: udpate rest loader to be able reuse
                    [[self reportLoader] cancel];
                    self.configurator = nil;
                } else if (![JMUtils isSystemVersion9] && [JMUtils isSupportVisualize]) {
                    [[self webEnvironment] reset];
                    // TODO: fix this
//                    [[JMWebViewManager sharedInstance] removeWebEnvironmentWithId:[self currentWebEnvironmentIdentifier]];
//                    self.webEnvironment = nil;
                    self.configurator = nil;
                }
                [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult *_Nullable result) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (!result.error) {
                        [strongSelf showSessionExpiredAlert];
                    } else {
                        __weak typeof(self) weakSelf = strongSelf;
                        [JMUtils showLoginViewAnimated:YES completion:^{
                            __strong typeof(self) strongSelf = weakSelf;
                            [strongSelf exitAction];
                        }];
                    }
                }];
            } else {
                __weak typeof(self) weakSelf = self;
                [JMUtils showLoginViewAnimated:YES completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf exitAction];
                }];
            }
            break;
        }
        case JSReportLoaderErrorTypeEmtpyReport:
            // TODO: this isn't an error
            [[self stateManager] setupPageForState:JMReportViewerStateResourceNotExist];
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

- (void)showSessionExpiredAlert
{
    // TODO: add translations
    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"Session was expired"
                                                                                      message:@"Reload?"
                                                                            cancelButtonTitle:@"dialog_button_cancel"
                                                                      cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                                          [self exitAction];
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

#pragma mark - WebView helpers
- (void)resetSubViews
{
    [[self webEnvironment] resetZoom];
    [[self webEnvironment].webView removeFromSuperview];

    // TODO: fix this
//    self.webEnvironment = nil;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [[self stateManager] hideMenuView];
    // TODO: add handling of other actions
    switch (action) {
        case JMMenuActionsViewAction_Info: {
            self.configurator.infoPageManager.controller = self;
            [self.configurator.infoPageManager showInfoPageForResource:self.resource];
            break;
        }
        case JMMenuActionsViewAction_Refresh:
            [self refreshReport];
            break;
        case JMMenuActionsViewAction_Edit: {
            [self showInputControlsViewControllerWithInitialParameters:[self report].reportParameters];
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
            JMReportViewerState currentState = [self stateManager].activeState;
            [[self stateManager] setupPageForState:JMReportViewerStateLoading];
            self.configurator.printManager.controller = self;
            [self.configurator.printManager printResource:self.resource completion:^{
                [[self stateManager] setupPageForState:currentState];
            }];
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
                    withText:JMCustomLocalizedString(@"report_viewer_save_addedToQueue", nil)];
}

#pragma mark - Input Controls

- (void)showInputControlsViewControllerWithInitialParameters:(NSArray <JSReportParameter *> *)initialParameters
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
    inputControlsViewController.completionBlock = ^(NSArray <JSReportParameter *> *reportParameters, NSString *reportOptionURI) {
        __strong typeof(self) strongSelf = weakSelf;
        if (reportParameters) {
            [strongSelf updateReportWithParameters:reportParameters];
        } else if (reportOptionURI) {
            [strongSelf runReportWithReportURI:reportOptionURI];
        } else {
            // For now do nothing.
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
    };

    [self.navigationController pushViewController:inputControlsViewController animated:YES];
}

#pragma mark - Scheduling

- (void)scheduleReport
{
    JMScheduleVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
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

@end
