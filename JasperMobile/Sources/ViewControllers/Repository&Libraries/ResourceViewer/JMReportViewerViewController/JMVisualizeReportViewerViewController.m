/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMVisualizeReportViewerViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMVisualizeReportLoader.h"
#import "JMVisualizeReport.h"
#import "JMReportViewerToolBar.h"
#import "JMSaveReportViewController.h"

#import "SWRevealViewController.h"
#import "JMBaseCollectionViewController.h"
#import "JMWebConsole.h"
#import "JMWebViewController.h"

@interface JMVisualizeReportViewerViewController () <JMVisualizeReportLoaderDelegate>
@property (nonatomic, strong) JMVisualizeReportLoader *reportLoader;
@property (nonatomic, assign) BOOL isChildReport;
@end

@implementation JMVisualizeReportViewerViewController

@synthesize reportLoader = _reportLoader;

#pragma mark - Actions
- (void)cancelResourceViewingAndExit
{
    if (self.isChildReport) {
        [self closeChildReport];
    } else {
        [super cancelResourceViewingAndExit];
    }
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    if (self.report.isReportEmpty) {
        [self showEmptyReportMessage];
    }
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

- (void)closeChildReport
{
    [[JMVisualizeWebViewManager sharedInstance] resetChildWebView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupSubviews
{
    CGRect rootViewBounds = self.navigationController.view.bounds;
    UIWebView *webView = [[JMVisualizeWebViewManager sharedInstance] webViewWithParentFrame:rootViewBounds asSecondary:self.isChildReport];
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;
}

#pragma mark - Custom accessors
- (JMVisualizeReportLoader *)reportLoader
{
    if (!_reportLoader) {
        _reportLoader = [JMVisualizeReportLoader loaderWithReport:self.report];
        _reportLoader.webView = self.webView;
        self.webView.delegate = _reportLoader;
        _reportLoader.delegate = self;
    }
    return _reportLoader;
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar pageDidChanged:(NSInteger)page
{
    // TODO: need support sessions
    // start show loading indicator
    [self.reportLoader fetchPageNumber:page withCompletion:@weakself(^(BOOL success, NSError *error)) {
        if (success) {
            // succcess action
        } else {
            [self handleError:error];
        }
        // stop show loading indicator
    }@weakselfend];
}

#pragma mark - Run report
- (void)runReportWithPage:(NSInteger)page
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self cancelResourceViewingAndExit];
    }@weakselfend];

    [self hideEmptyReportMessage];

    [self.reportLoader runReportWithPage:page completion:@weakself(^(BOOL success, NSError *error)) {
        [self stopShowLoader];

        if (success) {
            // succcess action
        } else {
            [self handleError:error];
        }
    }@weakselfend];
}

- (void)updateReportWithNewParameters
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
            [self cancelResourceViewingAndExit];
        }@weakselfend];

    [self hideEmptyReportMessage];

    [self.reportLoader applyReportParametersWithCompletion:@weakself(^(BOOL success, NSError *error)) {
        [self stopShowLoader];

        if (success) {
            // succcess action
        } else {
            [self handleError:error];
        }
    }@weakselfend];
}

#pragma mark - JMRefreshable
- (void)refresh
{
    if (self.reportLoader.isReportInLoadingProcess) {
        [self hideEmptyReportMessage];
        [self.report restoreDefaultState];
        [self updateToobarAppearence];
        // session
        [self.reportLoader refreshReportWithCompletion:@weakself(^(BOOL success, NSError *error)) {
            [self stopShowLoader];
            if (success) {
                // succcess action
            } else {
                [self handleError:error];
            }
        }@weakselfend];
    } else {
        [super refresh];
    }
}

- (void)handleError:(NSError *)error
{
    if (error.code == JMReportLoaderErrorTypeAuthentification) {

        [self.restClient deleteCookies];
        [self resetSubViews];

        NSInteger reportCurrentPage = self.report.currentPage;
        [self.report restoreDefaultState];
        if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
            // TODO: Need add restoring for current page
            [self runReportWithPage:reportCurrentPage];
        } else {
            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self cancelResourceViewingAndExit];
            } @weakselfend];
        }

    } else {
        [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self cancelResourceViewingAndExit];
        }];
    }
}

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReceiveOnClickEventForReport:(JMVisualizeReport *)report
{
    NSString *identifier = @"JMVisualizeReportViewerViewController";
    JMVisualizeReportViewerViewController *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    reportViewController.report = report;
    reportViewController.isChildReport = YES;
    reportViewController.backButtonTitle = self.title;

    [self.navigationController pushViewController:reportViewController animated:YES];
}

-(void)reportLoader:(JMVisualizeReportLoader *)reportLoder didReceiveOnClickEventForReference:(NSURL *)urlReference
{
    [[UIApplication sharedApplication] openURL:urlReference];
}

- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReceiveOutputResourcePath:(NSString *)resourcePath fullReportName:(NSString *)fullReportName
{
    // sample
    // [self.reportLoader exportReportWithFormat:@"pdf"];
    // html format currently vis.js doesn't support
    // here we can receive link on file.
}

#pragma mark - UIWebView helpers
- (void)resetSubViews
{
    [self.webView stopLoading];
    [[JMVisualizeWebViewManager sharedInstance] reset];
}

//#pragma mark - Helpers
//- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
//{
//    JMMenuActionsViewAction availableAction = [super availableActionForResource:resource] | self.menuActionsViewAction;
//    if (self.report.isReportWithInputControls) {
//        availableAction |= JMMenuActionsViewAction_Edit;
//    }
//    return availableAction;
//}

@end
