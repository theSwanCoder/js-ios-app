/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSUIDashboardViewController.m
//  Jaspersoft Corporation
//

#import "JSUILoadingView.h"
#import "JSUIReportUnitViewController.h"
#import "JSUIDashboardViewController.h"

@interface JSUIDashboardViewController()

@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

@end

@implementation JSUIDashboardViewController

@synthesize descriptor = _descriptor;
@synthesize resourceClient = _resourceClient;
@synthesize webView = _webView;
@synthesize loadingIndicator = _loadingIndicator;

- (void)viewWillAppear:(BOOL)animated {
    NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl,
                              @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                              self.descriptor.uriString];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [JSUIReportUnitViewController setOriginsForLoadingIndicator:self.loadingIndicator interfaceOrientation:self.interfaceOrientation];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    [self.resourceClient resource:@"/" usingBlock:^(JSRequest *request) {
        request.finishedBlock = ^(JSOperationResult *result) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashboardUrl]]];
        };
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return true;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [JSUIReportUnitViewController setOriginsForLoadingIndicator:self.loadingIndicator interfaceOrientation:toInterfaceOrientation];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingIndicator stopAnimating];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
