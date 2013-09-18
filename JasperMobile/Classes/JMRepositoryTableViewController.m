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

@interface JMRepositoryTableViewController()
- (NSString *)path:(NSString *)defaultPath;
- (void)reloadData;
@end

@implementation JMRepositoryTableViewController

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Check if resources are already updated
    if ([self isNeedsToReloadData]) {
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
    [JMCancelRequestPopup presentInViewController:self message:@"status.loading" restClient:self.resourceClient cancelBlock:self.cancelBlock];

    // Check if search action was not performed
    if (self.searchQuery.length > 0) {
        [self.resourceClient resources:[self path:@""] query:self.searchQuery types:nil recursive:YES limit:0 delegate:[JMRequestDelegate checkRequestResultForDelegate:self viewControllerToDismiss:self]];
    } else {
        [self.resourceClient resources:[self path:@"/"] delegate:[JMRequestDelegate checkRequestResultForDelegate:self viewControllerToDismiss:self]];
    }
}

- (NSString *)path:(NSString *)defaultPath
{
    return self.resourceDescriptor.uriString ?: defaultPath;
}

@end
