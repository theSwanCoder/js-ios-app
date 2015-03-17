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
#import "JMFavorites+Helpers.h"
#import "PopoverView.h"
#import "JMSavedResources+Helpers.h"
#import "JMResourceInfoViewController.h"
#import "ALToastView.h"
#import "JMUtils.h"
#import "JMWebViewManager.h"


NSString * const kJMShowReportOptionsSegue = @"ShowReportOptions";
NSString * const kJMShowMultiPageReportSegue = @"ShowMultiPageReport";
NSString * const kJMShowDashboardViewerSegue = @"ShowDashboardViewer";
NSString * const kJMShowSavedRecourcesViewerSegue = @"ShowSavedRecourcesViewer";


@interface JMResourceViewerViewController () <PopoverViewDelegate>
@property (nonatomic, strong) PopoverView *popoverView;
@end

@implementation JMResourceViewerViewController

@synthesize resourceLookup = _resourceLookup;

#pragma mark - LifeCycle
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView loadHTMLString:nil baseURL:nil];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.resourceRequest];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [self currentResourceLookup].label;
    
    [self setupWebView];
    
    [self runReportExecution];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = NSStringFromClass(self.class);
    
    [self setupNavigationItems];
    
    if (!self.isResourceLoaded && self.resourceRequest) {
        [self.webView loadRequest:self.resourceRequest];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.webView.loading) {
        [self stopShowLoadingIndicators];
        [self.webView stopLoading];
    }
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setResourceLookup:[self currentResourceLookup]];
}

#pragma mark - Custom Accessors
- (void)setResourceRequest:(NSURLRequest *)resourceRequest
{
    if (resourceRequest != _resourceRequest) {
        _resourceRequest = resourceRequest;
    }
}

- (JSResourceLookup *)currentResourceLookup
{
    return self.resourceLookup;
}

#pragma mark - Handle rotates
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    CGPoint point = CGPointMake(self.view.frame.size.width, -10);
    [self.popoverView animateRotationToNewPoint:point
                                         inView:self.view
                                   withDuration:duration];
}

#pragma mark - Setups
- (void)setupWebView
{
    UIWebView *webView = [JMWebViewManager sharedInstance].webView;
    CGRect rootViewBounds = self.navigationController.view.bounds;
    webView.frame = rootViewBounds;
    webView.delegate = self;
    [self.view insertSubview:webView belowSubview:self.activityIndicator];
    self.webView = webView;
    
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.suppressesIncrementalRendering = YES;
    [self.webView loadHTMLString:@"" baseURL:nil];
}

- (void)setupNavigationItems
{
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *actionBarButtonItem = [self actionBarButtonItem];
    if (actionBarButtonItem) {
        [items addObject:actionBarButtonItem];
    }
    
    UIBarButtonItem *favoriteBarButtonItem = [self favoriteBarButtonItem];
    if (favoriteBarButtonItem) {
        [items addObject:favoriteBarButtonItem];
    }
    self.navigationItem.rightBarButtonItems = [items copy];
}

#pragma mark - Actions
- (void)showAvailableActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self;
    actionsView.availableActions = [self availableActionForResource:[self currentResourceLookup]];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame), -10);
    
    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:[self currentResourceLookup]]) {
        [JMFavorites removeFromFavorites:[self currentResourceLookup]];
    } else {
        [JMFavorites addToFavorites:[self currentResourceLookup]];
    }
    if (sender) {
        [self replaceRightNavigationItem:sender withItem:[self favoriteBarButtonItem]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

-(void) runReportExecution
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:[NSString stringWithFormat:@"You need to implement \"%@\" method in \"%@\" class", NSStringFromSelector(_cmd), NSStringFromClass(self.class)] userInfo:nil];
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
            [[UIAlertView localizedAlertWithTitle:nil
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

#pragma mark - UIWebView helpers
- (void)startShowLoadingIndicators
{
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopShowLoadingIndicators
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_Info:
            [self showResourceInfoViewControllerWithResourceLookup:[self currentResourceLookup]];
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

#pragma mark - Helpers
- (void)showResourceInfoViewControllerWithResourceLookup:(JSResourceLookup *)resourceLookup
{
    JMResourceInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JMResourceInfoViewController"];
    vc.resourceLookup = resourceLookup;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIBarButtonItem *) actionBarButtonItem
{
    if ([self availableActionForResource:[self currentResourceLookup]]) {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                             target:self
                                                             action:@selector(showAvailableActions)];
    }
    return nil;
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    if (![JMUtils isIphone]) {
        BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:[self currentResourceLookup]];
        NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
        
        UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(favoriteButtonTapped:)];
        favoriteItem.tintColor = isResourceInFavorites ? [UIColor yellowColor] : [UIColor whiteColor];
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

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    JMMenuActionsViewAction availableAction = JMMenuActionsViewAction_Info;
    if (![self favoriteBarButtonItem]) {
        availableAction |= [JMFavorites isResourceInFavorites:resource] ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
    }
    return availableAction;
}

#pragma mark - Loader Popups
- (void)startShowLoaderWithMessage:(NSString *)message cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    [JMUtils showNetworkActivityIndicator];
    [JMCancelRequestPopup presentWithMessage:message
                                 cancelBlock:cancelBlock];
}

- (void)stopShowLoader
{
    [JMUtils hideNetworkActivityIndicator];
    [JMCancelRequestPopup dismiss];
}

@end
