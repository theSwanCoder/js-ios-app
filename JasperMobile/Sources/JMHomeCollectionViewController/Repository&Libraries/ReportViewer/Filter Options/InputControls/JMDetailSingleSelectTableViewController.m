//
//  JMDetailSingleSelectTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSingleSelectTableViewController.h"
#import "JMSearchBar.h"

@interface JMDetailSingleSelectTableViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, JMSearchBarDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (strong, nonatomic) JMSearchBar *searchBar;

@property (nonatomic, strong) NSArray *filteredListOfValues;
@end

@implementation JMDetailSingleSelectTableViewController

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
    return self.filteredListOfValues ? self.filteredListOfValues : self.cell.listOfValues;
}

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;
    
    for (JSInputControlOption *option in cell.listOfValues) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
        }
    }
    
    if ([self.selectedValues count] == 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[cell.listOfValues indexOfObject:[self.selectedValues anyObject]] inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.cell.inputControlDescriptor.label;
    self.titleLabel.text = JMCustomLocalizedString(@"detail.report.options.singleselect.titlelabel.title", nil);
    self.titleLabel.textColor = kJMDetailViewLightTextColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self showNavigationItems];
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
        [self.cell updateWithParameters:@[selectedOption]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (void)searchButtonTapped:(id)sender
{
    if (!self.searchBar) {
        self.searchBar = [[JMSearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 34)];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
}

- (void) showNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_item.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(searchButtonTapped:)];
}

#pragma mark - JMSearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarClearButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.filteredListOfValues = nil;
    [self.tableView reloadData];

    [self showNavigationItems];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{    [searchBar resignFirstResponder];
    if ([searchBar.text length] == 0) {
        [self showNavigationItems];
    }
}

- (void)searchBarDidChangeText:(JMSearchBar *)searchBar
{
    if (searchBar.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label beginswith[cd] %@", searchBar.text];
        self.filteredListOfValues = [self.cell.listOfValues filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredListOfValues = nil;
    }
    
    [self.tableView reloadData];
}

@end
