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

@interface JMPrivacyPolicyViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) JSRESTResource *resourceClient;

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
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), @weakself(^(void)){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:ppURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  timeoutInterval:10.0];
        
        NSURLCache *ppCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:10 * 1024 * 1024 diskPath:nil];
        NSCachedURLResponse *cachedResponce = [ppCache cachedResponseForRequest:request];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)[cachedResponce response];
        NSData *loadedData = nil;
        
        if (httpResponse) {
            loadedData = [cachedResponce data];
        } else {
            loadedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), @weakself(^(void)) {
            NSString *htmlString = [[NSString alloc] initWithData:loadedData encoding:NSUTF8StringEncoding];
            [self.webView loadHTMLString:htmlString baseURL:ppURL];
            if (!cachedResponce && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                NSCachedURLResponse *loadedCachedResponce = [[NSCachedURLResponse alloc] initWithResponse:httpResponse data:loadedData];
                [ppCache storeCachedResponse:loadedCachedResponce forRequest:request];
            }
        }@weakselfend);
    }@weakselfend);
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
