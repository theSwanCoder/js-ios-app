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
#import "JMUtils.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import <Objection-iOS/Objection.h>

@interface JMReportViewerViewController()
@property (nonatomic, strong) NSString *tempDirectory;
@property (nonatomic, strong) NSString *reportPath;
@end

@implementation JMReportViewerViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")
inject_default_rotation()

@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    if (self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD) {
        [self generateReportURL];
    } else {
        [self runReport];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [JMUtils hideNetworkActivityIndicator];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:self.tempDirectory]) {
        [fileManager removeItemAtPath:self.tempDirectory error:nil];
    }

    self.webView = nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Private -
#pragma mark Rest v2

- (void)generateReportURL
{
    NSURL *reportURL = [NSURL URLWithString:[self.reportClient generateReportUrl:self.resourceLookup.uri
                                                                    reportParams:self.parameters
                                                                            page:0
                                                                          format:self.reportFormat]];
    NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
    [self.webView loadRequest:request];
}

#pragma mark Rest v1

- (void)runReport
{
    __weak JMReportViewerViewController *reportViewerViewController = self;

    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.reportClient cancelBlock:^{
        [reportViewerViewController.navigationController popViewControllerAnimated:YES];
    }];

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportDescriptor *reportDescriptor = [result.objects objectAtIndex:0];
        NSString *uuid = reportDescriptor.uuid;

        NSString *tempDirectory = NSTemporaryDirectory();

        reportViewerViewController.tempDirectory = [tempDirectory stringByAppendingPathComponent:uuid];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if (![fileManager fileExistsAtPath:reportViewerViewController.tempDirectory]) {
            [fileManager createDirectoryAtPath:reportViewerViewController.tempDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }

        for (JSReportAttachment *attachment in reportDescriptor.attachments) {
            NSString *fileName = attachment.name;
            NSString *fileType = attachment.type;
            NSString *extension;

            if ([fileType isEqualToString:@"text/html"]) {
                extension = @".html";
            } else if ([fileType isEqualToString:@"application/pdf"]) {
                extension = @".pdf";
            }

            // The path to write a file
            NSString *resourceFile = [self.tempDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, extension]];

            // Set as main file to render in web view if extension is equals to HTML or PDF
            if (extension) {
                reportViewerViewController.reportPath = resourceFile;
            }

            [self.reportClient reportFile:uuid fileName:fileName path:resourceFile usingBlock:^(JSRequest *request) {
                request.timeoutInterval = 0;
                // Request delegate uses as counter for asynchronous requests and finish block is not needed
                request.delegate = [JMRequestDelegate requestDelegateForFinishBlock:nil];
            }];
        }
    }];

    [JMRequestDelegate setFinalBlock:^{
        NSURL *reportPath = [NSURL fileURLWithPath:reportViewerViewController.reportPath];
        [reportViewerViewController.webView loadRequest:[NSURLRequest requestWithURL:reportPath]];
    }];

    [self.reportClient runReport:self.resourceLookup.uri reportParams:self.parameters format:self.reportFormat delegate:delegate];
}

@end
