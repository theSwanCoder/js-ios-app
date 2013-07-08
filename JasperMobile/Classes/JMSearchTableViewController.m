//
//  JMSearchTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/8/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMSearchTableViewController.h"
#import "JMLocalization.h"
#import "JMCancelRequestPopup.h"

@interface JMSearchTableViewController ()
- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated;
@end

@implementation JMSearchTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    
    // TODO: change to proper message
    searchBar.placeholder = JMCustomLocalizedString(@"Search resources", nil);
    [searchBar sizeToFit];
    
    self.tableView.tableHeaderView = searchBar;
    [self hideSearchBar:searchBar animated:NO];
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

#pragma mark - Private

- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, searchBar.frame.size.height) animated:animated];
}

@end
