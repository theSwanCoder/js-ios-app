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
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMLibraryTableViewController.h"
#import "JMUtils.h"

static NSInteger const kJMLoadingCellTag = 100;
static NSString * const kJMShowSearchFilterSegue = @"ShowSearchFilter";

@interface JMSearchableTableViewController ()
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, readwrite) JMCancelRequestBlock cancelBlock;

- (CGPoint)defaultContentOffset;
- (void)resetSearchState;
@end

@implementation JMSearchableTableViewController

@synthesize resourceTypes = _resourceTypes;
@synthesize isRefreshing = _isRefreshing;
@synthesize isNeedsToReloadData = _isNeedsToReloadData;

- (BOOL)isNeedsToReloadData
{
    return !self.isRefreshing && _isNeedsToReloadData;
}

- (void)changeServerProfile
{
    [super changeServerProfile];
    [self resetSearchState];
    self.isRefreshing = NO;
    self.resourceTypes = nil;
}

- (void)getResources
{
    @throw [NSException exceptionWithName:@"Method implementation is missing" reason:@"You need to implement \"getResources\" method in subclasses" userInfo:nil];
}

- (NSMutableSet *)resourceTypes
{
    if (!_resourceTypes) {
        _resourceTypes = [NSMutableSet setWithObjects:self.constants.WS_TYPE_REPORT_UNIT, self.constants.WS_TYPE_DASHBOARD, nil];
    }
    
    return _resourceTypes;
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.offset = 0;
        self.totalCount = 0;
        self.cancelBlock = nil;
        
        if (!self.searchBar.text.length) {
            self.contentOffset = [self defaultContentOffset];
        }
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Accessors

- (JMCancelRequestBlock)cancelBlock
{
    if (!_cancelBlock) {
        __weak JMSearchableTableViewController *search = self;
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
    
    if (!self.isSearchDisabled) {
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
        [self.searchBar sizeToFit];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        self.contentOffset = [self defaultContentOffset];
        self.tableView.tableHeaderView = self.searchBar;
    } else if (!self.isPaginationAvailable) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!self.isSearchDisabled) {
        self.tableView.contentOffset = self.contentOffset;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowSearchFilterSegue]) {
        id destinationViewController = segue.destinationViewController;
        [destinationViewController setDelegate:self];
        [destinationViewController setResourceTypes:self.resourceTypes];
    }

    [super prepareForSegue:segue sender:sender];
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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:JMMainStoryboard() bundle:nil];
        id destinationViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(JMLibraryTableViewController.class)];
        
        if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
            [destinationViewController setResourceClient:self.resourceClient];
            [destinationViewController setResourceLookup:self.resourceLookup];
            [destinationViewController setIsSearchDisabled:YES];
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
    [JMUtils hideNetworkActivityIndicator];

    if (self.isPaginationAvailable && !self.totalCount) {
        self.totalCount = [[result.allHeaderFields objectForKey:@"Total-Count"] integerValue];
        if (self.totalCount) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    
    [super requestFinished:result];
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

#pragma mark - Pagination Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [super tableView:tableView numberOfRowsInSection:section];
    if (self.isPaginationAvailable && numberOfRows != 0 && self.offset + kJMResourcesLimit < self.totalCount) {
        numberOfRows++;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.resources.count) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *) [cell viewWithTag:1];
        [activityIndicator startAnimating];
        cell.tag = kJMLoadingCellTag;
        return cell;
    }

    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kJMLoadingCellTag) {
        self.offset += kJMResourcesLimit;
        [self getResources];
    }
}

#pragma mark - Private

- (CGPoint)defaultContentOffset
{
    if ([JMUtils isFoundationNumber7OrHigher]) {
        return CGPointMake(0, -20.0f);
    } else {
        return CGPointMake(0, self.searchBar.frame.size.height);
    }
}

- (void)resetSearchState
{
    if (self.searchBar) {
        self.searchBar.text = nil;
    }
    self.offset = 0;
    self.totalCount = 0;
    self.contentOffset = [self defaultContentOffset];
}

@end
