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


#import "JMReportViewerViewController.h"
#import "JMReportLoader.h"
#import "JMRestReport.h"

#import "JMReportViewerToolBar.h"
#import "JMSaveReportViewController.h"

#import "SWRevealViewController.h"
#import "JMBaseCollectionViewController.h"
#import "JMReportOptionsViewController.h"


@interface JMReportViewerViewController ()
@property (nonatomic, strong, readwrite) JMReportLoader *reportLoader;
@end

@implementation JMReportViewerViewController

@synthesize reportLoader = _reportLoader;

#pragma mark - Custom accessors
- (JMReportLoader *)reportLoader
{
    if (!_reportLoader) {
        _reportLoader = [JMReportLoader loaderWithReport:self.report];
    }
    return _reportLoader;
}

#pragma mark - JMReportViewerToolBarDelegate
- (void)toolbar:(JMReportViewerToolBar *)toolbar pageDidChanged:(NSInteger)page
{
    [self.reportLoader fetchPageNumber:page withCompletion:@weakself(^(BOOL success, NSError *error)) {
        if (success) {
            [self.webView stopLoading];
            [self.webView loadHTMLString:self.report.HTMLString
                                 baseURL:[NSURL URLWithString:self.report.baseURLString]];
        } else {
            [self handleReportLoaderError:error];
        }
    }@weakselfend];
}

#pragma mark - Run report
- (void)runReport
{
    [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)) {
        [self.restClient cancelAllRequests];
        [self.reportLoader cancelReport];
        [self backToPreviousView];
    }@weakselfend];
    
    [self.reportLoader fetchStartPageWithCompletion:@weakself(^(BOOL success, NSError *error)) {
        [self stopShowLoader];
        
        if (success) {
            [self hideEmptyReportMessage];
            [self.report saveCurrentState];
            
            [self.webView stopLoading];
            [self.webView loadHTMLString:self.report.HTMLString
                                 baseURL:[NSURL URLWithString:self.report.baseURLString]];
        } else {
            if (error.code == JMReportLoaderErrorTypeEmtpyReport) {
                [self showEmptyReportMessage];
            } else {
                [self handleReportLoaderError:error];
            }
        }
    }@weakselfend];
}

#pragma mark - Error Report handlers
- (void) handleReportLoaderError:(NSError *)error
{
    if (error.code == JSSessionExpiredErrorCode) {
        if (self.restClient.keepSession && [self.restClient isSessionAuthorized]) {
            [self runReport];
        } else {
            [JMUtils showLoginViewAnimated:YES completion:@weakself(^(void)) {
                [self runReport];
            } @weakselfend];
        }
    } else {
        if (self.report.requestId) {
            [self.reportLoader cancelReport];
        }
        [JMUtils showAlertViewWithError:error];
    }
}
@end
