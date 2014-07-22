//
//  JMDetailSingleSelectTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMDetailSingleSelectTableViewController.h"
#import "JMListValueTableViewCell.h"
#import "JMFullScreenButtonProvider.h"


@interface JMDetailSingleSelectTableViewController() <JMFullScreenButtonProvider>
@property (nonatomic, assign) BOOL isSearching;
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
    return self.isSearching ? self.filteredListOfValues : self.cell.listOfValues;
}

- (void)setCell:(JMSingleSelectInputControlCell *)cell
{
    _cell = cell;
    
    for (JSInputControlOption *option in cell.listOfValues) {
        if (option.selected.boolValue) {
            [self.selectedValues addObject:option];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[cell.listOfValues indexOfObject:option] inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
            break;
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JMListValueTableViewCell class]) bundle:nil]
         forCellReuseIdentifier:kJMListValueTableViewCellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    // Remove extra separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchTextField.delegate = self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.0f, 0)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
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
    JMListValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJMListValueTableViewCellIdentifier];
    
    JSInputControlOption *option = [self.listOfValues objectAtIndex:indexPath.row];
    cell.valueLabel.text = option.label;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *searchQuery = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (searchQuery.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label beginswith[cd] %@", searchQuery];
        if (self.isSearching && string.length) {
            self.filteredListOfValues = [self.filteredListOfValues filteredArrayUsingPredicate:predicate];
        } else {
            self.filteredListOfValues = [self.cell.listOfValues filteredArrayUsingPredicate:predicate];
        }
        
        self.isSearching = YES;
    } else {
        self.isSearching = NO;
        self.filteredListOfValues = nil;
    }
    
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.isSearching = NO;
    self.filteredListOfValues = nil;
    self.searchTextField.text = nil;
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)search:(id)sender
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - JMFullScreenButtonProvider
- (BOOL)shouldDisplayFullScreenButton
{
    return YES;
}
@end
