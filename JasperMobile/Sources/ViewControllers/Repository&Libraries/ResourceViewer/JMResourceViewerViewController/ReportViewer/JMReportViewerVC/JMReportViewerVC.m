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
#import "JSResourceLookup+Helpers.h"
#import "JMReportViewerConfigurator.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptNativeBridge.h"
#import "JMWebViewManager.h"
#import "JMSaveReportViewController.h"
#import "ALToastView.h"
#import "JMInputControlsViewController.h"
#import "JMReportViewerToolBar.h"
#import "JMExternalWindowControlsVC.h"
#import "JMNewScheduleVC.h"
#import "JMWebEnvironment.h"

NSString * const kJMReportViewerPrimaryWebEnvironmentIdentifier = @"kJMReportViewerPrimaryWebEnvironmentIdentifier";
NSString * const kJMReportViewerSecondaryWebEnvironmentIdentifier = @"kJMReportViewerSecondaryWebEnvironmentIdentifier";

@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMExternalWindowControlViewControllerDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, copy) void(^exportCompletion)(NSString *resourcePath);
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *emptyReportMessageLabel;
@property (nonatomic, strong, readwrite) JMReport *report;
@property (nonatomic, strong) NSArray *initialReportParameters;
@property (nonatomic, assign) BOOL isReportAlreadyConfigured;
@property (nonatomic) JMExternalWindowControlsVC *controlsViewController;
@property (nonatomic, strong) JMWebEnvironment *webEnvironment;
@property (nonatomic, assign) BOOL wasAuthError;
@end

@implementation JMReportViewerVC

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    JMLog(@"horizontal size class: %@", @(newCollection.horizontalSizeClass));
    JMLog(@"vertical size class: %@", @(newCollection.verticalSizeClass));

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureReport];

    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configViewport];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateToobarAppearence];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_toolbar removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kJMSaveReportViewControllerSegue]) {
        JMSaveReportViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.report = self.report;
        destinationViewController.delegate = self;
    }
}

#pragma mark - Observe Notifications
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(multipageNotification)
                                                 name:kJSReportIsMutlipageDidChangedNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:kJSReportCountOfPagesDidChangeNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:kJSReportCurrentPageDidChangeNotification
                                               object:self.report];
}

- (void)multipageNotification
{
    [self updateToobarAppearence];
}

- (void)reportLoaderDidChangeCountOfPages:(NSNotification *)notification
{
    self.toolbar.countOfPages = self.report.countOfPages;
    [self handleReportLoaderDidChangeCountOfPages];
}

- (void)reportLoaderDidChangeCurrentPage:(NSNotification *)notification
{
    self.toolbar.currentPage = self.report.currentPage;
}

#pragma mark - Actions
- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if (!self.isChildReport) {
        [self stopShowLoader];

        if (![self.restClient isRequestPoolEmpty]) {
            [self.restClient cancelAllRequests];
        }
        if (self.exitBlock) {
            self.exitBlock();
        }

        if ([self isContentOnTV]) {
            [self hideExternalWindowWithCompletion:nil];
        }
    }
    [super cancelResourceViewingAndExit:exit];
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    BOOL isReportReady = self.report.countOfPages != NSNotFound;
    if (isReportReady && self.report.isReportEmpty) {
        [self showEmptyReportMessage];
    }
}

#pragma mark - Notifications
- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    [self.toolbar endEditing:YES];
}

#pragma mark - Setups

- (void)configViewport
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if ([self isContentOnTV]) {
        return;
    }

    CGFloat initialScaleViewport = 0.75;
    if ([JMUtils isSupportVisualize]) {
        BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
        if (isCompactWidth) {
            initialScaleViewport = 0.25;
        }
    } else {
        initialScaleViewport = 2;
        if ([JMUtils isCompactWidth] || [JMUtils isCompactHeight]) {
            initialScaleViewport = 1;
        }
    }

    if ([self.reportLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        [self.reportLoader updateViewportScaleFactorWithValue:initialScaleViewport];
    }
}

- (UIView *)resourceView
{
    return self.webEnvironment.webView;
}

- (void)setupSubviews
{
    self.webEnvironment = [self currentWebEnvironment];
    self.configurator = [JMReportViewerConfigurator configuratorWithReport:self.report
                                                            webEnvironment:self.webEnvironment];
    [self.configurator updateReportLoaderDelegateWithObject:self];

    [super setupSubviews];
}

