/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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

//
//  JMReportViewerViewController.m
//  Jaspersoft Corporation
//

#import "JMReportViewerViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMRequestDelegate.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import <Objection-iOS/Objection.h>

@interface JMReportViewerViewController()
@property (nonatomic, strong) NSString *tempDirectory;
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, weak) JMReportDownloaderUtil *reportDownloader;
@end

@implementation JMReportViewerViewController
objection_requires(@"resourceClient", @"reportClient", @"constants", @"reportDownloader")
inject_default_rotation()

@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.saveButton.title = JMCustomLocalizedString(@"dialog.button.save", nil);
}

#pragma mark - UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [self createTempDirectory];

    // TODO: change server version to 5.2.0 instead of 5..5
    if (self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_TWO) {
        [self runReportExecution];
    } else {
        [self runReport];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setParameters:self.parameters];
    [destinationViewController setDelegate:self];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        [JMUtils hideNetworkActivityIndicator];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.tempDirectory error:nil];
        self.webView = nil;
        
        // Cancel all active requests before disappearing
        if (![JMRequestDelegate isRequestPoolEmpty]) {
            [self.reportClient cancelAllRequests];
            [JMRequestDelegate clearRequestPool];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Private -

- (void)createTempDirectory {
    NSString *tempDirectory = NSTemporaryDirectory();
    self.tempDirectory = [tempDirectory stringByAppendingPathComponent:kJMReportsDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:self.tempDirectory
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
}

#pragma mark Rest v2

- (void)runReportExecution
{
    [JMCancelRequestPopup dismiss];
    [self.activityIndicator startAnimating];
    
    __weak JMReportViewerViewController *reportViewerViewController = self;
    
    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        
        NSString *reportUrl = [reportViewerViewController.reportClient generateReportOutputUrl:response.requestId exportOutput:export.uuid];
        [reportViewerViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]]];
    }];
    
    [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.constants.CONTENT_TYPE_HTML interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:YES transformerKey:nil pages:nil attachmentsPrefix:nil parameters:self.parameters delegate:delegate];
}

#pragma mark Rest v1

- (void)runReport
{
    [JMCancelRequestPopup dismiss];
    [self.activityIndicator startAnimating];

    __weak JMReportViewerViewController *reportViewerViewController = self;
    
    [self.reportDownloader runReport:self.resourceLookup.uri parameters:self.parameters format:self.constants.CONTENT_TYPE_HTML path:self.tempDirectory completionBlock:^(NSString *fullReportPath) {
        NSURL *reportPath = [NSURL fileURLWithPath:fullReportPath];
        [reportViewerViewController.webView loadRequest:[NSURLRequest requestWithURL:reportPath]];
    }];
}

@end
