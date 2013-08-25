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

#import "JMSearchableTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMResourceClientHolder.h"

@interface JMSearchableTableViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) CGPoint contentOffset;

- (CGPoint)defaultContentOffset;
- (void)resetSearchState;
@end

@implementation JMSearchableTableViewController

@synthesize isRefreshing = _isRefreshing;

- (BOOL)isNeedsToReloadData
{
    return !self.isRefreshing && ([super isNeedsToReloadData] || self.searchQuery.length);
}

- (void)changeServerProfile
{
    [super changeServerProfile];
    [self resetSearchState];
}

#pragma mark - Accessors

@synthesize cancelBlock = _cancelBlock;

- (JMCancelRequestBlock)cancelBlock
{
    if (!_cancelBlock) {
        __block JMSearchableTableViewController *search = self;
        _cancelBlock = ^{
            search.searchQuery = nil;
            search.isRefreshing = NO;
            
            UINavigationController *navigationController = [search navigationController];
            UIViewController *topController = [navigationController.viewControllers objectAtIndex:0];
            
            if (topController == search) {
                NSDictionary *userInfo = @{
                    kJMMenuTag : @kJMServersMenuTag
                };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kJMSelectMenuNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            } else {
                [[search navigationController] popViewControllerAnimated:YES];
            }
        };
    }
    
    return _cancelBlock;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.isScrollDisabled) {
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
        [self.searchBar sizeToFit];
        self.contentOffset = [self defaultContentOffset];
        self.tableView.tableHeaderView = self.searchBar;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.contentOffset = self.contentOffset;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
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
    }
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    self.isRefreshing = NO;
    self.searchQuery = nil;
    [super requestFinished:result];
}

#pragma mark - JMResourceTableViewControllerDelegate

- (void)refreshWithResource:(JSResourceDescriptor *)resourceDescriptor
{
    [super refreshWithResource:resourceDescriptor];
    self.tableView.contentOffset = self.contentOffset;
}

#pragma mark - JMRefreshable

- (void)refresh
{
    self.isRefreshing = YES;
    // Clear table content
    self.resources = nil;
    [self resetSearchState];
    [self.tableView reloadData];
}

#pragma mark - Private

- (CGPoint)defaultContentOffset
{
    return CGPointMake(0, self.searchBar.frame.size.height);
}

- (void)resetSearchState
{
    self.searchBar.text = nil;
    self.searchQuery = nil;
    self.contentOffset = [self defaultContentOffset];
}

@end
