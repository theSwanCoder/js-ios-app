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

@interface JMDashboardInputControlsVC () <UITabBarDelegate, UITableViewDataSource, JMDashboardInputControlsCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation JMDashboardInputControlsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dashboard.inputControls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMDashboardInputControlsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMDashboardInputControlsCell"
                                                            forIndexPath:indexPath];
    NSDictionary *inputControl = self.dashboard.inputControls[indexPath.row];
    cell.nameLabel.text = inputControl[@"id"];

    cell.delegate = self;

    NSArray *values = inputControl[@"value"];
    if (values.count == 1) {
        cell.textField.text = values.firstObject;
    }

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

@end
