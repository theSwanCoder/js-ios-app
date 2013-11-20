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
//  JMRepositoryTableViewController.m
//  Jaspersoft Corporation
//

#import "JMRepositoryTableViewController.h"
#import "JMRequestDelegate.h"
#import "JSRESTBase+updateServerInfo.h"

@interface JMRepositoryTableViewController()
- (NSString *)path:(NSString *)defaultPath;
- (void)reloadData;
@end

@implementation JMRepositoryTableViewController

- (void)getResources
{
    JMRequestDelegate *delegate = [JMRequestDelegate checkRequestResultForDelegate:self viewControllerToDismiss:self];
    if (self.isPaginationAvailable) {
        NSArray *types = @[self.constants.WS_TYPE_FOLDER, self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD];
        BOOL recursive = self.searchQuery.length != 0;
        [self.resourceClient resourceLookups:[self path:@"/"] query:self.searchQuery types:types recursive:recursive offset:self.offset limit:kJMResourcesLimit delegate:delegate];
    } else {
        // Check if search action was not performed
        // TODO: remove condition for searchQuery. Make 1 call instead two
        if (self.searchQuery.length > 0) {
            [self.resourceClient resources:[self path:@""] query:self.searchQuery types:nil recursive:YES limit:0 delegate:delegate];
        } else {
            [self.resourceClient resources:[self path:@"/"] delegate:delegate];
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.isNeedsToReloadData) {
        [self reloadData];
    }
}

#pragma mark - JMRefreshable

- (void)refresh
{
    [super refresh];
    [self reloadData];
}

#pragma mark - Private

- (void)reloadData
{
    JMRequestDelegate *serverInfoDelegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        [self getResources];
    }];
    
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:self.cancelBlock];
    // Update server info (if needed)
    [self.resourceClient updateServerInfo:serverInfoDelegate];
}

- (NSString *)path:(NSString *)defaultPath
{
    return self.resourceLookup.uri ?: defaultPath;
}

@end
