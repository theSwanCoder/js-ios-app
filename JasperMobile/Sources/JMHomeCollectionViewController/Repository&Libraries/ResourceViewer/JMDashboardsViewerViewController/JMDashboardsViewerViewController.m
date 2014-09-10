//
//  JMDashboardsViewerViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/10/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDashboardsViewerViewController.h"

@interface JMDashboardsViewerViewController ()

@end

@implementation JMDashboardsViewerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)runReportExecution
{
    NSString *dashboardUrl = [NSString stringWithFormat:@"%@%@%@",
                              self.resourceClient.serverProfile.serverUrl,
                              @"/flow.html?_flowId=dashboardRuntimeFlow&viewAsDashboardFrame=true&dashboardResource=",
                              self.resourceLookup.uri];
    
    NSURL *url = [NSURL URLWithString:dashboardUrl];
    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.resourceClient.timeoutInterval];
}
@end
