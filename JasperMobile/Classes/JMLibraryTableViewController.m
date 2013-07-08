//
//  JMLibraryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/5/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMLibraryTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMFilter.h"

#define kJMRequestType @"type"

@interface JMLibraryTableViewController()
@property (nonatomic, strong) NSString *query;

- (void)searchReportsByQuery:(NSString *)query includingDashboards:(BOOL)includingDashboards;
@end

@implementation JMLibraryTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self searchReportsByQuery:nil includingDashboards:YES];
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    id type = [result.request.params objectForKey:kJMRequestType];
    
    // Check if server supports dashboard type of resource (JasperServer CE version
    // doesn't have this type)
    if ([result isError] && [type isKindOfClass:[NSArray class]] &&
        [type containsObject:self.constants.WS_TYPE_DASHBOARD]) {
        [self searchReportsByQuery:self.query includingDashboards:NO];
    } else {
        [super requestFinished:result];
    }
    
    self.query = nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [super searchBarSearchButtonClicked:searchBar];
    
    self.query = searchBar.text;
    [self searchReportsByQuery:self.query includingDashboards:YES];
    
    searchBar.text = @"";
}

#pragma mark - Private

- (void)searchReportsByQuery:(NSString *)query includingDashboards:(BOOL)includingDashboards
{
    NSMutableArray *types = [NSMutableArray arrayWithObject:self.constants.WS_TYPE_REPORT_UNIT];
    if (includingDashboards) {
        [types addObject:self.constants.WS_TYPE_DASHBOARD];
    }
    
    [JMCancelRequestPopup presentInViewController:self progressMessage:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [JMFilter checkNetworkReachabilityForBlock:^{
        [self.resourceClient resources:@"/" query:self.query types:types recursive:YES limit:0 delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:nil];
}

@end