- (void)updateToobarAppearence
{
    if (self.toolbar && self.report.isMultiPageReport && !self.report.isReportEmpty) {
        self.toolbar.currentPage = self.report.currentPage;
        if (self.navigationController.visibleViewController == self) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Overloaded methods
- (void) startResourceViewing
{
    // empty method because parent call it from viewDidLoad
    // there is issue with "white screen" after loading input controls
    // until current view doesn't appear (on iOS 7)
}

- (void)startLoadReportWithPage:(NSInteger)page
{
    BOOL isReportAlreadyLoaded = self.report.isReportAlreadyLoaded;
    BOOL isReportInLoadingProcess = self.reportLoader.isReportInLoadingProcess;

    JMLog(@"report parameters: %@", self.report.reportParameters);
    JMLog(@"report input controls: %@", self.report.activeReportOption.inputControls);

    if(!isReportAlreadyLoaded && !isReportInLoadingProcess) {
        // show report with loaded input controls
        // when we start running a report from another report by tapping on hyperlink
        [self runReportWithPage:page];
    }
}

- (void)configureReport
{
    __weak typeof(self) weakSelf = self;
    void(^errorHandlingBlock)(NSError *, NSString *) = ^(NSError *error, NSString *errorMessage) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        JMLog(@"%@: %@", errorMessage, error);

        [strongSelf handleError:error];
    };

    NSString *reportURI = self.resourceLookup.uri;

    [self startShowLoaderWithMessage:@"status.loading"];
    [self.restClient resourceLookupForURI:reportURI resourceType:kJS_WS_TYPE_REPORT_UNIT
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:^(JSOperationResult *result) {
                              __strong typeof(self)strongSelf = weakSelf;
                              if (result.error) {
                                  errorHandlingBlock(result.error, @"Report Unit Loading Error");
                              } else {
                                  JSResourceReportUnit *reportUnit = result.objects.firstObject;
                                  if (reportUnit) {
                                      // get report input controls
                                      __weak typeof(self) weakSelf = strongSelf;
                                      [strongSelf.restClient inputControlsForReport:reportURI ids:nil selectedValues:nil completionBlock:^(JSOperationResult * _Nullable result) {
                                          __strong typeof(self) strongSelf = weakSelf;
                                          if (result.error) {
                                              errorHandlingBlock(result.error, @"Report Input Controls Loading Error");
                                          } else {
                                              NSMutableArray *visibleInputControls = [NSMutableArray array];
                                              for (JSInputControlDescriptor *inputControl in result.objects) {
                                                  if (inputControl.visible.boolValue) {
                                                      [visibleInputControls addObject:inputControl];
                                                  }
                                              }

                                              if ([visibleInputControls count]) {
                                                  [strongSelf.report generateReportOptionsWithInputControls:visibleInputControls];

                                                  // get report options
                                                  __weak typeof(self) weakSelf = strongSelf;
                                                  [strongSelf.restClient reportOptionsForReportURI:strongSelf.report.reportURI completion:^(JSOperationResult * _Nullable result) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      if (result.error && result.error.code == JSSessionExpiredErrorCode) {
                                                          errorHandlingBlock(result.error, @"Report Options Loading Error");
                                                      } else {
                                                          [strongSelf stopShowLoader];
                                                          strongSelf.isReportAlreadyConfigured = YES;
                                                          NSMutableArray *reportOptions = [NSMutableArray array];
                                                          for (id reportOption in result.objects) {
                                                              if ([reportOption isKindOfClass:[JSReportOption class]] && [reportOption identifier]) {
                                                                  [reportOptions addObject:reportOption];
                                                              }
                                                          }

                                                          [strongSelf.report addReportOptions:reportOptions];

                                                          if ([reportOptions count] || (reportUnit.alwaysPromptControls && [visibleInputControls count])) {
                                                              [strongSelf showInputControlsViewControllerWithBackButton:YES];
                                                          } else  {
                                                              if (strongSelf.initialReportParameters) {
                                                                  [strongSelf.report updateReportParameters:strongSelf.initialReportParameters];
                                                              }
                                                              [strongSelf startLoadReportWithPage:1];
                                                          }
                                                      }
                                                  }];
                                              } else {
                                                  [strongSelf stopShowLoader];
                                                  [strongSelf startLoadReportWithPage:1];
                                              }
                                          }
                                      }];
                                  } else {
                                      NSDictionary *userInfo = @{NSURLErrorFailingURLErrorKey : @"Report Unit Loading Error"};
                                      NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:JSClientErrorCode userInfo:userInfo];
                                      __weak typeof(self) weakSelf = strongSelf;
                                      [JMUtils presentAlertControllerWithError:error completion:^{
                                          __strong typeof(self) strongSelf = weakSelf;
                                          [strongSelf cancelResourceViewingAndExit:YES];
                                      }];
                                  }
                              }
                          }];
}

