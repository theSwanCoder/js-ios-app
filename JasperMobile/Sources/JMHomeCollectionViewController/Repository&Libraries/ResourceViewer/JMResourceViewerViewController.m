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


#import <SplunkMint-iOS/SplunkMint-iOS.h>
#import "JMResourceViewerViewController.h"
#import "JMFavorites+Helpers.h"
#import "PopoverView.h"
#import "JMSavedResources+Helpers.h"
#import "JMResourceInfoViewController.h"
#import "ALToastView.h"
#import "UIAlertView+Additions.h"

@interface JMResourceViewerViewController () <PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;

@end

@implementation JMResourceViewerViewController
objection_requires(@"resourceClient", @"resourceLookup")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resourceLookup.label;
    
    self.webView.scrollView.bounces = NO;
    self.webView.suppressesIncrementalRendering = YES;
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[self actionBarButtonItem], [self favoriteBarButtonItem], nil];
    [self runReportExecution];

    // log events
    NSString *currentClassName = NSStringFromClass(self.class);
    [[Mint sharedInstance] logEventAsyncWithTag:currentClassName completionBlock:^(MintLogResult *splunkLogResult)
    {
        NSString *logResultState = splunkLogResult.resultState == OKResultState ? @"OK" : @"Error";
        NSLog(@"Log result: %@", logResultState);
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isResourceLoaded && self.resourceRequest) {
        [self.webView loadRequest:self.resourceRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.webView.loading) {
        [self.webView stopLoading];
        [self loadingDidFinished];
    }
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        self.webView.delegate = nil;
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:@"document.body.innerHTML='';" afterDelay:0.25];
        [self.webView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.resourceRequest];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setResourceLookup:self.resourceLookup];
}

- (void)setResourceRequest:(NSURLRequest *)resourceRequest
{
    if (resourceRequest != _resourceRequest) {
        _resourceRequest = resourceRequest;
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        self.isResourceLoaded = NO;
        [self.webView loadRequest:resourceRequest];
    }
}

- (UIBarButtonItem *) actionBarButtonItem
{
    if ([self availableAction]) {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return nil;
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    if (![JMUtils isIphone]) {
        UIImage *itemImage = [JMFavorites isResourceInFavorites:self.resourceLookup] ? [UIImage imageNamed:@"favorited_item"] : [UIImage imageNamed:@"make_favorite_item"];
        UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonTapped:)];
        favoriteItem.tintColor = [JMFavorites isResourceInFavorites:self.resourceLookup] ? [UIColor yellowColor] : [UIColor whiteColor];
        return favoriteItem;
    }
    return nil;
}

- (void) replaceRightNavigationItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)newItem
{
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    NSInteger index = [rightItems indexOfObject:oldItem];
    [rightItems replaceObjectAtIndex:index withObject:newItem];
    self.navigationItem.rightBarButtonItems = rightItems;
}

#pragma mark - Actions
- (void)actionButtonClicked:(id) sender
{
    JMMenuActionsView *actionsView = [[JMMenuActionsView alloc] initWithFrame:CGRectMake(0, 0, 240, 200)];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableAction];
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    self.popoverView = [PopoverView showPopoverAtPoint:point inView:self.view withTitle:nil withContentView:actionsView delegate:self];
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resourceLookup]) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
    } else {
        [JMFavorites addToFavorites:self.resourceLookup];
    }
    if (sender) {
        [self replaceRightNavigationItem:sender withItem:[self favoriteBarButtonItem]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (![self favoriteBarButtonItem]) {
        availableAction |= [JMFavorites isResourceInFavorites:self.resourceLookup] ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
    }
    return availableAction;
}

-(void) runReportExecution
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:[NSString stringWithFormat:@"You need to implement \"%@\" method in \"%@\" class", NSStringFromSelector(_cmd), NSStringFromClass(self.class)] userInfo:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *serverHost = [NSURL URLWithString:self.resourceClient.serverProfile.serverUrl].host;
    if (![request.URL.host isEqualToString:serverHost] && navigationType == UIWebViewNavigationTypeLinkClicked) {
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
    [self.activityIndicator startAnimating];
    [JMUtils showNetworkActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadingDidFinished];
    if (self.resourceRequest) {
        self.isResourceLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadingDidFinished];
    self.isResourceLoaded = NO;
}

- (void)loadingDidFinished
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_Info:
            [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:nil];
            break;
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            [self favoriteButtonTapped:nil];
            break;
        default:
            break;
    }

    [self.popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.2f];
}

#pragma mark - PopoverViewDelegate Methods
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point inView:self.view withDuration:duration];
}
@end
