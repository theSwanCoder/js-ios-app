//
//  JMResourceViewerViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMResourceViewerViewController.h"
#import <Objection-iOS/Objection.h>
#import "JMFavorites+Helpers.h"

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
    
    self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
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
    [super viewWillDisappear:animated];
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

- (NSArray *)rightBarButtonItems
{
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonTapped:)];
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoriteButtonTapped:)];
    [self updateFavotiteItem:favoriteItem];
    return [NSArray arrayWithObjects:refreshItem, favoriteItem, nil];
}

#pragma mark - Actions
- (void)refreshButtonTapped:(id) sender
{
    [self runReportExecution];
}

- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resourceLookup]) {
        [JMFavorites removeFromFavorites:self.resourceLookup];
    } else {
        [JMFavorites addToFavorites:self.resourceLookup];
    }
    [self updateFavotiteItem:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMFavoritesDidChangedNotification object:nil];
}

- (void) updateFavotiteItem:(UIBarButtonItem *)item
{
    item.tintColor = [JMFavorites isResourceInFavorites:self.resourceLookup] ? [UIColor yellowColor] : [UIColor whiteColor];
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
@end
