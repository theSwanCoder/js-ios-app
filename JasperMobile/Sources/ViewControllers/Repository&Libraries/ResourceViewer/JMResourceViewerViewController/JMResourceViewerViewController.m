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


#import "JMResourceViewerViewController.h"
#import "JMWebViewManager.h"
#import "ALToastView.h"
#import "JSResourceLookup+Helpers.h"
#import "JMPrintResourceViewController.h"
#import "JMMainNavigationController.h"

@interface JMResourceViewerViewController () <UIPrintInteractionControllerDelegate>
@property (nonatomic, weak, readwrite) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UINavigationController *printNavController;
@property (nonatomic, assign) CGSize printSettingsPreferredContentSize;
@end

@implementation JMResourceViewerViewController

- (void)dealloc
{
    [[JMWebViewManager sharedInstance] reset];
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.printSettingsPreferredContentSize = CGSizeMake(540, 580);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.webView.loading) {
        [self stopShowLoadingIndicators];
        // old dashboards don't load empty page
        //[self.webView stopLoading];
    }
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = self.printNavController.view.superview.frame;
    frame.size = self.printSettingsPreferredContentSize;
    self.printNavController.view.superview.frame = frame;

    self.printNavController.preferredContentSize = self.printSettingsPreferredContentSize;

    [super viewWillLayoutSubviews];
}

#pragma mark - Setups
- (void)setupSubviews
{
    CGRect rootViewBounds = self.navigationController.view.bounds;
    UIWebView *webView = [[JMWebViewManager sharedInstance] webViewWithParentFrame:rootViewBounds];
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"webView": webView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                                                      options:NSLayoutFormatAlignAllLeading
                                                                      metrics:nil
                                                                        views:@{@"webView": webView}]];
}

- (void)resetSubViews
{
    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
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
    [self printItem:printingItem
           withName:itemName
         completion:nil];
}

- (void)printItem:(id)printingItem withName:(NSString *)itemName completion:(void(^)(BOOL completed, NSError *error))completion
{
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = itemName;
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;

    UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
    printInteractionController.printInfo = printInfo;
    printInteractionController.showsPageRange = YES;
    printInteractionController.printingItem = printingItem;

    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (completion) {
                completion(completed, error);
            }
        };

    if ([JMUtils isIphone]) {
        [printInteractionController presentAnimated:YES completionHandler:completionHandler];
    } else {
        if ([JMUtils isSystemVersion9]) {
            [printInteractionController presentFromBarButtonItem:self.printNavController.navigationItem.rightBarButtonItems.firstObject
                                                        animated:YES
                                               completionHandler:completionHandler];
        } else {
            printInteractionController.delegate = self;
            self.printNavController = [JMMainNavigationController new];
            self.printNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.printNavController.preferredContentSize = self.printSettingsPreferredContentSize;
            [printInteractionController presentFromBarButtonItem:self.printNavController.navigationItem.rightBarButtonItems.firstObject
                                                        animated:YES
                                               completionHandler:completionHandler];
        }
    }
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
    printSettingsVC.navigationItem.leftBarButtonItem.tintColor = [[JMThemesManager sharedManager] barItemsColor];
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
            UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.attention"
                                                                                              message:@"resource.viewer.open.link"
                                                                                    cancelButtonTitle:@"dialog.button.cancel"
                                                                              cancelCompletionHandler:nil];
            [alertController addActionWithLocalizedTitle:@"dialog.button.ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }];
            [self presentViewController:alertController animated:YES completion:nil];
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
