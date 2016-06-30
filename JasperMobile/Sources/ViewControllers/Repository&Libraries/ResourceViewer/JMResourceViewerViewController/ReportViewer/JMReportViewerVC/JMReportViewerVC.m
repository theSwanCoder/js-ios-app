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
#import "JMReportViewerConfigurator.h"
#import "JMJavascriptRequest.h"
#import "JMWebViewManager.h"
#import "JMSavingReportViewController.h"
#import "ALToastView.h"
#import "JMInputControlsViewController.h"
#import "JMReportViewerToolBar.h"
#import "JMExternalWindowControlsVC.h"
#import "JMScheduleVC.h"
#import "JMWebEnvironment.h"
#import "JMResource.h"
#import "JMAnalyticsManager.h"
#import "JMBookmarksVC.h"
#import "JMReportBookmark.h"
#import "JMReportPartViewToolbar.h"
#import "JMReportPart.h"

NSString * const kJMReportViewerPrimaryWebEnvironmentIdentifierViz    = @"kJMReportViewerPrimaryWebEnvironmentIdentifierViz";
NSString * const kJMReportViewerPrimaryWebEnvironmentIdentifierREST   = @"kJMReportViewerPrimaryWebEnvironmentIdentifierREST";
NSString * const kJMReportViewerSecondaryWebEnvironmentIdentifierViz  = @"kJMReportViewerSecondaryWebEnvironmentIdentifierViz";
NSString * const kJMReportViewerSecondaryWebEnvironmentIdentifierREST = @"kJMReportViewerSecondaryWebEnvironmentIdentifierREST";

@interface JMReportViewerVC () <JMSaveReportViewControllerDelegate, JMReportViewerToolBarDelegate, JMReportLoaderDelegate, JMReportPartViewToolbarDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, copy) void(^exportCompletion)(NSString *resourcePath);
@property (nonatomic, weak) JMReportViewerToolBar *toolbar;
@property (nonatomic, weak) JMReportPartViewToolbar *reportPartToolbar;
@property (weak, nonatomic) UILabel *emptyReportMessageLabel;
@property (nonatomic, strong) JMReport *report;
@property (nonatomic, assign) BOOL isReportAlreadyConfigured;
@property (nonatomic) JMExternalWindowControlsVC *controlsViewController;
@property (nonatomic, weak) UIBarButtonItem *currentBackButton;
@end

@implementation JMReportViewerVC

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    [coordinator animateAlongsideTransition:nil completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if ([self.reportLoader respondsToSelector:@selector(fitReportViewToScreen)]) {
            [self.reportLoader fitReportViewToScreen];
        }
    }];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

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
        JMSavingReportViewController *destinationViewController = segue.destinationViewController;
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidUpdateBookmarks)
                                                 name:JMReportBookmarksDidUpdateNotification
                                               object:self.report];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportDidUpdateParts)
                                                 name:JMReportPartsDidUpdateNotification
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
    if (self.report.parts) {
        [self.reportPartToolbar updateCurrentPartForPage:self.report.currentPage];
    }
}

- (void)reportDidUpdateBookmarks
{
    if ([self reportHasBookmarks]) {
        [self addBookmarkItem];
    }
}

- (void)reportDidUpdateParts
{
    if (self.report.parts) {
        // TODO: need ability remove from top toolbar?
        [self addTopToolbar:self.reportPartToolbar];
        [self showTopToolbarAnimated:YES];
    } else {
        [self hideTopToolbarAnimated:YES];
    }
}

#pragma mark - Actions
- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if (!self.isChildReport) {
        [self stopShowLoader];

        [self.restClient cancelAllRequests];
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
    } else {
        [self hideEmptyReportMessage];
    }
}

- (void)backActionInWebView
{
    [self startShowLoaderWithMessage:@"status_loading"];
    __weak typeof(self) weakSelf = self;
    [self.reportLoader runReportWithPage:self.report.currentPage
                              completion:^(BOOL success, NSError *error) {
                                  typeof(self) strongSelf = weakSelf;
                                  [strongSelf stopShowLoader];
                                  strongSelf.navigationItem.leftBarButtonItem = strongSelf.currentBackButton;
                              }];
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
}

- (void)setupSubviews
{
    [self addEmptyReportLabelInView:self.view];
    [self hideEmptyReportMessage];
}

