//
//  JMReportSearchVC.m
//  TIBCO JasperMobile
//
//  Created by Alexey Gubarev on 8/8/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportSearchVC.h"
#import "JMReportSearchTableViewCell.h"
#import "JMThemesManager.h"
#import "JMLocalization.h"
#import "JMJavascriptRequest.h"
#import "JMCancelRequestPopup.h"
#import "JMUtils.h"
#import "JSReportSearch.h"
#import "EKMapper.h"
#import "NSObject+Additions.h"


@interface JMReportSearchVC() <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UILabel *noResultLabel;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation JMReportSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = JMCustomLocalizedString(@"report_viewer_report_search", nil);
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = self.tableView.backgroundColor;
    [txfSearchField setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    self.searchBar.barTintColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    self.searchBar.tintColor = [UIColor darkGrayColor];
    [self.searchBar setBackgroundImage:[UIImage new]];
    self.searchBar.placeholder = JMCustomLocalizedString(@"report_viewer_report_search_value_placeholder", nil);
    self.searchBar.text = self.currentSearch.searchText;
    
    self.tableView.layer.cornerRadius = 4;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.noResultLabel.text = JMCustomLocalizedString(@"resources_noresults_msg", nil);

    [self refreshUI];
    if (self.currentSearch.selectedResult) {
        NSInteger indexOfSelectedRow = [self.currentSearch.searchResults indexOfObject:self.currentSearch.selectedResult];
        if (indexOfSelectedRow != NSNotFound) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexOfSelectedRow inSection:0];
            [self.tableView selectRowAtIndexPath:cellIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        } else {
            self.currentSearch.selectedResult = nil;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentSearch.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"JMReportSearchTableViewCell";

    JMReportSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[JMReportSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    }
    JSReportSearchResult *currentResult = self.currentSearch.searchResults[indexPath.row];

    cell.searchResult = currentResult;
//    cell.highlighted = self.currentSearch.selectedResult == currentResult;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSReportSearchResult *selectedResult = self.currentSearch.searchResults[indexPath.row];
    if(selectedResult != self.currentSearch.selectedResult){
        self.currentSearch.selectedResult = selectedResult;
        self.exitBlock(self.currentSearch);
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self applySearchWithText:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

#pragma mark - Private
- (void)applySearchWithText:(NSString *)searchString
{
    if (![searchString isEqualToString:self.currentSearch.searchText]) {
        [JMUtils showNetworkActivityIndicator];
        [JMCancelRequestPopup presentWithMessage:@"status_loading"
                                     cancelBlock:^{
//                                         [self cancelAction];
                                     }];
        
        JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"API.searchText"
                                                                   inNamespace:JMJavascriptNamespaceVISReport
                                                                    parameters:@{
                                                                                 @"text" : searchString
                                                                                 }];

        __weak typeof(self) weakSelf = self;
        [self.webEnvironment sendJavascriptRequest:request completion:^(NSDictionary * _Nullable params, NSError * _Nullable error) {
            [JMCancelRequestPopup dismiss];
            if (!error) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.currentSearch.searchText = searchString;
                strongSelf.currentSearch.searchResults = [strongSelf mapSearchResultsFromParams:params[@"data"]];
                [strongSelf refreshUI];
            } else {
                [JMUtils presentAlertControllerWithError:error completion:nil];
            }
        }];
    }
}

- (NSArray *)mapSearchResultsFromParams:(NSArray *__nonnull)params
{
    NSAssert(params != nil, @"parameters is nil");
    NSAssert([params isKindOfClass:[NSArray class]], @"Parameters should be NSArray class");
    
    NSMutableArray *searchResults = [NSMutableArray new];
    
    for (NSDictionary *resultData in params) {
        EKObjectMapping *objectMapping = [JSReportSearchResult objectMappingForServerProfile:self.restClient.serverProfile];
        JSReportSearchResult *searchResult = [EKMapper objectFromExternalRepresentation:resultData withMapping:objectMapping];
        [searchResults addObject:searchResult];
    }
    
    return searchResults;
}

- (void)refreshUI
{
    self.noResultLabel.hidden = ([self.currentSearch.searchResults count] > 0);
    [self.tableView reloadData];
}

- (JSReportSearch *)currentSearch
{
    if (!_currentSearch) {
        _currentSearch = [JSReportSearch new];
    }
    return _currentSearch;
}

@end
