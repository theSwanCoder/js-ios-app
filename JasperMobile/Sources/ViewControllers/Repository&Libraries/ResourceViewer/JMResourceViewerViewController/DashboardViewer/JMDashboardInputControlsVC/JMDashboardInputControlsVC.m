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


//
//  JMDashboardInputControlsVC.m
//  TIBCO JasperMobile
//

#import "JMDashboardInputControlsVC.h"
#import "JMDashboard.h"
#import "JMDashboardInputControlsCell.h"
#import "JMTextInputControlCell.h"
#import "JMDashboardParameter.h"

@interface JMDashboardInputControlsVC () <UITabBarDelegate, UITableViewDataSource, JMDashboardInputControlsCellDelegate, JMInputControlCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@end

@implementation JMDashboardInputControlsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup "Run Report" button
    self.applyButton.backgroundColor = [[JMThemesManager sharedManager] reportOptionsRunReportButtonBackgroundColor];
    [self.applyButton setTitleColor:[[JMThemesManager sharedManager] reportOptionsRunReportButtonTextColor]
                               forState:UIControlStateNormal];
    [self.applyButton setTitle:JMCustomLocalizedString(@"dialog.button.applyUpdate", nil)
                          forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dashboard.inputControls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMTextInputControlCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextEditCell"
                                                            forIndexPath:indexPath];
    JMDashboardParameter *dashboardParameter = self.dashboard.inputControls[indexPath.row];
    cell.titleLabel.text = dashboardParameter.identifier;
    cell.textField.text = [dashboardParameter valuesAsString];

    cell.delegate = self;

    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - Actions
- (IBAction)doneAction:(id)sender
{
    if (self.exitBlock) {
        self.exitBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - JMDashboardInputControlsCellDelegate
- (void)dashboardInputControlsCell:(JMDashboardInputControlsCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *inputControl = self.dashboard.inputControls[indexPath.row];
    NSMutableDictionary *updatedInputControl = [inputControl mutableCopy];
    NSArray *value = @[text];
    updatedInputControl[@"value"] = value;

    NSMutableArray *updatedInputControls = [self.dashboard.inputControls mutableCopy];
    updatedInputControls[indexPath.row] = updatedInputControl;
    self.dashboard.inputControls = updatedInputControls;
}

#pragma mark - JMInputControlCellDelegate
- (void)reloadTableViewCell:(JMInputControlCell *)cell
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)inputControlCellDidChangedValue:(JMInputControlCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JMDashboardParameter *dashboardParameter = self.dashboard.inputControls[indexPath.row];

    JMTextInputControlCell *textInputControlCell = (JMTextInputControlCell *) cell;
    NSString *newValue = textInputControlCell.textField.text;

    // TODO: replace with another approach for saving values.
    [dashboardParameter updateValuesWithString:newValue];
}

- (void)updatedInputControlsValuesWithDescriptor:(JSInputControlDescriptor *)descriptor
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}


@end
