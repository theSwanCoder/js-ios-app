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

@interface JMVisualizeReportViewerViewController () <JMVisualizeReportLoaderDelegate>
@property (nonatomic, strong) JMVisualizeReportLoader *reportLoader;
@property (nonatomic, assign) BOOL isRefreshWebView;
@end

@implementation JMVisualizeReportViewerViewController

@synthesize reportLoader = _reportLoader;

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[JMWebConsole enable];
    self.isRefreshWebView = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

#pragma mark - Custom accessors
- (JMVisualizeReportLoader *)reportLoader
{
    if (!_reportLoader) {
        _reportLoader = [JMVisualizeReportLoader loaderWithReport:self.report];
        _reportLoader.webView = self.webView;
        _reportLoader.delegate = self;
        self.webView.delegate = _reportLoader;
    }
    return _reportLoader;
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar pageDidChanged:(NSInteger)page
{
    [self.reportLoader loadPageNumber:page withLoadHTMLCompletion:@weakself(^(BOOL success, NSError *error)) {
        
    }@weakselfend reportLoadCompletion:@weakself(^(BOOL success, NSError *error)) {
        
    }@weakselfend];
}

#pragma mark - Run report
- (void)runReport
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.reportLoader cancelReport];
        [self backToRootVC];
    }@weakselfend];
    
    [self hideEmptyReportMessage];
    
    [self.reportLoader fetchStartPageWithLoadHTMLCompletion:@weakself(^(BOOL success, NSError *error)) {
        if (success) {
            [self.webView stopLoading];
            [self.webView loadHTMLString:self.report.HTMLString
                                 baseURL:[NSURL URLWithString:self.report.baseURLString]];
        } else {
            NSLog(@"Error loading HTML%@", error.localizedDescription);
        }
    }@weakselfend reportLoadCompletion:@weakself(^(BOOL success, NSError *error)) {
        [self stopShowLoader];
        if (success) {
            [self hideEmptyReportMessage];
        } else {
            if (error.code == JMReportLoaderErrorTypeEmtpyReport) {
                [self showEmptyReportMessage];
            } else {
                [self stopShowLoader];
                [UIAlertView localizedAlertWithTitle:@"detail.report.viewer.error.title"
                                             message:error.localizedDescription
                                          completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              [self backToRootVC];
                                          }
                                   cancelButtonTitle:@"dialog.button.ok"
                                   otherButtonTitles:nil];
            }
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
        [self.reportLoader reloadReportWithInputControls:self.report.inputControls];
    } else {
        [super refresh];
    }
}

#pragma mark - JMVisualizeReportLoaderDelegate
//- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReciveClickOnReport:(JMVisualizeReport *)report
//{
//    NSLog(@"click on report: %@", report);
//    NSString *identifier = @"JMVisualizeReportViewerViewController";
// 
//    JMVisualizeReportViewerViewController *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
//    reportViewController.report = report;
//    reportViewController.shouldLoadInputControls = NO;
//    
//    [self.navigationController pushViewController:reportViewController animated:YES];
//}

- (void)reportLoader:(JMVisualizeReportLoader *)reportLoader didReciveOnClickEventForReport:(JMVisualizeReport *)report withParameters:(NSDictionary *)reportParameters
{
    
    NSLog(@"click on report: %@", report);
    NSString *identifier = @"JMVisualizeReportViewerViewController";
    
    JMVisualizeReportViewerViewController *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    reportViewController.report = report;
    
    [self.navigationController pushViewController:reportViewController animated:YES];
}

@end
