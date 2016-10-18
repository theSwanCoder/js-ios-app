/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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


#import "JMSingleSelectTableViewController.h"
#import "JMSingleSelectInputControlCell.h"

@interface JMSingleSelectTableViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UILabel     *noResultLabel;
@property (nonatomic, weak) IBOutlet UISearchBar *icSearchBar;

@property (nonatomic, strong) NSArray *filteredListOfValues;

@property (nonatomic, strong) NSMutableSet *previousSelectedValues;

@end

@implementation JMSingleSelectTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.cell.inputControlDescriptor.label;
    self.titleLabel.text = JMLocalizedString(@"report_viewer_options_singleselect_titlelabel_title");
    self.noResultLabel.text = JMLocalizedString(@"resources_noresults_msg");

    self.titleLabel.textColor = [[JMThemesManager sharedManager] reportOptionsTitleLabelTextColor];
    self.noResultLabel.textColor = [[JMThemesManager sharedManager] reportOptionsNoResultLabelTextColor];
    
    self.tableView.layer.cornerRadius = 4;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    UITextField *txfSearchField = [self.icSearchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = self.tableView.backgroundColor;
    [txfSearchField setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor]}];
    self.icSearchBar.barTintColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    
    self.icSearchBar.tintColor = [UIColor darkGrayColor];
    [self.icSearchBar setBackgroundImage:[UIImage new]];
    self.icSearchBar.placeholder = JMLocalizedString(@"report_viewer_options_search_value_placeholder");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    JMLog(@"\nPrevious Selection :%@\nNew Selection: %@", self.previousSelectedValues, self.selectedValues);
    
TODO: // Should reimplement this logic - it does not correct update cell!!!
    
    if (![self.previousSelectedValues isEqualToSet:[NSSet setWithArray:self.selectedValues]]) {
        [self.cell updateWithParameters:self.selectedValues];
    }
}

#pragma mark - Accessors

- (NSArray *)selectedValues
{
    return [self.listOfValues filteredArrayUsingPredicate:[self selectedValuesPredicate]];
}

- (NSArray *)listOfValues
{
    return self.filteredListOfValues ? self.filteredListOfValues : self.cell.inputControlDescriptor.state.options;
}

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;
    self.previousSelectedValues = [NSMutableSet setWithArray:self.selectedValues];

    if ([self.previousSelectedValues count] == 1) {
        NSInteger indexOfSelectedRow = [self.cell.inputControlDescriptor.state.options indexOfObject:[self.previousSelectedValues anyObject]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfSelectedRow inSection:0];
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
    static NSString *cellIdentifier = @"ListCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
        cell.textLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    }
    
    JSInputControlOption *option = self.listOfValues[indexPath.row];
    cell.textLabel.text = option.label;
    cell.accessoryType = option.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *selectedOption = self.listOfValues[indexPath.row];
    JSInputControlOption *previousSelectedOption = [self.previousSelectedValues anyObject];

    if (previousSelectedOption != selectedOption) {
        selectedOption.selected = YES;
        previousSelectedOption.selected = NO;
    }

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UISearchBarDelegate
- (NSPredicate *)selectedValuesPredicate
{
    return [NSPredicate predicateWithFormat:@"SELF.selected == YES"];
}
    
- (NSPredicate *)filteredPredicateWithText:(NSString *)text
{
    if (text.length) {
        return [NSPredicate predicateWithFormat:@"SELF.label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", text]];
    }
    return nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self applyFiltering];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = nil;
    [self searchBar:searchBar textDidChange:@""];
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

- (void) applyFiltering
{
    NSPredicate *predicate = [self filteredPredicateWithText:self.icSearchBar.text];
    if (predicate) {
        self.filteredListOfValues = [self.cell.inputControlDescriptor.state.options filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredListOfValues = nil;
    }
    
    self.noResultLabel.hidden = ([self.listOfValues count] > 0);
    
    [self.tableView reloadData];
}
@end
