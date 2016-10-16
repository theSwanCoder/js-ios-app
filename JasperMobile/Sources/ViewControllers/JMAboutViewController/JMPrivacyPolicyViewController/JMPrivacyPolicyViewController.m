/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
#import "ALToastView.h"
#import "RNCachingURLProtocol.h"
#import "Reachability.h"
#import "JMLocalization.h"
#import "JMConstants.h"
#import "JaspersoftSDK.h"
#import "JMUtils.h"
#import "UIAlertController+Additions.h"
#import "NSObject+Additions.h"

@interface JMPrivacyPolicyViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *cachedRequestURLs;
@end

@implementation JMPrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = JMLocalizedString(@"about_privacy_policy_title");
    [self.view setAccessibility:NO withTextKey:@"about_privacy_policy_title" identifier:JMPrivacyPolicyPageAccessibilityId];

    self.webView.scrollView.bounces = NO;
    
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];

    [self showPrivacyPolicy];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
}

- (void)dealloc
{
    [NSURLProtocol unregisterClass:[RNCachingURLProtocol class]];
}

- (void) showPrivacyPolicy
{
    NSURL *ppURL = [NSURL URLWithString:kJMPrivacyPolicyURI];
    NSMutableURLRequest *ppRequest = [[NSMutableURLRequest alloc] initWithURL:ppURL cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:10.0];
    [ppRequest addValue:@"html/text" forHTTPHeaderField:kJSRequestResponceType];
    
    NSString *cachePath = [[RNCachingURLProtocol new] cachePathForRequest:ppRequest];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath] && [[Reachability reachabilityWithHostName:[ppURL host]] currentReachabilityStatus] == NotReachable) {
        NSString *errorMessage = JMLocalizedString(@"error_noconnection_dialog_msg");
        NSError *error = [NSError errorWithDomain:@"error_noconnection_dialog_title" code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        __weak typeof(self) weakSelf = self;
        [JMUtils presentAlertControllerWithError:error completion:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.webView loadRequest:ppRequest];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_attention"
                                                                                              message:@"resource_viewer_open_link"
                                                                                    cancelButtonType:JMAlertControllerActionType_Cancel
                                                                              cancelCompletionHandler:nil];
            [alertController addActionWithType:JMAlertControllerActionType_Ok style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [ALToastView toastInView:webView withText:JMLocalizedString(@"resource_viewer_can_not_open_link")];
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
    [JMUtils showNetworkActivityIndicator];
}

- (void) stopLoadingAnimating
{
    [self.activityIndicator stopAnimating];
    [JMUtils hideNetworkActivityIndicator];
}
@end
