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


#import "JMPrivacyPolicyViewController.h"
#import "UIAlertView+Additions.h"
#import "ALToastView.h"
#import "RNCachingURLProtocol.h"
#import "Reachability.h"

@interface JMPrivacyPolicyViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) JSRESTResource *resourceClient;
@property (nonatomic, strong) NSMutableArray *cachedRequestURLs;
@end

@implementation JMPrivacyPolicyViewController
objection_requires(@"resourceClient")

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"detail.settings.privacy.policy.title", nil);
    
    self.webView.scrollView.bounces = NO;
    
    [[JSObjection defaultInjector] injectDependencies:self];

    [self showPrivacyPolicy];
}

- (void) showPrivacyPolicy
{
    NSURL *ppURL = [NSURL URLWithString:kJMPrivacyPolicyURI];
    NSMutableURLRequest *ppRequest = [[NSMutableURLRequest alloc] initWithURL:ppURL cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:10.0];
    [ppRequest addValue:@"html/text" forHTTPHeaderField:kJSRequestResponceType];
    
    NSString *cachePath = [[RNCachingURLProtocol new] cachePathForRequest:ppRequest];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath] && [[Reachability reachabilityWithHostName:[ppURL host]] currentReachabilityStatus] == NotReachable) {
        [[UIAlertView localizedAlertWithTitle:@"error.noconnection.dialog.title" message:@"error.noconnection.dialog.msg" delegate:nil cancelButtonTitle:@"dialog.button.ok" otherButtonTitles:nil] show];
    } else {
        [self.webView loadRequest:ppRequest];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            [[UIAlertView localizedAlertWithTitle:nil message:@"detail.resource.viewer.open.link" completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (alertView.cancelButtonIndex != buttonIndex) {
                    [[UIApplication sharedApplication] openURL:request.URL];
                }
            } cancelButtonTitle:@"dialog.button.cancel" otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            [ALToastView toastInView:webView withText:JMCustomLocalizedString(@"detail.resource.viewer.can't.open.link", nil)];
        }
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startLoadingAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoadingAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoadingAnimating];
}

- (void) startLoadingAnimating
{
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) stopLoadingAnimating
{
    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
