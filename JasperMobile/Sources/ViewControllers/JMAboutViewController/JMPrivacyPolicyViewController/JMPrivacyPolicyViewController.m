/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
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

@interface JMPrivacyPolicyViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *cachedRequestURLs;
@end

@implementation JMPrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = JMLocalizedString(@"about_privacy_policy_title");
    
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
                                                                                    cancelButtonTitle:@"dialog_button_cancel"
                                                                              cancelCompletionHandler:nil];
            [alertController addActionWithLocalizedTitle:@"dialog_button_ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
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
