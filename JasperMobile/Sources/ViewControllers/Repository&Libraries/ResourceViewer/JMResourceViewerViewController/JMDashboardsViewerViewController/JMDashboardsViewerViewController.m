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


#import "JMDashboardsViewerViewController.h"
#import "JMVisualizeClient.h"
#import "JMCancelRequestPopup.h"
#import "RKObjectmanager.h"


@interface JMDashboardsViewerViewController()
@property (nonatomic, assign, getter=isLoaderVisible) BOOL loaderVisible;
@end

@implementation JMDashboardsViewerViewController

#pragma mark - UIViewController LifeCycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.loaderVisible = NO;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (self.navigationController && self.navigationController.visibleViewController == self && self.isViewLoaded) {
        if (!self.isLoaderVisible) {
            self.loaderVisible = YES;
            [self startShowLoaderWithMessage:@"status.loading" cancelBlock:@weakself(^(void)){
                    [self resetSubViews];
                    [self.navigationController popViewControllerAnimated:YES];
                }@weakselfend];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    self.loaderVisible = NO;
    [self stopShowLoader];
    [super webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    self.loaderVisible = NO;
    [self stopShowLoader];
}

@end
