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
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMResourceClientHolder.h"

@interface JMSearchTableViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL shouldMoveToContentOffset;
@property (nonatomic, assign) CGPoint contentOffset;

- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated;
@end

@implementation JMSearchTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.isScrollDisabled) {
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
        [self.searchBar sizeToFit];
        
        self.contentOffset = CGPointMake(0, self.searchBar.frame.size.height);
    
        self.tableView.tableHeaderView = self.searchBar;
        [self hideSearchBar:self.searchBar animated:NO];
    }
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
    if (self.navigationController) {
        [searchBar resignFirstResponder];
        
        // TODO: consult about hiding search bar
//        [self hideSearchBar:searchBar animated:NO];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:JMMainStoryboard() bundle:nil];
        id destinationViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self.class)];
        
        if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
            [destinationViewController setResourceClient:self.resourceClient];
            [destinationViewController setResourceDescriptor:self.resourceDescriptor];
            [destinationViewController setIsScrollDisabled:YES];
        }
        
        [destinationViewController setSearchQuery:searchBar.text];
        
        [self.navigationController pushViewController:destinationViewController animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDecelerating || scrollView.isDragging) {
        self.contentOffset = scrollView.contentOffset;
    } else {
        [self.tableView setContentOffset:self.contentOffset];
    }
}

#pragma mark - JMResourceViewControllerDelegate

- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor
{
    [super refreshWithResource:resourceDescriptor];
    [self hideSearchBar:self.searchBar animated:NO];
}

#pragma mark - Private

// TODO: remove if hiding 
- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, searchBar.frame.size.height) animated:animated];
}

@end