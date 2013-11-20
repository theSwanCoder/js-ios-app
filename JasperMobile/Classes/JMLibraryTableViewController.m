/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
#import "JMRequestDelegate.h"
#import "JSRESTBase+updateServerInfo.h"

static NSString * const kJMRequestType = @"type";

@interface JMLibraryTableViewController()
@property (nonatomic, assign) BOOL includeDashboards;
- (void)reloadData;
@end

@implementation JMLibraryTableViewController

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.includeDashboards = YES;
    
    // Check if resources are needs to be reloaded
    if (self.isNeedsToReloadData) {
        [self reloadData];
    }
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    id type = [result.request.params objectForKey:kJMRequestType];

    // Check if server supports dashboard type of resource (JasperServer CE version
    // doesn't have this type)
    if ([result isError] && [type isKindOfClass:[NSArray class]] &&
        [type containsObject:self.constants.WS_TYPE_DASHBOARD]) {
        
        self.includeDashboards = YES;
        [self reloadData];
    } else {
        [super requestFinished:result];
    }
}

#pragma mark - JMRefreshable

- (void)refresh
{
    [super refresh];
    [self reloadData];
}

#pragma mark - Private

- (void)getResources
{
    NSMutableArray *types = [NSMutableArray arrayWithObject:self.constants.WS_TYPE_REPORT_UNIT];
    if (self.includeDashboards) {
        [types addObject:self.constants.WS_TYPE_DASHBOARD];
    }
    
    JMRequestDelegate *delegate = [JMRequestDelegate checkRequestResultForDelegate:self viewControllerToDismiss:self];
    if (self.isPaginationAvailable) {
        [self.resourceClient resourceLookups:nil query:self.searchQuery types:types recursive:YES offset:self.offset limit:kJMResourcesLimit delegate:delegate];
    } else {
        [self.resourceClient resources:nil query:self.searchQuery types:types recursive:YES limit:0 delegate:delegate];
    }
}

- (void)reloadData
{
    JMRequestDelegate *serverInfoDelegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [self getResources];
    }];
    
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:self.cancelBlock];
    // Update server info (if needed)
    [self.resourceClient updateServerInfo:serverInfoDelegate];
}

@end
