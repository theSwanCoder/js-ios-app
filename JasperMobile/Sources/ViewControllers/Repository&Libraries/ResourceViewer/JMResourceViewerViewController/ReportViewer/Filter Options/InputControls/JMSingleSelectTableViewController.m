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
    self.titleLabel.text = JMCustomLocalizedString(@"report.viewer.options.singleselect.titlelabel.title", nil);
    self.noResultLabel.text = JMCustomLocalizedString(@"resources.noresults.msg", nil);

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
    self.icSearchBar.placeholder = JMCustomLocalizedString(@"report.viewer.options.search.value.placeholder", nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self.previousSelectedValues isEqualToSet:self.selectedValues]) {
        [self.cell updateWithParameters:[self.selectedValues allObjects]];
    }
}

#pragma mark - Accessors

- (NSMutableSet *)selectedValues
{
    if (!_selectedValues) {
        _selectedValues = [NSMutableSet set];
    }
    
    return _selectedValues;
}

- (NSArray *)listOfValues
{
    return self.filteredListOfValues ? self.filteredListOfValues : self.cell.inputControlDescriptor.state.options;
}

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;
    
    for (JSInputControlOption *option in cell.inputControlDescriptor.state.options) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
        }
    }
    
    if ([self.selectedValues count] == 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cell.inputControlDescriptor.state.options indexOfObject:[self.selectedValues anyObject]] inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
    }
    self.previousSelectedValues = [self.selectedValues mutableCopy];
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
    cell.accessoryType = option.selected.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *selectedOption = self.listOfValues[indexPath.row];
    JSInputControlOption *previousSelectedOption = [self.selectedValues anyObject];

    if (previousSelectedOption != selectedOption) {
        selectedOption.selected = [JSConstants stringFromBOOL:YES];
        previousSelectedOption.selected = [JSConstants stringFromBOOL:NO];

        [self.previousSelectedValues removeAllObjects];
        [self.previousSelectedValues addObject:previousSelectedOption];

        [self.selectedValues removeAllObjects];
        [self.selectedValues addObject:selectedOption];
    }

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", searchBar.text]];
        self.filteredListOfValues = [self.cell.inputControlDescriptor.state.options filteredArrayUsingPredicate:predicate];
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

@end
