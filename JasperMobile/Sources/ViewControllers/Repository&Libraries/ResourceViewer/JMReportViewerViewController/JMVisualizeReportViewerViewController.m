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
#import "JMReportOptionsViewController.h"
#import "JMWebConsole.h"
#import "JMWebViewController.h"
#import "JMVisualizeWebViewManager.h"

@interface JMVisualizeReportViewerViewController () <JMVisualizeReportLoaderDelegate>
@property (nonatomic, strong) JMVisualizeReportLoader *reportLoader;
@end

@implementation JMVisualizeReportViewerViewController

@synthesize reportLoader = _reportLoader;

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isStartFromAnotherReport = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[self clearWebView];
}

#pragma mark - Actions
- (void)backButtonTapped:(id) sender
{
    [self clearWebView];
    [super backButtonTapped:sender];
}

- (void)backToPreviousReport
{
    [self clearWebView];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.webView removeFromSuperview];
    
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    JMVisualizeReportViewerViewController *reportViewController = self.navigationController.viewControllers[viewControllersCount - 2];
    
    //
    [reportViewController.view insertSubview:self.webView belowSubview:reportViewController.activityIndicator];
    self.webView.delegate = reportViewController.reportLoader;
    reportViewController.returnFromPreviousReportCompletion = @weakself(^()) {
        [reportViewController.reportLoader refreshReport];
    }@weakselfend;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setups
- (void)setupNavigationItems
{
    if (!self.isStartFromAnotherReport) {
        [super setupNavigationItems];
    }
}

- (void)setupWebView // overriden with another webView
{
    UIWebView *webView = [JMVisualizeWebViewManager sharedInstance].webView;
    CGRect rootViewBounds = self.navigationController.view.bounds;
    webView.frame = rootViewBounds;
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
            // session
    
    
    // start show loading indicator
    [self.reportLoader loadPageNumber:page withReportLoadCompletion:@weakself(^(BOOL success, NSError *error)) {
        // stop show loading indicator
    }@weakselfend];
}

#pragma mark - Run report
- (void)runReport
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.reportLoader cancelReport];
        [self backToPreviousReport];
    }@weakselfend];
    
    [self.reportLoader fetchStartPageWithReportLoadCompletion:@weakself(^(BOOL success, NSError *error)) {
        [self stopShowLoader];
        
        if (success) {
            [self hideEmptyReportMessage];
        } else {
            if (error.code == JMReportLoaderErrorTypeEmtpyReport) {
                [self showEmptyReportMessage];
            } else {
                [UIAlertView localizedAlertWithTitle:@"detail.report.viewer.error.title"
                                             message:error.localizedDescription
                                          completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              [self backToPreviousView];
                                          }
                                   cancelButtonTitle:@"dialog.button.ok"
                                   otherButtonTitles:nil];
            }
        }
        
    }@weakselfend];
}

- (void)reloadReport
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    [self hideEmptyReportMessage];
//    [self.report restoreDefaultState];
    
    //[self clearWebView];
    
    NSLog(@"subviews: %@", self.view.subviews);
    if ([self.webView isLoading]) {
        NSLog(@"web view is loading");
    }
    [super updateToobarAppearence];
    [self.reportLoader refreshReport];
}

#pragma mark - JMRefreshable
- (void)refresh
{
    if (self.reportLoader.isReportInLoadingProcess) {
        //[self hideEmptyReportMessage];
        [self.report restoreDefaultState];
        [super updateToobarAppearence];
        // session
        [self.reportLoader refreshReport];
    } else {
        [super refresh];
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
            UIBarButtonItem *backItem = [self backButtonWithTitle:backItemTitle
                                                           target:reportViewController
                                                           action:@selector(backToPreviousReport)];
            reportViewController.navigationItem.leftBarButtonItem = backItem;
            
            [self clearWebView];
            [self.navigationController pushViewController:reportViewController animated:YES];
        }
    }@weakselfend];
}

- (void)clearWebView
{
    [self.webView stopLoading];
    NSLog(@"contentScaleFactor: %f", self.webView.contentScaleFactor);
    NSLog(@"zoomScale: %f", self.webView.scrollView.zoomScale);
    
    // reset zoom in webView
    //[self.webView.scrollView setZoomScale:0.1 animated:NO];
    [self.reportLoader destroyReport];
}

#pragma mark - UIWebView helpers
- (void)startShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
}


- (void)stopShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
}

@end
