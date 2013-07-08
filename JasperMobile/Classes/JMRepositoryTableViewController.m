//
//  JMRepositoryTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/5/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMRepositoryTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMFilter.h"

@implementation JMRepositoryTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [JMCancelRequestPopup presentInViewController:self progressMessage:@"status.loading" restClient:self.resourceClient cancelBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [JMFilter checkNetworkReachabilityForBlock:^{
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
