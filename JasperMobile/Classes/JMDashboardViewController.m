//
//  JMDashboardViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 8/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMDashboardViewController.h"
#import "JMFilter.h"
#import "JMRotationBase.h"

@implementation JMDashboardViewController
inject_default_rotation()

@synthesize resourceClient = _resourceClient;
@synthesize resourceDescriptor = _resourceDescriptor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [JMFilter checkNetworkReachabilityForBlock:^{
        NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@", self.resourceClient.serverProfile.serverUrl,
                                  @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                                  self.resourceDescriptor.uriString];
        
        [self.activityIndicator startAnimating];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashboardUrl]]];
    } viewControllerToDismiss:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

@end