- (void)handleLowMemory
{
    [self.restClient cancelAllRequests];
    [super handleLowMemory];
}

#pragma mark - Print
- (void)printResource
{
    // TODO: we don't have events when JIVE is applied to a report.
    [super printResource];
    
    [self preparePreviewForPrintWithCompletion:^(NSURL *resourceURL) {
        if (resourceURL) {
            [self printItem:resourceURL
                   withName:self.report.resourceLookup.label
                 completion:^(BOOL completed, NSError *error){
                     [self removeResourceWithURL:resourceURL];
                     if(error){
                         JMLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
                     }
                 }];
        }
    }];
}

- (void)preparePreviewForPrintWithCompletion:(void(^)(NSURL *resourceURL))completion
{
    JSReportSaver *reportSaver = [[JSReportSaver alloc] initWithReport:self.report restClient:self.restClient];
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
        [reportSaver cancelSavingReport];
    }];
    
    NSString *reportName = [self tempReportName];
    [reportSaver saveReportWithName:reportName
                             format:kJS_CONTENT_TYPE_PDF
                         pagesRange:[JSReportPagesRange allPagesRange]
                         completion:^(NSURL * _Nullable savedReportURL, NSError * _Nullable error) {
                             [JMCancelRequestPopup dismiss];
                             if (error) {
                                 if (error.code == JSSessionExpiredErrorCode) {
                                     [JMUtils showLoginViewAnimated:YES completion:nil];
                                 } else {
                                     [JMUtils presentAlertControllerWithError:error completion:nil];
                                 }
                             } else {
                                 NSString *fullReportName = [reportName stringByAppendingPathExtension:kJS_CONTENT_TYPE_PDF];
                                 NSURL *reportURL = [savedReportURL URLByAppendingPathComponent:fullReportName];
                                 if (completion) {
                                     completion(reportURL);
                                 }
                             }
                         }];
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

- (void)removeResourceWithURL:(NSURL *)resourceURL
{
    NSString *directoryPath = [resourceURL.path stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

#pragma mark - Custom accessors
- (JMWebEnvironment *)currentWebEnvironment
{
    JMWebEnvironment *webEnvironment = [[JMWebViewManager sharedInstance] webEnvironmentForId:[self currentWebEnvironmentIdentifier]];
    return webEnvironment;
}

- (NSString *)currentWebEnvironmentIdentifier
{
    NSString *webEnvironmentIdentifier;
    if (self.isChildReport) {
        webEnvironmentIdentifier = kJMReportViewerSecondaryWebEnvironmentIdentifier;
    } else {
        webEnvironmentIdentifier = kJMReportViewerPrimaryWebEnvironmentIdentifier;
    }
    return webEnvironmentIdentifier;
}

- (id<JMReportLoaderProtocol>)reportLoader
{
    return [self.configurator reportLoader];
}

- (JMReport *)report
{
    if (!_report) {
        _report = [self.resourceLookup reportModel];
    }
    return _report;
}

- (JMReportViewerToolBar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerToolBar" owner:self options:nil] firstObject];
        _toolbar.toolbarDelegate = self;
        _toolbar.currentPage = self.report.currentPage;
        _toolbar.countOfPages = self.report.countOfPages;
        _toolbar.frame = self.navigationController.toolbar.bounds;
        [self.navigationController.toolbar addSubview: _toolbar];
    }
    return _toolbar;
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar changeFromPage:(NSInteger)fromPage toPage:(NSInteger)toPage
{
    toolbar.enable = NO;
    [self.webEnvironment resetZoom];

    __weak typeof(self)weakSelf = self;
    void(^changePageCompletion)(BOOL, NSError*) = ^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        if (success) {
            toolbar.enable = YES;
            [strongSelf.report updateCurrentPage:toPage];
            if (![JMUtils isSupportVisualize]) {
                // fix an issue in webview after zooming and changing page (black areas)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([strongSelf isContentOnTV]) {
                        if ([strongSelf.reportLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
                            [strongSelf.reportLoader updateViewportScaleFactorWithValue:3];
                        }
                    }
                });
            }

            if ([strongSelf isContentOnTV]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf.controlsViewController updateInterface];
                });
            }
        } else {
            [strongSelf handleError:error];
        }
    };
    if ([self.reportLoader respondsToSelector:@selector(shouldDisplayLoadingView)] && [self.reportLoader shouldDisplayLoadingView]) {
        [self startShowLoaderWithMessage:@"status.loading"];
    }
    [self.reportLoader fetchPageNumber:toPage withCompletion:changePageCompletion];
}

