/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMEULAViewController.h"
#import "JMUtils.h"
#import "JMLocalization.h"

@interface JMEULAViewController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation JMEULAViewController

#pragma mark - LifeCycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMLocalizedString(@"about_eula_title");

    if (self.shouldUserAccept) {
        UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"action_title_accept")
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(agreeAction:)];
        self.navigationItem.rightBarButtonItem = acceptButton;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:@"EULA" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Actions
- (IBAction)agreeAction:(id)sender
{
    if (self.completion) {
        self.completion();
    }
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    JMLog(@"request: %@", request);
    JMLog(@"navigationType: %@", @(navigationType));

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}


@end
