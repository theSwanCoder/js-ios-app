/*
 * Tibco JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
#import "JMSearchBar.h"

@interface JMSingleSelectTableViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, JMSearchBarDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel     *noResultLabel;

@property (nonatomic, strong) NSArray *filteredListOfValues;
@property (nonatomic, strong) NSMutableSet *previousSelectedValues;

@end

@implementation JMSingleSelectTableViewController

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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.cell.inputControlDescriptor.label;
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.singleselect.titlelabel.title", nil);
    self.noResultLabel.text = JMCustomLocalizedString(@"detail.noresults.msg", nil);
    
    self.titleLabel.textColor = kJMDetailViewLightTextColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self showNavigationItems];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self.previousSelectedValues isEqualToSet:self.selectedValues]) {
        [self.cell updateWithParameters:[self.selectedValues allObjects]];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
        cell.textLabel.font = [JMFont tableViewCellTitleFont];
    }
    
    JSInputControlOption *option = [self.listOfValues objectAtIndex:indexPath.row];
    cell.textLabel.text = option.label;
    cell.accessoryType = option.selected.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSInputControlOption *selectedOption = [self.listOfValues objectAtIndex:indexPath.row];
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

#pragma mark - Actions

- (void)searchButtonTapped:(id)sender
{
    CGRect searchBarFrame = [JMUtils isIphone] ? self.navigationController.navigationBar.bounds : CGRectMake(0, 0, 320, 44);
    JMSearchBar *searchBar =  [[JMSearchBar alloc] initWithFrame:searchBarFrame];
    searchBar.delegate = self;
    searchBar.placeholder = JMCustomLocalizedString(@"detail.report.options.search.value.placeholder", nil);
    
    if ([JMUtils isIphone]) {
        self.navigationItem.hidesBackButton = YES;
        [self.navigationController.navigationBar addSubview:searchBar];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    }
}

- (void) showNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_item"] style:UIBarButtonItemStyleBordered target:self action:@selector(searchButtonTapped:)];
}

#pragma mark - JMSearchBarDelegate
- (void)searchBarSearchButtonClicked:(JMSearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(JMSearchBar *) searchBar
{
    [searchBar resignFirstResponder];
    self.filteredListOfValues = nil;
    [self.tableView reloadData];
    if ([JMUtils isIphone]) {
        [searchBar removeFromSuperview];
        self.navigationItem.hidesBackButton = NO;
    } else {
        [self showNavigationItems];
    }
}

- (void)searchBarDidChangeText:(JMSearchBar *)searchBar
{
    if (searchBar.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label beginswith[cd] %@", searchBar.text];
        self.filteredListOfValues = [self.cell.inputControlDescriptor.state.options filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredListOfValues = nil;
    }
    self.noResultLabel.hidden = ([self.listOfValues count] > 0);
    self.tableView.hidden = !([self.listOfValues count] > 0);
    self.titleLabel.hidden = !([self.listOfValues count] > 0);

    [self.tableView reloadData];
}

@end
