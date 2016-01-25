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
#import "JMNewJobVC.h"

@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMExternalWindowControlViewControllerDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, copy) void(^exportCompletion)(NSString *resourcePath);
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *emptyReportMessageLabel;
@property (nonatomic, strong, readwrite) JMReport *report;
@property (nonatomic, strong) NSArray *initialReportParameters;
@property (nonatomic, assign) BOOL isReportAlreadyConfigured;
@property (nonatomic) JMExternalWindowControlsVC *controlsViewController;
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
    if (self.isChildReport) {
        [self closeChildReport];
    } else {
        [self stopShowLoader];

        if (![self.restClient isRequestPoolEmpty]) {
            [self.restClient cancelAllRequests];
        }
        [self.reportLoader cancel];
        if (self.exitBlock) {
            self.exitBlock();
        }

        if ([self isContentOnTV]) {
            [self hideExternalWindow];
        }

        [super cancelResourceViewingAndExit:exit];
    }
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    BOOL isReportReady = self.report.countOfPages != NSNotFound;
    if (isReportReady && self.report.isReportEmpty) {
        [self showEmptyReportMessage];
    }
}

- (void)closeChildReport
{
    [[JMWebViewManager sharedInstance] resetChildWebView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notifications
- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    [self.toolbar endEditing:YES];
}

#pragma mark - Setups
- (void)setupLeftBarButtonItems
{
    if (self.isChildReport) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItemWithTarget:self action:@selector(closeChildReport)];
    } else {
        [super setupLeftBarButtonItems];
    }
}

- (void)configViewport
{
    CGFloat initialScaleViewport = 0.75;
    BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    if (isCompactWidth) {
        initialScaleViewport = 0.25;
    }

    if ([self.reportLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        [self.reportLoader updateViewportScaleFactorWithValue:initialScaleViewport];
    }
}

- (void)setupSubviews
{
    self.configurator = [JMReportViewerConfigurator configuratorWithReport:self.report];

    UIWebView *webView = [self.configurator webViewAsSecondary:self.isChildReport];
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    [self setupWebViewLayout];
    [self.configurator updateReportLoaderDelegateWithObject:self];

    [self hideReportView];
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
                                  JSResourceReportUnit *reportUnit = [result.objects objectAtIndex:0];
                                  if (reportUnit) {
                                      if (strongSelf.isChildReport) {
                                          [strongSelf stopShowLoader];
                                          [strongSelf.report updateReportParameters:strongSelf.initialReportParameters];
                                          [strongSelf startLoadReportWithPage:1];
                                      } else {
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
                                      }
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
- (UIWebView *)webView
{
    return self.configurator.webView;
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
- (void)toolbar:(JMReportViewerToolBar *)toolbar changeFromPage:(NSInteger)fromPage toPage:(NSInteger)toPage completion:(void (^)(BOOL success))completion
{
    [[self webView].scrollView setZoomScale:0.1 animated:YES];

    __weak typeof(self)weakSelf = self;
    void(^changePageCompletion)(BOOL, NSError*) = ^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;

        // fix an issue in webview after zooming and changing page (black areas)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            JMJavascriptRequest *runRequest = [JMJavascriptRequest new];
            runRequest.command = @"document.body.style.height = '100%%'; document.body.style.width = '100%%';";
            [((JMJavascriptNativeBridge *)[strongSelf reportLoader].bridge) sendRequest:runRequest];
        });

        if ([strongSelf isContentOnTV]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf.controlsViewController updateInterface];
            });
        }

        if (success) {
            [self.report updateCurrentPage:toPage];
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
            [strongSelf handleError:error];
        }
    };
#warning Should update logic for load new report page after session expiration
    [self.reportLoader fetchPageNumber:toPage withCompletion:changePageCompletion];
}