#pragma mark - Run report
- (void)runReportWithPage:(NSInteger)page
{
    [self hideEmptyReportMessage];
    [self hideToolbar];
    [self hideReportView];
    self.toolbar.enable = NO;

    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status.loading"];
    [self.reportLoader runReportWithPage:page completion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        strongSelf.toolbar.enable = YES;

        if (success) {
            // Analytics
            NSString *label = [JMUtils isSupportVisualize] ? kJMAnalyticsResourceEventLabelReportVisualize : kJMAnalyticsResourceEventLabelReportREST;
            [JMUtils logEventWithInfo:@{
                                kJMAnalyticsCategoryKey      : kJMAnalyticsResourceEventCategoryTitle,
                                kJMAnalyticsActionKey        : kJMAnalyticsResourceEventActionOpenTitle,
                                kJMAnalyticsLabelKey         : label
                        }];

            [strongSelf showReportView];

            if ([strongSelf isContentOnTV]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf.controlsViewController updateInterface];
                });
            }
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)updateReportWithNewActiveReportOption:(JSReportOption *)newActiveOption
{
    NSString *currentReportURI = self.report.activeReportOption.uri;
    NSString *reportOptionURI = newActiveOption.uri;

    BOOL isURIChanged = YES;
    if (currentReportURI == nil && reportOptionURI == nil) {
        isURIChanged = NO;
    } else if (currentReportURI != nil && reportOptionURI == nil) {
        isURIChanged = YES;
    } else if (currentReportURI == nil && reportOptionURI != nil) {
        isURIChanged = YES;
    } else if ([currentReportURI isEqualToString:reportOptionURI]) {
        isURIChanged = NO;
    }

    self.report.activeReportOption = newActiveOption;
    if (self.report.isReportAlreadyLoaded && !isURIChanged) {
        [self hideEmptyReportMessage];
        [self hideToolbar];
        [self hideReportView];

        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:@"status.loading"];
        [self.reportLoader applyReportParametersWithCompletion:^(BOOL success, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            [strongSelf stopShowLoader];

            if (success) {
                [strongSelf showReportView];
                if ([strongSelf isContentOnTV]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf.controlsViewController updateInterface];
                    });
                }
            } else {
                [strongSelf handleError:error];
            }
        }];
    } else {
        self.report.isReportAlreadyLoaded = NO;
        [self runReportWithPage:1];
    }
}

#pragma mark - JMRefreshable
- (void)refresh
{
    [self.report restoreDefaultState];
    [self updateToobarAppearence];
    [self runReportWithPage:1];
}

