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


#import "JMResourceViewerViewController.h"
#import "JMWebViewManager.h"
#import "ALToastView.h"
#import "JSResourceLookup+Helpers.h"
#import "JMPrintResourceViewController.h"
#import "JMMainNavigationController.h"

@interface JMResourceViewerViewController () <UIPrintInteractionControllerDelegate>
@property (nonatomic, weak, readwrite) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UINavigationController *printNavController;
@end

@implementation JMResourceViewerViewController

- (void)dealloc
{
    [[JMWebViewManager sharedInstance] reset];
}

#pragma mark - UIViewController LifeCycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.webView.loading) {
        [self stopShowLoadingIndicators];
        // old dashboards don't load empty page
        //[self.webView stopLoading];
    }
}

#pragma mark - Setups
- (void)setupSubviews
{
    CGRect rootViewBounds = self.navigationController.view.bounds;
    UIWebView *webView = [[JMWebViewManager sharedInstance] webViewWithParentFrame:rootViewBounds];
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;
}

- (void)resetSubViews
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:nil baseURL:nil];
}

- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self resetSubViews];
    [self.view endEditing:YES];
    self.webView.delegate = nil;

    [super cancelResourceViewingAndExit:exit];
}

#pragma mark - Overriden methods

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableActions = [super availableActionForResource:resource];
    if (![self.resourceLookup isSavedReport]) {
        availableActions |= JMMenuActionsViewAction_Print;
    }
    return availableActions;
}

- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Print) {
        [self printResource];
    }
}

#pragma mark - Print API
- (void)printResource
{
    // override in child
}

- (void)printItem:(id)printingItem withName:(NSString *)itemName
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = itemName;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;

    UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
    printInteractionController.printInfo = printInfo;
    printInteractionController.showsPageRange = YES;
    printInteractionController.printingItem = printingItem;

    UIPrintInteractionCompletionHandler completionHandler = @weakself(^(UIPrintInteractionController *printController, BOOL completed, NSError *error)) {
            if(error){
                NSLog(@"FAILED! due to error in domain %@ with error code %zd", error.domain, error.code);
            }
        }@weakselfend;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([JMUtils isIphone]) {
            [printInteractionController presentAnimated:YES completionHandler:completionHandler];
        } else {
            printInteractionController.delegate = self;
            self.printNavController = [JMMainNavigationController new];
            self.printNavController.view.backgroundColor = [UIColor colorWithRedComponent:239.f greenComponent:239.f blueComponent:244.f];
            self.printNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.printNavController.preferredContentSize = CGSizeMake(320, 400);
            [printInteractionController presentFromBarButtonItem:self.printNavController.navigationItem.rightBarButtonItems.firstObject
                                                        animated:YES
                                               completionHandler:completionHandler];
        }
    });
}

#pragma mark - UIPrintInteractionControllerDelegate
- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return self.printNavController;
}

- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [self presentViewController:self.printNavController animated:YES completion:nil];
    UIViewController *printSettingsVC = self.printNavController.topViewController;
    printSettingsVC.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    [self.printNavController dismissViewControllerAnimated:YES completion:^{
        self.printNavController = nil;
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *serverHost = [NSURL URLWithString:self.restClient.serverProfile.serverUrl].host;
    NSString *requestHost = request.URL.host;
    BOOL isParentHost = [requestHost isEqualToString:serverHost];
    BOOL isLinkClicked = navigationType == UIWebViewNavigationTypeLinkClicked;

    if (!isParentHost && isLinkClicked) {
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            [[UIAlertView localizedAlertWithTitle:@"dialod.title.attention"
                                          message:@"resource.viewer.open.link"
                                       completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        if (alertView.cancelButtonIndex != buttonIndex) {
                                                            [[UIApplication sharedApplication] openURL:request.URL];
                                                        }
                                                    }
                                cancelButtonTitle:@"dialog.button.cancel"
                                otherButtonTitles:@"dialog.button.ok", nil] show];
        } else {
            [ALToastView toastInView:webView
                            withText:JMCustomLocalizedString(@"resource.viewer.can't.open.link", nil)];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startShowLoadingIndicators];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopShowLoadingIndicators];
    if (self.resourceRequest) {
        self.isResourceLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopShowLoadingIndicators];
    self.isResourceLoaded = NO;
}

@end
