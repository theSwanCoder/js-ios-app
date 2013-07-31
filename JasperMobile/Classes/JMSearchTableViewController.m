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
//  JMSearchTableViewController.m
//  Jaspersoft Corporation
//

#import "JMSearchTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMLocalization.h"

@interface JMSearchTableViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;

- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated;
@end

@implementation JMSearchTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    // TODO: change to proper message
    self.searchBar.placeholder = JMCustomLocalizedString(@"Search resources", nil);
    [self.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchBar;
    [self hideSearchBar:self.searchBar animated:NO];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self hideSearchBar:searchBar animated:YES];

    [JMCancelRequestPopup presentInViewController:self
                                  progressMessage:@"status.searching"
                                       restClient:self.resourceClient
                                      cancelBlock:nil];
}

#pragma mark - JMResourceViewControllerDelegate

- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor
{
    [super refreshWithResource:resourceDescriptor];
    [self hideSearchBar:self.searchBar animated:NO];
}

#pragma mark - Private

- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, searchBar.frame.size.height) animated:animated];
}

@end
