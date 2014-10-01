//
//  JMResourceViewerViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceViewerViewController.h"
#import "JMFavorites+Helpers.h"
#import "PopoverView.h"
#import "JMSavedResources+Helpers.h"

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
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isRequestLoaded && self.request) {
        [self.webView loadRequest:self.request];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.webView.loading) {
        [self.webView stopLoading];
        [self loadingDidFinished];
    }
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
        self.webView.delegate = nil;
        [self.webView removeFromSuperview];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
    }
}

- (void)setRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        }
        [self.webView loadRequest:request];
        self.isRequestLoaded = NO;
    }
}

- (UIBarButtonItem *) actionBarButtonItem
{
    if ([self availableAction]) {
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return nil;
}

- (BOOL) favoriteFeatureIsAvailableForCurrentResource
{
    return ![self isKindOfClass:NSClassFromString(@"JMSavedResourceViewerViewController")];
}

- (UIBarButtonItem *) favoriteBarButtonItem
{
    if ([self favoriteFeatureIsAvailableForCurrentResource] & ![JMUtils isIphone]) {
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
    JMResourceViewerActionsView *actionsView = [[JMResourceViewerActionsView alloc] initWithFrame:CGRectMake(0, 0, 240, 200)];
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
    [self replaceRightNavigationItem:sender withItem:[self favoriteBarButtonItem]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

- (JMResourceViewerAction)availableAction
{
    if ([self favoriteFeatureIsAvailableForCurrentResource] && ![self favoriteBarButtonItem]) {
        return [JMFavorites isResourceInFavorites:self.resourceLookup] ? JMResourceViewerAction_MakeUnFavorite : JMResourceViewerAction_MakeFavorite;
    }
    return JMResourceViewerAction_None;
}

-(void) runReportExecution
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"runReportExecution\" method in subclasses" userInfo:nil];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    [JMUtils showNetworkActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadingDidFinished];
    if (self.request) {
        self.isRequestLoaded = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadingDidFinished];
    self.isRequestLoaded = NO;
}

- (void)loadingDidFinished
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - JMResourceViewerActionsViewDelegate
- (void)actionsView:(JMResourceViewerActionsView *)view didSelectAction:(JMResourceViewerAction)action
{
    if (action == JMResourceViewerAction_MakeFavorite) {
        [JMFavorites addToFavorites:self.resourceLookup];
    } else if (action == JMResourceViewerAction_MakeUnFavorite) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
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
