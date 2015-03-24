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


#import "JMVisualizeDashboardViewerVC.h"
#import "JMVisualizeClient.h"
#import "JMCancelRequestPopup.h"
#import "RKObjectmanager.h"


@interface JMVisualizeDashboardViewerVC() <JMVisualizeClientDelegate>
@property (strong, nonatomic) NSArray *rightButtonItems;
@property (strong, nonatomic) JMVisualizeClient *visualizeClient;
@property (assign, nonatomic) BOOL isCommandSend;
@end

@implementation JMVisualizeDashboardViewerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.visualizeClient = [JMVisualizeClient new];
    self.visualizeClient.delegate = self;
    self.visualizeClient.webView = self.webView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.rightButtonItems = self.navigationItem.rightBarButtonItems;
}

#pragma mark - Actions
- (void)minimizeDashboard
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = self.rightButtonItems;
    self.navigationItem.title = [self currentResourceLookup].label;
    [self.visualizeClient minimizeDashlet];
}

#pragma mark - Start Point
- (void)startLoadDashboard
{    
    self.isCommandSend = NO;
    [self.webView loadRequest:self.dashboard.resourceRequest];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL sholdStartFromSuperclass = [super webView:webView shouldStartLoadWithRequest:request
                                    navigationType:navigationType];
    
    return sholdStartFromSuperclass && ![self.visualizeClient isCallbackRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.isCommandSend) {
        NSLog(@"inject js");
        self.isCommandSend = YES;
        
        [self.webView.scrollView setZoomScale:0.1 animated:YES];
        
        NSString *jsMobilePath = [[NSBundle mainBundle] pathForResource:@"jaspermobile_dashboard" ofType:@"js"];
        
        NSError *error;
        NSString *jsMobile = [NSString stringWithContentsOfFile:jsMobilePath encoding:NSUTF8StringEncoding error:&error];
        if (jsMobile) {
            NSString *width = @"\"250%\"";
            NSString *height = @"\"250%\"";
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                width = @"\"150%\"";
                height = @"\"150%\"";
            }
            jsMobile = [jsMobile stringByReplacingOccurrencesOfString:@"CONTAINER_SIZE_WIDTH" withString:width];
            jsMobile = [jsMobile stringByReplacingOccurrencesOfString:@"CONTAINER_SIZE_HEIGHT" withString:height];

            [self.webView stringByEvaluatingJavaScriptFromString:jsMobile];
        } else {
            NSLog(@"load jaspermobile.js error: %@", error.localizedDescription);
        }
    } else {        
        [super webViewDidFinishLoad:webView];
    }
}

#pragma mark - JMVisualizeClientDelegate
- (void)visualizeClientDidEndLoading
{
    [self stopShowLoader];
}

- (void)visualizeClientDidMaximizeDashletWithTitle:(NSString *)title
{
    [self.webView.scrollView setZoomScale:0.1 animated:YES];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftBarButtonItem = [self backButtonWithTitle:[self currentResourceLookup].label
                                                               target:self
                                                               action:@selector(minimizeDashboard)];
    self.navigationItem.title = title;
}

@end
