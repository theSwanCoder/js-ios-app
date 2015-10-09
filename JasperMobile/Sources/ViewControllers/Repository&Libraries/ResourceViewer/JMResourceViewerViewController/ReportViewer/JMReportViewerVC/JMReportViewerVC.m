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

@interface JMReportViewerVC () <JMReportLoaderDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, copy) void(^exportCompletion)(NSString *resourcePath);
@end

@implementation JMReportViewerVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![JMUtils isSystemVersion8]) {
        // need update frame for ios7
        // there is issue with webView, when we run report and device is in landscape mode
        [self webView].frame = self.view.bounds;
    }
}

- (UIWebView *)webView
{
    return self.configurator.webView;
}

#pragma mark - Actions
- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    if (self.isChildReport) {
        [self closeChildReport];
    } else {
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
    [[JMVisualizeWebViewManager sharedInstance] resetChildWebView];
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
    UIWebView *webView = [self.configurator webViewWithFrame:self.view.bounds asSecondary:self.isChildReport];
    [self.view insertSubview:webView belowSubview:self.activityIndicator];

    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"webView": webView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"webView": webView}]];

    [self.configurator updateReportLoaderDelegateWithObject:self];
}

#pragma mark - Custom accessors
- (id<JMReportLoader>)reportLoader
{
    return [self.configurator reportLoader];
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
                [((JMJavascriptNativeBridge *)[self reportLoader].bridge) sendRequest:runRequest];
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
        [strongSelf.reportLoader cancelReport];
        [strongSelf cancelResourceViewingAndExit:YES];
    }];

    [self.reportLoader runReportWithPage:page completion:^(BOOL success, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf stopShowLoader];

        if (success) {
            // Crashlytics
            NSString *resourcesType = [JMUtils isSupportVisualize] ? @"Report (Visualize)" : @"Report (REST)";
            [Answers logCustomEventWithName:@"User opened resource"
                           customAttributes:@{
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
            [strongSelf.reportLoader cancelReport];
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
        [strongSelf.reportLoader cancelReport];
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
                [JMUtils showLoginViewAnimated:YES completion:^{
                    [strongSelf cancelResourceViewingAndExit:YES];
                }];
            }
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [JMUtils presentAlertControllerWithError:error completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf cancelResourceViewingAndExit:YES];
            }
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
    if (self.isChildReport) {
        [[JMVisualizeWebViewManager sharedInstance] resetChildWebView];
    } else {
        [[JMVisualizeWebViewManager sharedInstance] reset];
    }
}

#pragma mark - Helpers
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

#pragma mark - Print
- (void)preparePreviewForPrintWithCompletion:(void(^)(NSURL *resourceURL))completion
{
    if ([JMUtils isSupportVisualize]) {
        __weak typeof(self)weakSelf = self;
        self.exportCompletion = ^(NSString *resourcePath) {
            __strong typeof(self)strongSelf = weakSelf;
            [JMCancelRequestPopup dismiss];

            JMReportSaver *reportSaver = [[JMReportSaver alloc] initWithReport:strongSelf.report];
            [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
                [reportSaver cancelReport];
            }];
            [reportSaver saveReportWithName:[strongSelf tempReportName]
                                     format:[JSConstants sharedInstance].CONTENT_TYPE_PDF
                               resourcePath:resourcePath
                                 completion:^(JMSavedResources *savedReport, NSError *error) {
                                         [JMCancelRequestPopup dismiss];
                                         if (error) {
                                             if (error.code == JSSessionExpiredErrorCode) {
                                                 [strongSelf.restClient verifyIsSessionAuthorizedWithCompletion:^(BOOL isSessionAuthorized) {
                                                     if (strongSelf.restClient.keepSession && isSessionAuthorized) {
                                                         [strongSelf preparePreviewForPrintWithCompletion:completion];
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
            };

        [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:^{
            self.exportCompletion = nil;
        }];
        [self.reportLoader exportReportWithFormat:@"pdf"];
    } else {
        [super preparePreviewForPrintWithCompletion:completion];
    }
}

@end
