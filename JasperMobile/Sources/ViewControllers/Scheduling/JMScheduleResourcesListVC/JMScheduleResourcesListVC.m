/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMScheduleResourcesListVC.h
//  TIBCO JasperMobile
//
#import "JMScheduleResourcesListVC.h"
#import "JMSchedulingListVC.h"


@interface JMScheduleResourcesListVC() <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <JSResourceLookup *> *resources;
@property (weak, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation JMScheduleResourcesListVC

#pragma mark - UIViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Choose Report";
    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

    [self setupRefreshControl];
    [self refresh];

    self.searchBar.tintColor = [[JMThemesManager sharedManager] barItemsColor];
    self.searchBar.placeholder = JMCustomLocalizedString(@"resources.search.placeholder", nil);
}

#pragma mark - Setup controls
- (void)setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
}

#pragma mark - Actions
- (void)refresh
{
    [self fetchResourcesWithQuery:nil completion:^(NSArray <JSResourceLookup *> *resources, NSError *error) {
        [self.refreshControl endRefreshing];

        self.resources = [@[] mutableCopy];
        [self.resources addObjectsFromArray:resources];
        [self.tableView reloadData];
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *currentString = searchBar.text;

    NSString *changedString;

    if (range.length == 1) {
        // remove symbol
        changedString = [currentString stringByReplacingCharactersInRange:range withString:@""];
    } else if (range.location == 0 && range.length == text.length) {
        // autocompleted text
        changedString = text;
    } else {
        // add symbol
        NSRange firstPartOfStringRange = NSMakeRange(0, range.location);
        NSString *firstPartOfString = [currentString substringWithRange:firstPartOfStringRange];

        NSRange lastPartOfStringRange = NSMakeRange(range.location, currentString.length - range.location);
        NSString *lastPartOfString = [currentString substringWithRange:lastPartOfStringRange];

        changedString = [NSString stringWithFormat:@"%@%@%@", firstPartOfString, text, lastPartOfString];
    }

    JMLog(@"changed string: %@", changedString);

    [self fetchResourcesWithQuery:changedString completion:^(NSArray <JSResourceLookup *> *resources, NSError *error) {
        self.resources = [@[] mutableCopy];
        [self.resources addObjectsFromArray:resources];
        [self.tableView reloadData];
    }];

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self refresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMScheduleResourceCell" forIndexPath:indexPath];
    JSResourceLookup *resourceLookup = self.resources[indexPath.row];
    cell.textLabel.text = resourceLookup.label;
    cell.detailTextLabel.text = resourceLookup.resourceDescription;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    JSResourceLookup *resourceLookup = self.resources[indexPath.row];
    JMSchedulingListVC *schedulingInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMSchedulingListVC"];
    schedulingInfoVC.resourceLookup = resourceLookup;

    [self.navigationController pushViewController:schedulingInfoVC animated:YES];
}

#pragma mark - Getting Resources
- (void)fetchResourcesWithQuery:(NSString *)query completion:(void(^)(NSArray <JSResourceLookup *> *resources, NSError *error))completion
{
    if (!completion) {
        return;
    }

    [self.restClient resourceLookups:nil
                               query:query
                               types:@[@"reportUnit"]
                              sortBy:@"label"
                          accessType:nil
                           recursive:YES
                              offset:0
                               limit:100
                     completionBlock:^(JSOperationResult *result) {
                         if (result.error) {
                             completion(nil, result.error);
                         } else {
                             NSArray <JSResourceLookup *> *resources = result.objects;
                             completion(resources, nil);
                         }
                     }];
}

@end