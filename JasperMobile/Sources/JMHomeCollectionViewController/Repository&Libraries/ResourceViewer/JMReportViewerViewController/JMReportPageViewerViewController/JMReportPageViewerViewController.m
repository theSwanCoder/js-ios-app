//
//  JMReportPageViewerViewController.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportPageViewerViewController.h"

@interface JMReportPageViewerViewController() <UIWebViewDelegate>
@property (nonatomic, assign, getter=isStartLoad) BOOL startLoad;
@end

@implementation JMReportPageViewerViewController

#pragma mark - Lifecycle
-(void)dealloc
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"page: %@", @(self.pageIndex));
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isStartLoad) {
        [self startShowLoadProgress];
    }
}

#pragma mark - Public API
- (void)startLoadReportPageContentWithLoader:(JMReportLoader *)reportLoader
{
    if (!self.webView.isLoading) {
        self.startLoad = YES;
        [reportLoader startLoadPage:(self.pageIndex+1) withCompletion:@weakself(^(NSString *HTMLString, NSString *baseURL)) {
            self.startLoad = NO;
            [self.webView loadHTMLString:HTMLString
                                 baseURL:[NSURL URLWithString:baseURL]];
        }@weakselfend];
    }
}

- (void)startShowLoadProgress
{
    [JMUtils showNetworkActivityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopShowLoadProgress
{
    [JMUtils hideNetworkActivityIndicator];
    [self.activityIndicator stopAnimating];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // TODO: start load indicator?
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopShowLoadProgress];
}

@end