- (void)refreshReport
{
    [self hideEmptyReportMessage];
    [self hideToolbar];
    [self hideReportView];
    
    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status.loading"];
    
    [self.reportLoader refreshReportWithCompletion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        
        if (success) {
            [strongSelf showReportView];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)handleError:(NSError *)error
{
    switch (error.code) {
        case JSReportLoaderErrorTypeAuthentification:
            [self.restClient deleteCookies];
            [self resetSubViews];
            [[JMWebViewManager sharedInstance] removeWebEnvironmentForId:[self currentWebEnvironmentIdentifier]];

            NSInteger reportCurrentPage = self.report.currentPage;
            [self.report restoreDefaultState];
            [self.report updateCurrentPage:reportCurrentPage];
            // Here 'break;' doesn't need, because we should try to create new session and reload report
        case JSSessionExpiredErrorCode:
            [self setupSubviews];
            [self configViewport];

            if (self.restClient.keepSession) {
                if (!self.wasAuthError) {
                    self.wasAuthError = YES;

                    __weak typeof(self)weakSelf = self;
                    [self startShowLoaderWithMessage:@"status.loading"];
                    [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                        __strong typeof(self)strongSelf = weakSelf;
                        [strongSelf stopShowLoader];
                        if (isSessionAuthorized) {
                            // TODO: Need add restoring for current page
                            [strongSelf runReportWithPage:self.report.currentPage];
                        } else {
                            [JMUtils showLoginViewAnimated:YES completion:^{
                                [strongSelf cancelResourceViewingAndExit:YES];
                            }];
                        }
                    }];
                } else {
                    __weak typeof(self) weakSelf = self;
                    [JMUtils presentAlertControllerWithError:error completion:^{
                        __strong typeof(self) strongSelf = weakSelf;
                        [strongSelf cancelResourceViewingAndExit:YES];
                    }];
                }
            } else {
                [JMUtils showLoginViewAnimated:YES completion:^{
                    [self cancelResourceViewingAndExit:YES];
                }];
            }
            break;
        case JSReportLoaderErrorTypeEmtpyReport:
            [self showEmptyReportMessage];
            break;
        default: {
            __weak typeof(self) weakSelf = self;
            [JMUtils presentAlertControllerWithError:error completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
            break;
        }
    }
}

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(id<JMReportLoaderProtocol>)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *)resourceLookup withParameters:(NSArray *)reportParameters
{
    JMReportViewerVC *reportViewController = (JMReportViewerVC *) [self.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
    reportViewController.resourceLookup = resourceLookup;
    reportViewController.initialReportParameters = reportParameters;
    reportViewController.isChildReport = YES;
    [self.navigationController pushViewController:reportViewController animated:YES];
}

- (void)reportLoader:(id<JMReportLoaderProtocol>)reportLoader didReceiveOnClickEventWithError:(NSError *)error
{
    [JMUtils presentAlertControllerWithError:error completion:nil];
}

-(void)reportLoader:(id<JMReportLoaderProtocol>)reportLoder didReceiveOnClickEventForReference:(NSURL *)urlReference
{
    [[UIApplication sharedApplication] openURL:urlReference];
}

- (void)reportLoader:(id<JMReportLoaderProtocol>)reportLoader didReceiveOutputResourcePath:(NSString *)resourcePath fullReportName:(NSString *)fullReportName
{
    // sample
    // [self.reportLoader exportReportWithFormat:@"pdf"];
    // html format currently vis.js doesn't support
    // here we can receive link on file.
    if (self.exportCompletion) {
        self.exportCompletion(resourcePath);
        self.exportCompletion = nil;
    }
}

#pragma mark - WebView helpers
- (void)resetSubViews
{
    [self.reportLoader destroy];
    [self.webEnvironment resetZoom];
    [self.webEnvironment.webView removeFromSuperview];

    self.webEnvironment = nil;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    switch (action) {
        case JMMenuActionsViewAction_Refresh:
            [self refreshReport];
            break;
        case JMMenuActionsViewAction_Edit: {
            [self showInputControlsViewControllerWithBackButton:NO];
            break;
        }
        case JMMenuActionsViewAction_Save:
            // TODO: change save action
            [self performSegueWithIdentifier:kJMSaveReportViewControllerSegue sender:nil];
            break;
        case JMMenuActionsViewAction_Schedule: {
            [self scheduleReport];
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
        default:
            break;
    }
}

#pragma mark - JMSaveReportControllerDelegate
- (void)reportDidSavedSuccessfully
{
    [ALToastView toastInView:self.navigationController.view
                    withText:JMCustomLocalizedString(@"report.viewer.save.addedToQueue", nil)];
}

#pragma mark - Input Controls
- (void)showInputControlsViewControllerWithBackButton:(BOOL)isShowBackButton
{
    JMInputControlsViewController *inputControlsViewController = (JMInputControlsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"JMInputControlsViewController"];
    inputControlsViewController.report = self.report;
    
    __weak typeof(self) weakSelf = self;
    inputControlsViewController.completionBlock = ^(JSReportOption *reportOption) {
        __strong typeof(self) strongSelf = weakSelf;
        if (reportOption) {
            [strongSelf updateReportWithNewActiveReportOption:reportOption];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        } else {
            if (!strongSelf.report.isReportAlreadyLoaded) {
                NSMutableArray *viewControllers = [strongSelf.navigationController.viewControllers mutableCopy];
                while (![[viewControllers lastObject] isKindOfClass:NSClassFromString(@"JMBaseCollectionViewController")]) {
                    [viewControllers removeLastObject];
                }
                [strongSelf.navigationController popToViewController:[viewControllers lastObject] animated:YES];
            }
        }
    };

    if (isShowBackButton) {
        UIBarButtonItem *backItem = [self backBarButtonItemWithTarget:inputControlsViewController
                                                               action:@selector(backButtonTapped:)];
        inputControlsViewController.navigationItem.leftBarButtonItem = backItem;
    }

    // There is issue in iOS 7 if self.view is not appeared, we can see white screen after pushing another VC
    while (!self.view.superview) {
        // wait
        [NSThread sleepForTimeInterval:0.25f];
    }

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

#pragma mark - Helpers
- (void)startShowLoaderWithMessage:(NSString *)message
{
    __weak typeof(self) weakSelf = self;
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.reportLoader cancel];
        [strongSelf cancelResourceViewingAndExit:YES];
    }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = [super availableActionForResource:resource] | JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule;
    if (self.report.isReportWithInputControls) {
        availableAction |= JMMenuActionsViewAction_Edit;
    }
    if ([self isReportReady] && !self.report.isReportEmpty) {
        availableAction |= JMMenuActionsViewAction_Refresh;
    }
    if ([self isExternalScreenAvailable]) {
        availableAction |= [self isContentOnTV] ?  JMMenuActionsViewAction_HideExternalDisplay : JMMenuActionsViewAction_ShowExternalDisplay;
    }
    return availableAction;
}

- (JMMenuActionsViewAction)disabledActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction disabledAction = [super disabledActionForResource:resource];
    if (![self isReportReady] || self.report.isReportEmpty) {
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule | JMMenuActionsViewAction_Print | JMMenuActionsViewAction_ShowExternalDisplay;
    }
    return disabledAction;
}

- (void)showEmptyReportMessage
{
    [self hideReportView];
    self.emptyReportMessageLabel.hidden = NO;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)hideEmptyReportMessage
{
    [self showReportView];
    self.emptyReportMessageLabel.hidden = YES;
}

- (BOOL)isReportReady
{
    BOOL isCountOfPagesExist = self.report.countOfPages != NSNotFound;
    return isCountOfPagesExist;
}

- (void)hideToolbar
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)showToolbar
{
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)hideReportView
{
    [self resourceView].hidden = YES;
}

