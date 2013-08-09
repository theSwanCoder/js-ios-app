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
#import "JMCancelRequestPopup.h"
#import "JMFilter.h"

@implementation JMRepositoryTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [JMFilter checkNetworkReachabilityForBlock:^{
        [JMCancelRequestPopup presentInViewController:self progressMessage:@"status.loading" restClient:self.resourceClient cancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.resourceClient resources:[self path] delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [super searchBarSearchButtonClicked:searchBar];
    
    [JMFilter checkNetworkReachabilityForBlock:^{
        [self.resourceClient resources:[self path] query:searchBar.text types:nil recursive:YES limit:0 delegate:[JMFilter checkRequestResultForDelegate:self]];
    } viewControllerToDismiss:self];
    
    searchBar.text = @"";
}

#pragma mark - Private

- (NSString *)path
{
    return self.resourceDescriptor.uriString ?: @"/";
}

@end
