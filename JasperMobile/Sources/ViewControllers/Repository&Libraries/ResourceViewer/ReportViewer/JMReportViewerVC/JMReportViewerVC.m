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


#import "JMReportViewerVC.h"
#import "JSResourceLookup+Helpers.h"
#import "JMReportViewerConfigurator.h"

@interface JMReportViewerVC () <JMReportLoaderDelegate>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, assign) BOOL isChildReport;
@end

@implementation JMReportViewerVC

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
    if (self.report.isReportEmpty) {
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

    CGRect rootViewBounds = self.navigationController.view.bounds;
    id webView = [self.configurator webViewWithFrame:rootViewBounds asSecondary:self.isChildReport];
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
}

#pragma mark - Custom accessors
- (id<JMReportLoader>)reportLoader
{
    return [self.configurator reportLoader];
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
            [self.reportLoader cancelReport];
            [self cancelResourceViewingAndExit:YES];
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
            [self.reportLoader cancelReport];
            [self cancelResourceViewingAndExit:YES];
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
    [self.report restoreDefaultState];
    [self updateToobarAppearence];
    [self runReportWithPage:1];
}

- (void)refreshReport
{
    [self hideEmptyReportMessage];
    [self updateToobarAppearence];
    [self.reportLoader refreshReportWithCompletion:@weakself(^(BOOL success, NSError *error)) {
            [self stopShowLoader];
            if (success) {
                // succcess action
                [self updateToobarAppearence];
            } else {
                [self handleError:error];
            }
        }@weakselfend];
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
                    [self cancelResourceViewingAndExit:YES];
                } @weakselfend];
        }

    } else if (error.code == JMReportLoaderErrorTypeEmtpyReport) {
        [self showEmptyReportMessage];
    } else {
        [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self cancelResourceViewingAndExit:YES];
        }];
    }






//    if (error.code == JSSessionExpiredErrorCode) {
//        if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
//            [self runReportWithPage:self.report.currentPage];
//        } else {
//            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
//                    [self cancelResourceViewingAndExit:YES];
//                } @weakselfend];
//        }
//    } else {
//        if (self.report.requestId) {
//            [self.reportLoader cancelReport];
//        }
//        [JMUtils showAlertViewWithError:error];
//    }



}

#pragma mark - JMVisualizeReportLoaderDelegate
- (void)reportLoader:(id<JMReportLoader>)reportLoader didReceiveOnClickEventForResourceLookup:(JSResourceLookup *)resourceLookup withParameters:(NSDictionary *)reportParameters
{
    NSString *reportURI = [resourceLookup.uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self loadInputControlsWithReportURI:reportURI completion:@weakself(^(NSArray *inputControls, NSError *error)) {
            if (error) {
                [JMUtils showAlertViewWithError:error completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self cancelResourceViewingAndExit:YES];
                }];
            } else {
                JMReportViewerVC *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:[resourceLookup resourceViewerVCIdentifier]];
                reportViewController.resourceLookup = resourceLookup;
                [reportViewController.report updateInputControls:inputControls];
                reportViewController.isChildReport = YES;

                [self resetSubViews];
                [self.navigationController pushViewController:reportViewController animated:YES];
            }
        }@weakselfend];
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
}

#pragma mark - UIWebView helpers
- (void)resetSubViews
{
    [[JMVisualizeWebViewManager sharedInstance] reset];
}

@end
