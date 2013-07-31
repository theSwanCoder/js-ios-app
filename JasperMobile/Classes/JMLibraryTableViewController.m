/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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

//
//  JMLibraryTableViewController.m
//  Jaspersoft Corporation
//

#import "JMLibraryTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMFilter.h"

static NSString * const kJMRequestType = @"type";

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
