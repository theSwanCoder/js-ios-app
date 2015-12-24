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
#import "JMReportSaver.h"
#import "JMSavedResources.h"
#import "JMSavedResources+Helpers.h"
#import "JMJavascriptRequest.h"
#import "JMJavascriptNativeBridge.h"
#import "JMWebViewManager.h"
#import "JMSaveReportViewController.h"
#import "JMReportManager.h"
#import "ALToastView.h"
#import "JMInputControlsViewController.h"
#import "JMReportViewerToolBar.h"
#import "JMExternalWindowControlViewController.h"

@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMExternalWindowControlViewControllerDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, copy) void(^exportCompletion)(NSString *resourcePath);
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *emptyReportMessageLabel;
@property (nonatomic, strong, readwrite) JMReport *report;
@property (nonatomic, strong) NSArray *initialReportParameters;
@property (nonatomic, assign) BOOL isReportAlreadyConfigured;
@property (nonatomic) JMExternalWindowControlViewController *controlViewController;
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
    self.emptyReportMessageLabel.text = JMCustomLocalizedString(@"report.viewer.emptyreport.title", nil);

    [self configureReport];

    [self addObservers];
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
                                                 name:kJMReportIsMutlipageDidChangedNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:kJMReportCountOfPagesDidChangeNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:kJMReportCurrentPageDidChangeNotification
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
        if (![self.restClient isRequestPoolEmpty]) {
            [self.restClient cancelAllRequests];
        }
        [self.reportLoader cancel];
        if (self.exitBlock) {
            self.exitBlock();
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

#pragma mark - Setups
- (void)setupLeftBarButtonItems
{
    if (self.isChildReport) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItemWithTarget:self action:@selector(closeChildReport)];
    } else {
        [super setupLeftBarButtonItems];
    }
}