- (void)updateToobarAppearence
{
    if (self.toolbar && self.report.isMultiPageReport && !self.report.isReportEmpty) {
        self.toolbar.currentPage = self.report.currentPage;
        if (self.navigationController.visibleViewController == self) {
            [self showPaginationToolbar];
        }
    } else {
        [self hidePaginationToolbar];
    }
}

#pragma mark - Overloaded methods
- (void) startResourceViewing
{
    [self configureReport];
}

- (void)startLoadReportWithPage:(NSInteger)page
{
    BOOL isReportAlreadyLoaded = self.report.isReportAlreadyLoaded;
    BOOL isReportInLoadingProcess = self.reportLoader.isReportInLoadingProcess;

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

    NSString *reportURI = self.resource.resourceLookup.uri;

    [self startShowLoaderWithMessage:@"status_loading"];
    [self.restClient resourceLookupForURI:reportURI resourceType:kJS_WS_TYPE_REPORT_UNIT
                               modelClass:[JSResourceReportUnit class]
                          completionBlock:^(JSOperationResult *result) {
                              __strong typeof(self)strongSelf = weakSelf;
                              if (result.error) {
                                  errorHandlingBlock(result.error, @"Report Unit Loading Error");
                              } else {
                                  JSResourceReportUnit *reportUnit = result.objects.firstObject;
                                  if (reportUnit) {
                                      [super setupSubviews];
                                      // get report input controls
                                      __weak typeof(self) weakSelf = strongSelf;
                                      [strongSelf.restClient inputControlsForReport:reportURI
                                                                     selectedValues:strongSelf.initialReportParameters
                                                                    completionBlock:^(JSOperationResult * _Nullable result) {
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
                                                                                // setup report options
                                                                                if (strongSelf.isChildReport && strongSelf.initialReportParameters) {
                                                                                    // generate 'none' report option
                                                                                    [strongSelf.report generateReportOptionsWithInputControls:visibleInputControls];

                                                                                    // make report option with visible input controls as active report option
                                                                                    JSReportOption *reportOptionWithInitParams = [JSReportOption defaultReportOption];
                                                                                    reportOptionWithInitParams.inputControls = [[NSArray alloc] initWithArray:visibleInputControls copyItems:YES];
                                                                                    strongSelf.report.activeReportOption = reportOptionWithInitParams;
                                                                                } else {
                                                                                    // generate 'none' report option
                                                                                    [strongSelf.report generateReportOptionsWithInputControls:visibleInputControls];
                                                                                }

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
    [JMCancelRequestPopup presentWithMessage:@"status_loading" cancelBlock:^{
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
    return [[JMWebViewManager sharedInstance] reusableWebEnvironmentWithId:[self currentWebEnvironmentIdentifier]];
}

- (NSString *)currentWebEnvironmentIdentifier
{
    NSString *webEnvironmentIdentifier;
    if (self.isChildReport) {
        if ([JMUtils isSupportVisualize]) {
            webEnvironmentIdentifier = kJMReportViewerSecondaryWebEnvironmentIdentifierViz;
        } else {
            webEnvironmentIdentifier = kJMReportViewerSecondaryWebEnvironmentIdentifierREST;
        }
    } else {
        if ([JMUtils isSupportVisualize]) {
            webEnvironmentIdentifier = kJMReportViewerPrimaryWebEnvironmentIdentifierViz;
        } else {
            webEnvironmentIdentifier = kJMReportViewerPrimaryWebEnvironmentIdentifierREST;
        }
    }
    return webEnvironmentIdentifier;
}

- (JMReportViewerConfigurator *)configurator
{
    if (!_configurator) {
        _configurator = [JMReportViewerConfigurator configuratorWithReport:self.report
                                                            webEnvironment:self.webEnvironment];
        [_configurator updateReportLoaderDelegateWithObject:self];
    }
    return _configurator;
}

- (id<JMReportLoaderProtocol>)reportLoader
{
    return [self.configurator reportLoader];
}

- (JMReport *)report
{
    if (!_report) {
        _report = [self.resource modelOfResource];
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

- (JMReportPartViewToolbar *)reportPartToolbar
{
    if (!_reportPartToolbar) {
        _reportPartToolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportPartViewToolbar" owner:self options:nil] firstObject];
        _reportPartToolbar.parts = self.report.parts;
        _reportPartToolbar.delegate = self;
    }
    return _reportPartToolbar;
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
        } else {
            [strongSelf handleError:error];
        }
    };
    if ([self.reportLoader respondsToSelector:@selector(shouldDisplayLoadingView)] && [self.reportLoader shouldDisplayLoadingView]) {
        [self startShowLoaderWithMessage:@"status_loading"];
    }
    [self.reportLoader fetchPageNumber:toPage withCompletion:changePageCompletion];
}

#pragma mark - JMReportPartViewToolbarDelegate
- (void)reportPartViewToolbarDidChangePart:(JMReportPartViewToolbar *)toolbar
{
    if ([self.reportLoader respondsToSelector:@selector(navigateToPart:withCompletion:)]) {
        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:@"status_loading"];
        [self.reportLoader navigateToPart:toolbar.currentPart withCompletion:^(BOOL success, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf stopShowLoader];
            if (error) {
                [strongSelf handleError:error];
            }
        }];
    }
}

#pragma mark - Run report
- (void)runReportWithPage:(NSInteger)page
{
    [self hideEmptyReportMessage];
    [self hidePaginationToolbar];
    [self hideReportView];
    self.toolbar.enable = NO;

    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status_loading"];
    [self.reportLoader runReportWithPage:page completion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];
        strongSelf.toolbar.enable = YES;

        if (success) {
            // Analytics
            NSString *label = [JMUtils isSupportVisualize] ? kJMAnalyticsResourceLabelReportVisualize : kJMAnalyticsResourceLabelReportREST;
            [[JMAnalyticsManager sharedManager] sendAnalyticsEventWithInfo:@{
                    kJMAnalyticsCategoryKey : kJMAnalyticsEventCategoryResource,
                    kJMAnalyticsActionKey   : kJMAnalyticsEventActionOpen,
                    kJMAnalyticsLabelKey    : label
            }];

            [strongSelf showReportView];
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
        [self hidePaginationToolbar];
        [self hideReportView];

        __weak typeof(self)weakSelf = self;
        [self startShowLoaderWithMessage:@"status_loading"];
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
    [self hidePaginationToolbar];
    [self hideReportView];
    
    __weak typeof(self)weakSelf = self;
    [self startShowLoaderWithMessage:@"status_loading"];
    
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
        case JSSessionExpiredErrorCode: {
            if (self.restClient.keepSession) {
                __weak typeof(self) weakSelf = self;
                JMLog(@"Handle session expired");
                JMLog(@"self.restClient: %@", self.restClient);
                [self startShowLoaderWithMessage:@"status_loading"];
                [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult *_Nullable result) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf stopShowLoader];
                    if (!result.error) {
                        // reset pagination
                        [strongSelf hidePaginationToolbar];
                        // reset top toolbar
                        [strongSelf hideTopToolbarAnimated:NO];
                        [strongSelf removeTopToolbar];
                        strongSelf.reportPartToolbar = nil;
                        // reset bookmarks
                        [strongSelf removeBookmarkItem];
                        // reset report
                        [strongSelf.report restoreDefaultState];
                        strongSelf.report.isReportAlreadyLoaded = NO;
                        [strongSelf hideReportView];
                        if (![JMUtils isSupportVisualize]) {
                            JMLog(@"Recreate configutator");
                            // TODO: udpate rest loader to be able reuse
                            [strongSelf.reportLoader cancel];
                            strongSelf.configurator = nil;
                        }
                        [strongSelf showSessionExpiredAlert];
                    } else {
                        __weak typeof(self) weakSelf = strongSelf;
                        [JMUtils showLoginViewAnimated:YES completion:^{
                            __strong typeof(self) strongSelf = weakSelf;
                            [strongSelf cancelResourceViewingAndExit:YES];
                        }];
                    }
                }];
            } else {
                __weak typeof(self) weakSelf = self;
                [JMUtils showLoginViewAnimated:YES completion:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            }
            break;
        }
        case JSReportLoaderErrorTypeEmtpyReport:
            [self showEmptyReportMessage];
            break;
        case JSInvalidCredentialsErrorCode: {
            [JMUtils showLoginViewAnimated:YES completion:^{
                [self cancelResourceViewingAndExit:YES];
            }];
            break;
        }
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

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(id<JMReportLoaderProtocol>)reportLoader didReceiveOnClickEventForResource:(JMResource *)resource withParameters:(NSArray *)reportParameters
{
    JMReportViewerVC *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:[resource resourceViewerVCIdentifier]];
    reportViewController.resource = resource;
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
    NSURL *serverURL = [NSURL URLWithString:self.restClient.serverProfile.serverUrl];
    if ([urlReference.host isEqualToString:serverURL.host]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:urlReference];
        [self.webEnvironment.webView loadRequest:request];

        UIBarButtonItem *backButton = [self backButtonWithTitle:JMCustomLocalizedString(@"back_button_title", nil)
                                                         target:self
                                                         action:@selector(backActionInWebView)];
        self.currentBackButton = self.navigationItem.leftBarButtonItem;
        self.navigationItem.leftBarButtonItem = backButton;
    } else {
        // TODO: open in safari view controller
        if (urlReference && [[UIApplication sharedApplication] canOpenURL:urlReference]) {
            [[UIApplication sharedApplication] openURL:urlReference];
        }
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
        case JMMenuActionsViewAction_Bookmarks: {
            [self showBookmarks];
            break;
        }
        case JMMenuActionsViewAction_ShowExternalDisplay: {
            [self showExternalWindowWithCompletion:^(BOOL success) {
                if (success) {
                    if ([self.reportLoader respondsToSelector:@selector(fitReportViewToScreen)]) {
                        [self.reportLoader fitReportViewToScreen];
                    }
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
- (void)showInputControlsViewControllerWithBackButton:(BOOL)isShowBackButton
{
    JMInputControlsViewController *inputControlsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMInputControlsViewController"];
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
            } else {
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    };

    if (isShowBackButton) {
        UIBarButtonItem *backItem = [self backBarButtonItemWithTarget:inputControlsViewController
                                                               action:@selector(backButtonTapped:)];
        inputControlsViewController.navigationItem.leftBarButtonItem = backItem;
    }

    [self.navigationController pushViewController:inputControlsViewController animated:YES];

}

#pragma mark - Helpers
- (void)startShowLoaderWithMessage:(NSString *)message
{
    __weak typeof(self) weakSelf = self;
    [self startShowLoaderWithMessage:@"status_loading" cancelBlock:^(void) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf.reportLoader cancel];
        [strongSelf cancelResourceViewingAndExit:YES];
    }];
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = [super availableAction] | JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule;
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

- (JMMenuActionsViewAction)disabledAction
{
    JMMenuActionsViewAction disabledAction = [super disabledAction];
    if (![self isReportReady] || self.report.isReportEmpty) {
        disabledAction |= JMMenuActionsViewAction_Save | JMMenuActionsViewAction_Schedule | JMMenuActionsViewAction_Print | JMMenuActionsViewAction_ShowExternalDisplay;
    }
    return disabledAction;
}

- (void)showEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = NO;
    [self hidePaginationToolbar];
}

- (void)hideEmptyReportMessage
{
    self.emptyReportMessageLabel.hidden = YES;
    if (self.report.isMultiPageReport) {
        [self showPaginationToolbar];
    } else {
        [self hidePaginationToolbar];
    }
}

- (BOOL)isReportReady
{
    BOOL isCountOfPagesExist = self.report.countOfPages != NSNotFound;
    return isCountOfPagesExist;
}

- (void)hidePaginationToolbar
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)showPaginationToolbar
{
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)hideReportView
{
    [self contentView].hidden = YES;
}

- (void)showReportView
{
    [self contentView].hidden = NO;
}

#pragma mark - Bookmark Item Helpers
- (void)addBookmarkItem
{
    UIBarButtonItem *bookmarkItem = [self findBookmarkItem];
    if (bookmarkItem) {
        return;
    } else {
        NSMutableArray *rightNavItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [rightNavItems addObject:[self createBookmarkItem]];
        self.navigationItem.rightBarButtonItems = rightNavItems;
    }
}

- (UIBarButtonItem *__nullable)findBookmarkItem
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

- (UIBarButtonItem *)createBookmarkItem
{
    UIBarButtonItem *bookmarkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmarks_item"]
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(showBookmarks)];
    return bookmarkItem;
}

- (void)removeBookmarkItem
{
    UIBarButtonItem *bookmarkItem = [self findBookmarkItem];
    if (bookmarkItem) {
        NSMutableArray *rightNavItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [rightNavItems removeObject:bookmarkItem];
        self.navigationItem.rightBarButtonItems = rightNavItems;
    } else {
        return;
    }
}

#pragma mark - Empty Report Label
- (UILabel *)createEmptyReportMessageLabel
{
    UILabel *label = [UILabel new];
    label.text = JMCustomLocalizedString(@"report_viewer_emptyreport_title", nil);
    return label;
}

- (void)addEmptyReportLabelInView:(UIView *)view
{
    [self.emptyReportMessageLabel removeFromSuperview];

    UILabel *emptyReportLabel = [self createEmptyReportMessageLabel];
    [view addSubview:emptyReportLabel];
    self.emptyReportMessageLabel = emptyReportLabel;

    [self setupEmptyReportLabelConstriantsInView:view];
}

- (void)setupEmptyReportLabelConstriantsInView:(UIView *)view
{
    [self.emptyReportMessageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

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
    UIView *view = [UIView new];
    UIView *reportView = [self contentView];

    [view addSubview:reportView];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[reportView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"reportView": reportView}]];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[reportView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"reportView": reportView}]];


    [self addEmptyReportLabelInView:view];
    if (![self.report isReportEmpty]) {
        [self hideEmptyReportMessage];
    }

    return view;
}


- (void)addControlsForExternalWindow
{
    self.controlsViewController = [[JMExternalWindowControlsVC alloc] initWithContentView:[self contentView]];

    CGRect controlViewFrame = self.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlsViewController.view.frame = controlViewFrame;

    [self.view addSubview:self.controlsViewController.view];
}

- (void)switchFromTV
{
    [self.controlsViewController.view removeFromSuperview];

    [super setupSubviews];

    [self addEmptyReportLabelInView:self.view];
    if (![self.report isReportEmpty]) {
        [self hideEmptyReportMessage];
    }

    [self hideExternalWindowWithCompletion:^{
        if ([self.reportLoader respondsToSelector:@selector(fitReportViewToScreen)]) {
            [self.reportLoader fitReportViewToScreen];
        }
    }];
}


#pragma mark - Scheduling
- (void)scheduleReport {
    JMScheduleVC *newJobVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMScheduleVC"];
    [newJobVC createNewScheduleMetadataWithResourceLookup:self.resource];
    [self.navigationController pushViewController:newJobVC animated:YES];
}

#pragma mark - Bookmarks
- (BOOL)reportHasBookmarks
{
    return self.report.bookmarks != nil;
}

- (void)showBookmarks
{
    JMBookmarksVC *bookmarksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMBookmarksVC"];
    bookmarksVC.bookmarks = self.report.bookmarks;
    __weak __typeof(self) weekSelf = self;
    bookmarksVC.exitBlock = ^(JMReportBookmark *selectedBookmark) {
        __typeof(self) strongSelf = weekSelf;
        [strongSelf.navigationController popToViewController:strongSelf animated:YES];
        JMReportBookmark *existingSelectedBookmark = [self.report findSelectedBookmark];
        if (existingSelectedBookmark && [existingSelectedBookmark isEqual:selectedBookmark]) {
            return;
        }
        [strongSelf.report markBookmarkAsSelected:selectedBookmark];
        JMLog(@"bookmark was selected: %@", selectedBookmark.isSelected ? @"YES" : @"NO");
        [strongSelf navigateToBookmark:selectedBookmark];
    };
    [self.navigationController pushViewController:bookmarksVC animated:YES];
}

- (void)navigateToBookmark:(JMReportBookmark *__nonnull)bookmark
{
    if ([self.reportLoader respondsToSelector:@selector(navigateToBookmark:withCompletion:)]) {
        [self startShowLoaderWithMessage:@"status_loading"];
        __weak __typeof(self) weakSelf = self;
        [self.reportLoader navigateToBookmark:bookmark withCompletion:^(BOOL success, NSError *error) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf stopShowLoader];
            if (error) {
                [strongSelf handleError:error];
            }
        }];
    }
}

@end
