/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportOptionsViewController.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"

@interface JMReportOptionsViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel     *noResultLabel;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *filteredListOfValues;

@end

@implementation JMReportOptionsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = JMLocalizedString(@"report_viewer_report_options_title");
    self.noResultLabel.text = JMLocalizedString(@"resources_noresults_msg");
    
    self.noResultLabel.textColor = [[JMThemesManager sharedManager] reportOptionsNoResultLabelTextColor];
    
    self.tableView.layer.cornerRadius = 4;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = self.tableView.backgroundColor;
    [txfSearchField setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    self.searchBar.barTintColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    self.searchBar.tintColor = [UIColor darkGrayColor];
    [self.searchBar setBackgroundImage:[UIImage new]];
    self.searchBar.placeholder = JMLocalizedString(@"report_viewer_options_search_value_placeholder");
}

#pragma mark - Accessors
- (NSArray *)listOfValues
{
    return self.filteredListOfValues ? self.filteredListOfValues : _listOfValues;
}

- (void)setSelectedReportOption:(JSReportOption *)selectedReportOption
{
    if (_selectedReportOption != selectedReportOption && [self.listOfValues indexOfObject:selectedReportOption] != NSNotFound) {
        _selectedReportOption = selectedReportOption;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.listOfValues indexOfObject:_selectedReportOption] inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ReportOptionsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    }
    
    JSReportOption *reportOption = self.listOfValues[indexPath.row];
    cell.textLabel.text = reportOption.label;
    cell.accessoryType = (reportOption == self.selectedReportOption) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedReportOption = self.listOfValues[indexPath.row];
    [self.delegate reportOptionsViewController:self didSelectOption:self.selectedReportOption];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", searchBar.text]];
        self.filteredListOfValues = [self.listOfValues filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredListOfValues = nil;
    }
    self.noResultLabel.hidden = ([self.listOfValues count] > 0);
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = nil;
    [self searchBar:searchBar textDidChange:searchBar.text];
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

@end

