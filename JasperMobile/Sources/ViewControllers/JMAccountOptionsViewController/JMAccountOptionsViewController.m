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


#import "JMAccountOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JMServerProfile+Helpers.h"
#import "JMAccountOptions.h"

#import "ALToastView.h"

#import "JMAccountOptionCell.h"


@interface JMAccountOptionsViewController () <UITableViewDataSource, UITableViewDelegate, JMAccountOptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) JMAccountOptions *accountOptions;
@end

@implementation JMAccountOptionsViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.title = JMCustomLocalizedString(@"account.options.title", nil);

    [self.saveButton setTitle:JMCustomLocalizedString(@"dialog.button.save", nil) forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[[JMThemesManager sharedManager] serverProfileSaveButtonTextColor] forState:UIControlStateNormal];
    self.saveButton.backgroundColor = [[JMThemesManager sharedManager] serverProfileSaveButtonBackgroundColor];
    
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];
    self.tableView.layer.cornerRadius = 4;

    self.tableView.rowHeight = 50.f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.accountOptions discardChanges];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (JMAccountOptions *)accountOptions
{
    if (!_accountOptions) {
        _accountOptions = [JMAccountOptions new];
    }
    return _accountOptions;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accountOptions.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMAccountOption *option = self.accountOptions.optionsArray[indexPath.row];
    
    JMAccountOptionCell *cell = (JMAccountOptionCell *) [tableView dequeueReusableCellWithIdentifier:option.cellIdentifier];
    cell.accountOption = option;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMAccountOption *option = self.accountOptions.optionsArray[indexPath.row];
    if (option.errorString) {
        CGFloat maxWidth = tableView.frame.size.width - 30;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [option.errorString boundingRectWithSize:maximumLabelSize
                                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        attributes:@{NSFontAttributeName:[[JMThemesManager sharedManager] tableViewCellErrorFont]}
                                                           context:nil];
        return tableView.rowHeight + ceilf(textRect.size.height);
    }
    return tableView.rowHeight;
}

#pragma mark - JMAccountOptionCellDelegate
- (void)reloadTableViewCell:(JMAccountOptionCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    if (cellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Actions

- (IBAction)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    if ([self.accountOptions isValidData]) {
        [self saveAccountOptions];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - Helpers
- (void)saveAccountOptions
{
    if ([self.accountOptions saveChanges] && [self.delegate respondsToSelector:@selector(accountOptionsDidChanged)]) {
        [self.delegate accountOptionsDidChanged];
    }
}


@end
