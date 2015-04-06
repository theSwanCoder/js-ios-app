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
@property (nonatomic, assign) BOOL isStartFromAnotherReport;
@property (nonatomic, copy) void(^returnFromPreviousReportCompletion)(void);

@end

@implementation JMVisualizeReportViewerViewController

@synthesize reportLoader = _reportLoader;

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isStartFromAnotherReport = NO;
}

#pragma mark - Actions
- (void)backToPreviousReport
{
    [self resetSubViews];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.webView removeFromSuperview];

    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    JMVisualizeReportViewerViewController *reportViewController = self.navigationController.viewControllers[viewControllersCount - 2];

    //
    [reportViewController.view insertSubview:self.webView belowSubview:reportViewController.activityIndicator];
    self.webView.delegate = reportViewController.reportLoader;
    reportViewController.returnFromPreviousReportCompletion = @weakself(^()) {
        reportViewController.returnFromPreviousReportCompletion = nil;
        [reportViewController.reportLoader refreshReportWithCompletion:@weakself(^(BOOL success, NSError *error)) {
            if (success) {
                // succcess action
                //[self hideEmptyReportMessage];
            } else {
                [self handleError:error];
            }
        }@weakselfend];
    }@weakselfend;

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setups
- (void)setupNavigationItems
{
    [super setupNavigationItems];
    if (self.isStartFromAnotherReport) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setupSubviews
{
    CGRect rootViewBounds = self.navigationController.view.bounds;
    UIWebView *webView = [[JMVisualizeWebViewManager sharedInstance] webViewWithParentFrame:rootViewBounds];
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;
}

#pragma mark - Start point
- (void)startLoadReport
{
    if (self.returnFromPreviousReportCompletion) {
        self.returnFromPreviousReportCompletion();
    } else {
        [super startLoadReport];
    }
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
        // stop show loading indicator
    }@weakselfend];
}

- (void)handleReportLoaderDidChangeCountOfPages
{
    if (self.report.isReportEmpty) {
        [self showEmptyReportMessage];
    }
}

#pragma mark - Run report
- (void)runReport
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.reportLoader cancelReport];
        [self cancelResourceViewingAndExit];
    }@weakselfend];

    [self hideEmptyReportMessage];

    [self.reportLoader fetchStartPageWithCompletion:@weakself(^(BOOL success, NSError *error)) {
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
        [super updateToobarAppearence];
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
        [self.webView loadHTMLString:nil baseURL:nil];
        [JMVisualizeWebViewManager sharedInstance].isVisualizeLoaded = NO;

        [self.report restoreDefaultState];
        if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
            [self runReport];
        } else {
            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self cancelResourceViewingAndExit];
            } @weakselfend];
        }

    } else {
        [[UIAlertView localizedAlertWithTitle:@"detail.report.viewer.error.title"
                                      message:error.localizedDescription
                                   completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       [self cancelResourceViewingAndExit];
                                   }
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles:nil] show];
    }
}

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReciveOnClickEventForReport:(JMVisualizeReport *)report withParameters:(NSDictionary *)reportParameters
{
    NSString *reportURI = [report.reportURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self loadInputControlsWithReportURI:reportURI completion:@weakself(^(NSArray *inputControls)) {
        report.isInputControlsLoaded = YES;
        if (inputControls) {
            [report updateInputControls:inputControls];
            [report applyReportParameters:reportParameters];

            NSString *identifier = @"JMVisualizeReportViewerViewController";

            JMVisualizeReportViewerViewController *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            reportViewController.report = report;
            reportViewController.isStartFromAnotherReport = YES;


            NSString *backItemTitle = self.title;
            NSString *title = report.resourceLookup.label;

            // detect backButton text width to truncate with '...'
            NSDictionary *textAttributes = @{NSFontAttributeName : [JMFont navigationBarTitleFont]};
            CGSize titleTextSize = [title sizeWithAttributes:textAttributes];
            CGFloat titleTextWidth = titleTextSize.width;
            CGSize backItemTextSize = [backItemTitle sizeWithAttributes:textAttributes];
            CGFloat backItemTextWidth = backItemTextSize.width;
            CGFloat backItemOffset = 12;

            CGFloat viewWidth = CGRectGetWidth(self.view.bounds);

            if ( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) {
                CGFloat charWidth = backItemTextWidth/backItemTitle.length;
                CGFloat excessWidth = (backItemOffset + backItemTextWidth) - (viewWidth - titleTextWidth) / 2;

                NSInteger excessLength = excessWidth/charWidth;
                NSInteger remainedLength = backItemTitle.length - excessLength;
                NSString *replaceSymbols = @"...";
                if (remainedLength < 10) {
                    backItemTitle = replaceSymbols;
                } else {
                    NSRange range = NSMakeRange(backItemTitle.length - (excessLength + replaceSymbols.length), excessLength + replaceSymbols.length);
                    backItemTitle = [backItemTitle stringByReplacingCharactersInRange:range withString:replaceSymbols];
                }
            }

            UIBarButtonItem *backItem = [self backButtonWithTitle:backItemTitle
                                                           target:reportViewController
                                                           action:@selector(backToPreviousReport)];
            reportViewController.navigationItem.leftBarButtonItem = backItem;

            [self resetSubViews];
            [self.navigationController pushViewController:reportViewController animated:YES];
        }
    }@weakselfend];
}

-(void)reportLoader:(JMVisualizeReportLoader *)reportLoder didReciveOnClickEventForReference:(NSURL *)urlReference
{
    [[UIApplication sharedApplication] openURL:urlReference];
}

#pragma mark - UIWebView helpers
- (void)resetSubViews
{
    [self.webView stopLoading];
    NSLog(@"contentScaleFactor: %f", self.webView.contentScaleFactor);
    NSLog(@"zoomScale: %f", self.webView.scrollView.zoomScale);

    // reset zoom in webView
    //[self.webView.scrollView setZoomScale:0.1 animated:NO];
    [self.reportLoader destroyReport];
}

- (void)startShowLoadingIndicators
{
    [JMUtils showNetworkActivityIndicator];
}

- (void)stopShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
}

@end