- (void)showReportView
{
    [self resourceView].hidden = NO;
}

- (void)layoutEmptyReportLabelInView:(UIView *)view {

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.emptyReportMessageLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self.emptyReportMessageLabel
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:view
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0];
    [view addConstraint:constraint];
}

#pragma mark - Work with external screen
- (UIView *)viewToShowOnExternalWindow
{
    CGFloat initialScaleViewport = 0.75;
    if (![JMUtils isSupportVisualize]) {
        initialScaleViewport = 3;
    }

    if ([self.reportLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        [self.reportLoader updateViewportScaleFactorWithValue:initialScaleViewport];
    }

    UIView *view = [UIView new];
    UIView *reportView = [self resourceView];

    [view addSubview:reportView];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[reportView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"reportView": reportView}]];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[reportView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"reportView": reportView}]];


    [view addSubview:self.emptyReportMessageLabel];
    [self layoutEmptyReportLabelInView:view];

    return view;
}


- (void)addControlsForExternalWindow
{
    self.controlsViewController = [[JMExternalWindowControlsVC alloc] initWithContentWebView:[self resourceView]];
    self.controlsViewController.delegate = self;

    CGRect controlViewFrame = self.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlsViewController.view.frame = controlViewFrame;

    [self.view addSubview:self.controlsViewController.view];
}

- (void)switchFromTV
{
    [self.controlsViewController.view removeFromSuperview];

    [super setupSubviews];

    [self.view addSubview:self.emptyReportMessageLabel];
    [self layoutEmptyReportLabelInView:self.view];
}

#pragma mark - JMExternalWindowControlViewControllerDelegate
- (void)externalWindowControlViewControllerDidUnplugControlView:(JMExternalWindowControlsVC *)viewController
{
    [self switchFromTV];
    [self hideExternalWindowWithCompletion:^(void) {
        [self configViewport];
    }];
}


#pragma mark - Scheduling
- (void)scheduleReport {
    JMNewScheduleVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMNewScheduleVC"];
    newJobVC.resourceLookup = self.resourceLookup;
    newJobVC.exitBlock = ^(void){
        [ALToastView toastInView:self.navigationController.view
                        withText:JMCustomLocalizedString(@"Schedule was created successfully.", nil)];
    };
    [self.navigationController pushViewController:newJobVC animated:YES];
}

@end
