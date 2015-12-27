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
//  JMExternalWindowDashboardControlsVC.m
//  TIBCO JasperMobile
//

#import "JMExternalWindowDashboardControlsVC.h"
#import "JMExternalWindowDashboardControlsTableViewCell.h"
#import "JMDashlet.h"

@interface JMExternalWindowDashboardControlsVC () <UITableViewDelegate, UITableViewDataSource, JMExternalWindowDashboardControlsTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation JMExternalWindowDashboardControlsVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"JMExternalWindowDashboardControlsTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.components.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMExternalWindowDashboardControlsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"
                                                                                           forIndexPath:indexPath];
    JMDashlet *dashlet = self.components[indexPath.row];
    cell.nameLabel.text = dashlet.name;
    cell.delegate = self;
    return cell;
}

#pragma mark - JMExternalWindowDashboardControlsTableViewCellDelegate
- (void)externalWindowDashboardControlsTableViewCellDidMaximize:(JMExternalWindowDashboardControlsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JMDashlet *dashlet = self.components[indexPath.row];
    JMLog(@"need maximize dashlet: %@", dashlet.name);
    if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMaximizeDashlet:)]) {
        [self.delegate externalWindowDashboardControlsVC:self didAskMaximizeDashlet:dashlet];
    }
}

- (void)externalWindowDashboardControlsTableViewCellDidMinimize:(JMExternalWindowDashboardControlsTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JMDashlet *dashlet = self.components[indexPath.row];
    JMLog(@"need minimize dashlet: %@", dashlet.name);
    if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMinimizeDashlet:)]) {
        [self.delegate externalWindowDashboardControlsVC:self didAskMinimizeDashlet:dashlet];
    }
}

@end