#pragma mark - Run report
- (void)runReportWithPage:(NSInteger)page
{
    [self hideEmptyReportMessage];
    [self hideToolbar];
    [self hideReportView];

    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.reportLoader cancel];
        [strongSelf cancelResourceViewingAndExit:YES];
    }];

    [self.reportLoader runReportWithPage:page completion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];

        if (success) {
            // Analytics
            NSString *label = [JMUtils isSupportVisualize] ? kJMAnalyticsResourceEventLabelReportVisualize : kJMAnalyticsResourceEventLabelReportREST;
            [JMUtils logEventWithInfo:@{
                                kJMAnalyticsCategoryKey      : kJMAnalyticsResourceEventCategoryTitle,
                                kJMAnalyticsActionKey        : kJMAnalyticsResourceEventActionOpenTitle,
                                kJMAnalyticsLabelKey         : label
                        }];

            [strongSelf showReportView];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)updateReportWithNewActiveReportOption:(JSReportOption *)newActiveOption
{
    NSString *currentReportURI = self.report.reportURI;
    self.report.activeReportOption = newActiveOption;
    
    BOOL uriDidChanged = (!currentReportURI && newActiveOption.uri) || ![currentReportURI isEqualToString:newActiveOption.uri];
    
    if (self.report.isReportAlreadyLoaded && !uriDidChanged) {
        [self hideEmptyReportMessage];
        [self hideToolbar];
        [self hideReportView];
        
        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^(void) {
            __strong typeof(self)strongSelf = weakSelf;
            [strongSelf.reportLoader cancel];
            [strongSelf cancelResourceViewingAndExit:YES];
        }];
        [self.reportLoader applyReportParametersWithCompletion:^(BOOL success, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            [strongSelf stopShowLoader];
            
            if (success) {
                [strongSelf showReportView];
            } else {
                [strongSelf handleError:error];
            }
        }];
    } else {
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
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.reportLoader cancel];
        [strongSelf cancelResourceViewingAndExit:YES];
    }];
    
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
            
            NSInteger reportCurrentPage = self.report.currentPage;
            [self.report restoreDefaultState];
            [self.report updateCurrentPage:reportCurrentPage];
            // Here 'break;' doesn't need, because we should try to create new session and reload report
        case JSSessionExpiredErrorCode:
            if (self.restClient.keepSession) {
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

#pragma mark - UIWebView helpers
- (void)resetSubViews
{
    [self.reportLoader destroy];
    [[JMWebViewManager sharedInstance] resetZoom];
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
        case JMMenuActionsViewAction_HideExternalDisplay:
            [self switchFromTV];
            [self hideExternalWindow];
            break;
        default:
            break;
    }
}

#pragma mark - JMSaveReportControllerDelegate
- (void)reportDidSavedSuccessfully
{
    [ALToastView toastInView:self.view
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
        [strongSelf updateReportWithNewActiveReportOption:reportOption];
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
    self.emptyReportMessageLabel.hidden = NO;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)hideEmptyReportMessage
{
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
    self.webView.hidden = YES;
}

- (void)showReportView
{
    self.webView.hidden = NO;
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
    if ([self.reportLoader respondsToSelector:@selector(updateViewportScaleFactorWithValue:)]) {
        [self.reportLoader updateViewportScaleFactorWithValue:0.75];
    }
    UIView *view = [UIView new];
    UIView *reportView = self.webView;

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
    self.controlsViewController = [[JMExternalWindowControlsVC alloc] initWithContentWebView:self.webView];
    self.controlsViewController.delegate = self;

    CGRect controlViewFrame = self.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlsViewController.view.frame = controlViewFrame;

    [self.view addSubview:self.controlsViewController.view];
}

- (void)switchFromTV
{
    [self.view addSubview:self.webView];
    [self setupWebViewLayout];

    [self configViewport];

    [self.view addSubview:self.emptyReportMessageLabel];
    [self layoutEmptyReportLabelInView:self.view];

    [self.controlsViewController.view removeFromSuperview];
}

#pragma mark - JMExternalWindowControlViewControllerDelegate
- (void)externalWindowControlViewControllerDidUnplugControlView:(JMExternalWindowControlsVC *)viewController
{
    [self switchFromTV];
    [self hideExternalWindow];
}


#pragma mark - Scheduling
- (void)scheduleReport {
    JMNewJobVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMNewJobVC"];
    newJobVC.resourceLookup = self.resourceLookup;
    newJobVC.exitBlock = ^() {

    };
    [self.navigationController pushViewController:newJobVC animated:YES];
}

@end