- (void)setupSubviews
{
    self.configurator = [JMReportViewerConfigurator configuratorWithReport:self.report];

    // Setup viewport scale factor
    CGFloat initialScaleViewport = 0.75;
    BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    if (isCompactWidth) {
        initialScaleViewport = 0.25;
    }
    self.configurator.viewportScaleFactor = initialScaleViewport;

    UIWebView *webView = [self.configurator webViewAsSecondary:self.isChildReport];
    [self.view insertSubview:webView belowSubview:self.activityIndicator];

    [self setupWebViewLayout];
    [self.configurator updateReportLoaderDelegateWithObject:self];
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
        [JMCancelRequestPopup dismiss];
        JMLog(@"%@: %@", errorMessage, error);
        if (error.code == JSSessionExpiredErrorCode) {
            [JMUtils showLoginViewAnimated:YES completion:^{
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
        } else {
            __weak typeof(self) weakSelf = strongSelf;
            [JMUtils presentAlertControllerWithError:error completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf cancelResourceViewingAndExit:YES];
            }];
        }
    };

    NSString *reportURI = self.resourceLookup.uri;

    [JMCancelRequestPopup presentWithMessage:@"status.loading"
                                 cancelBlock:^{
                                     __strong typeof(self) strongSelf = weakSelf;
                                     [strongSelf cancelResourceViewingAndExit:YES];
                                 }];
    [JMReportManager fetchReportLookupWithResourceURI:reportURI
                                           completion:^(JSResourceReportUnit *reportUnit, NSError *error) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               [strongSelf stopShowLoader];
                                               if (error) {
                                                   errorHandlingBlock(error, @"Report Unit Loading Error");
                                               } else {
                                                   if (reportUnit) {
                                                       if (strongSelf.isChildReport) {
                                                           [strongSelf.report updateReportParameters:strongSelf.initialReportParameters];
                                                           [strongSelf startLoadReportWithPage:1];
                                                       } else {
                                                           // get report input controls
                                                           __weak typeof(self) weakSelf = strongSelf;
                                                           [JMReportManager fetchInputControlsWithReportURI:reportURI
                                                                                                 completion:^(NSArray *inputControls, NSError *error) {
                                                                                                     __strong typeof(self) strongSelf = weakSelf;
                                                                                                     if (error) {
                                                                                                         errorHandlingBlock(error, @"Report Input Controls Loading Error");
                                                                                                     } else {
                                                                                                         if ([inputControls count]) {
                                                                                                             [strongSelf.report generateReportOptionsWithInputControls:inputControls];

                                                                                                             // get report options
                                                                                                             __weak typeof(self) weakSelf = strongSelf;
                                                                                                             [JMReportManager fetchReportOptionsWithReportURI:strongSelf.report.reportURI completion:^(NSArray *reportOptions, NSError *error) {
                                                                                                                 __strong typeof(self) strongSelf = weakSelf;
                                                                                                                 if (error && error.code == JSSessionExpiredErrorCode) {
                                                                                                                     errorHandlingBlock(error, @"Report Options Loading Error");
                                                                                                                 } else {
                                                                                                                     [JMCancelRequestPopup dismiss];
                                                                                                                     strongSelf.isReportAlreadyConfigured = YES;

                                                                                                                     [strongSelf.report addReportOptions:reportOptions];

                                                                                                                     if ([reportOptions count] || (reportUnit.alwaysPromptControls && [inputControls count])) {
                                                                                                                         [strongSelf showInputControlsViewControllerWithBackButton:YES];
                                                                                                                     } else  {
                                                                                                                         [strongSelf startLoadReportWithPage:1];
                                                                                                                     }
                                                                                                                 }
                                                                                                             }];
                                                                                                         } else {
                                                                                                             [JMCancelRequestPopup dismiss];
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

#pragma mark - Print
- (void)printResource
{
    // TODO: we don't have events when JIVE is applied to a report.

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
    JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:self.report];
    [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
        [reportSaver cancelReport];
    }];
    [reportSaver saveReportWithName:[self tempReportName]
                             format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                              pages:[self makePagesFormat]
                            addToDB:NO
                         completion:^(JMSavedResources *savedReport, NSError *error) {
                             [JMCancelRequestPopup dismiss];
                             if (error) {
                                 if (error.code == JSSessionExpiredErrorCode) {
                                     [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                         if (self.restClient.keepSession && isSessionAuthorized) {
                                             [self preparePreviewForPrintWithCompletion:completion];
                                         } else {
                                             [JMUtils showLoginViewAnimated:YES completion:nil];
                                         }
                                     }];
                                 } else {
                                     [JMUtils presentAlertControllerWithError:error completion:nil];
                                 }
                             } else {
                                 NSString *savedReportURL = [JMSavedResources absolutePathToSavedReport:savedReport];
                                 NSURL *resourceURL = [NSURL fileURLWithPath:savedReportURL];
                                 if (completion) {
                                     completion(resourceURL);
                                     [savedReport removeFromDB];
                                 }
                             }
                         }];
}

- (NSString *)tempReportName
{
    return [[NSUUID UUID] UUIDString];
}

- (NSString *)makePagesFormat
{
    NSString *pagesFormat;
    if (self.report.isMultiPageReport) {
        pagesFormat = [NSString stringWithFormat:@"1-%@", @(self.report.countOfPages)];
    } else {
        pagesFormat = [NSString stringWithFormat:@"1"];
    }
    return pagesFormat;
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

- (id<JMReportLoader>)reportLoader
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
    if ([self.reportLoader respondsToSelector:@selector(changeFromPage:toPage:withCompletion:)]) {
        [self.reportLoader changeFromPage:fromPage toPage:toPage withCompletion:^(BOOL success, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            if (success) {
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
                [strongSelf handleError:error];
            }
        }];
    } else {
        [self.reportLoader fetchPageNumber:toPage withCompletion:^(BOOL success, NSError *error) {
            __strong typeof(self)strongSelf = weakSelf;
            
            // fix an issue in webview after zooming and changing page (black areas)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                JMJavascriptRequest *runRequest = [JMJavascriptRequest new];
                runRequest.command = @"document.body.style.height = '100%%'; document.body.style.width = '100%%';";
                [((JMJavascriptNativeBridge *)[strongSelf reportLoader].bridge) sendRequest:runRequest];
            });
            
            if (success) {
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
                [strongSelf handleError:error];
            }
        }];
    }
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
            NSString *resourcesType = [JMUtils isSupportVisualize] ? @"Report (Visualize)" : @"Report (REST)";
            [JMUtils logEventWithName:@"User opened resource"
                         additionInfo:@{
                                 @"Resource's Type" : resourcesType
                         }];

            [strongSelf showReportView];
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)updateReportWithNewActiveReportOption:(JMExtendedReportOption *)newActiveOption
{
    NSString *currentReportURI = self.report.reportURI;
    self.report.activeReportOption = newActiveOption;
    
    BOOL uriDidChanged = (!currentReportURI && newActiveOption.reportOption.uri) || ![currentReportURI isEqualToString:newActiveOption.reportOption.uri];
    
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
    if (error.code == JMReportLoaderErrorTypeAuthentification) {
        
        [self.restClient deleteCookies];
        [self resetSubViews];
        
        NSInteger reportCurrentPage = self.report.currentPage;
        [self.report restoreDefaultState];
        
        __weak typeof(self)weakSelf = self;
        [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
            __strong typeof(self)strongSelf = weakSelf;
            if (strongSelf.restClient.keepSession && isSessionAuthorized) {
                // TODO: Need add restoring for current page
                [strongSelf runReportWithPage:reportCurrentPage];
            } else {
                [JMUtils showLoginViewAnimated:YES completion:^{
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            }
        }];
        
    } else if (error.code == JMReportLoaderErrorTypeEmtpyReport) {
        [self showEmptyReportMessage];
    } else if (error.code == JSSessionExpiredErrorCode) {
        __weak typeof(self)weakSelf = self;
        [self.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
            __strong typeof(self)strongSelf = weakSelf;
            if (strongSelf.restClient.keepSession && isSessionAuthorized) {
                [strongSelf runReportWithPage:strongSelf.report.currentPage];
            } else {
                __weak typeof(self)weakSelf = strongSelf;
                [JMUtils showLoginViewAnimated:YES completion:^{
                    __strong typeof(self)strongSelf = weakSelf;
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
}

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(id<JMReportLoader>)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *)resourceLookup withParameters:(NSArray *)reportParameters
{
    JMReportViewerVC *reportViewController = (JMReportViewerVC *) [self.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
    reportViewController.resourceLookup = resourceLookup;
    reportViewController.initialReportParameters = reportParameters;
    reportViewController.isChildReport = YES;
    [self.navigationController pushViewController:reportViewController animated:YES];
}

-(void)reportLoader:(id<JMReportLoader>)reportLoder didReceiveOnClickEventForReference:(NSURL *)urlReference
{
    [[UIApplication sharedApplication] openURL:urlReference];
}

- (void)reportLoader:(id<JMReportLoader>)reportLoader didReceiveOutputResourcePath:(NSString *)resourcePath fullReportName:(NSString *)fullReportName
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
        case JMMenuActionsViewAction_ShowExternalDisplay:
            if ( [self createExternalWindow] ) {
                [self showExternalWindow];
            }
            break;
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
    inputControlsViewController.completionBlock = ^(JMExtendedReportOption *reportOption) {
        [self updateReportWithNewActiveReportOption:reportOption];
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
- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = [super availableActionForResource:resource] | JMMenuActionsViewAction_Save;
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
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Print | JMMenuActionsViewAction_ShowExternalDisplay;
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
    ((UIView *)self.configurator.webView).hidden = YES;
}

- (void)showReportView
{
    ((UIView *)self.configurator.webView).hidden = NO;
}


#pragma mark - Work with external screen
- (UIView *)viewForAddingToExternalWindow
{
    [self.reportLoader updateViewportScaleFactorWithValue:0.75];
    UIView *reportView = self.configurator.webView;;
    reportView.translatesAutoresizingMaskIntoConstraints = YES;

    // Need some time to layout content of webview
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addControlsForExternalWindow];
    });

    return reportView;
}


- (void)addControlsForExternalWindow
{
    self.controlViewController = [[JMExternalWindowControlViewController alloc] initWithContentWebView:self.webView];
    self.controlViewController.delegate = self;

    CGRect controlViewFrame = self.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlViewController.view.frame = controlViewFrame;

    [self.view addSubview:self.controlViewController.view];
}

- (void)switchFromTV
{
    [self.view addSubview:self.webView];
    [self setupWebViewLayout];

    CGFloat initialScaleViewport = 0.75;
    BOOL isCompactWidth = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    if (isCompactWidth) {
        initialScaleViewport = 0.25;
    }
    [self.reportLoader updateViewportScaleFactorWithValue:initialScaleViewport];

    [self.controlViewController.view removeFromSuperview];
}

#pragma mark - JMExternalWindowControlViewControllerDelegate
- (void)externalWindowControlViewControllerDidUnplugControlView:(JMExternalWindowControlViewController *)viewController
{
    [self switchFromTV];
    [self hideExternalWindow];
}


@end
