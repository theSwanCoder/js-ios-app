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
@property (nonatomic, copy) NSArray <JMDashlet *> *visibleComponents;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *>*maximizedComponents;
@end

@implementation JMExternalWindowDashboardControlsVC

#pragma mark - Custom Accessor
- (void)setComponents:(NSArray *)components
{
    _components = components;

    NSMutableArray *visibleComponents = [NSMutableArray array];
    NSMutableDictionary *maximizedComponets = [NSMutableDictionary dictionary];
    for (JMDashlet *dashlet in components) {
        JMDashletType type = dashlet.type;
        switch(type) {
            case JMDashletTypeChart:
            case JMDashletTypeReportUnit:
            case JMDashletTypeAdhocView: {
                [visibleComponents addObject:dashlet];
                maximizedComponets[dashlet.identifier] = @(NO);
                break;
            }
            default:{
                break;
            }
        }
    }
    self.visibleComponents = visibleComponents;
    self.maximizedComponents = maximizedComponets;

    [self.tableView reloadData];
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"JMExternalWindowDashboardControlsTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.visibleComponents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMExternalWindowDashboardControlsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMExternalWindowDashboardControlsTableViewCell"
                                                                                           forIndexPath:indexPath];
    JMDashlet *dashlet = self.visibleComponents[indexPath.row];
    cell.nameLabel.text = dashlet.name;
    BOOL isMaximized = self.maximizedComponents[dashlet.identifier].boolValue;
    NSString *buttonTitle;
    if (isMaximized) {
        buttonTitle = JMCustomLocalizedString(@"external.screen.button.title.manimize", nil);
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        buttonTitle = JMCustomLocalizedString(@"external.screen.button.title.maximize", nil);
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.maximizeButton setTitle:buttonTitle
                         forState:UIControlStateNormal];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // find maximized component
    JMDashlet *selectedDashlet = self.visibleComponents[indexPath.row];
    NSString *selectedComponentID = selectedDashlet.identifier;
    BOOL isSelectedComponentMaximized = self.maximizedComponents[selectedComponentID].boolValue;
    if (isSelectedComponentMaximized) {
        // minimize
        self.maximizedComponents[selectedComponentID] = @(NO);
        if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMinimizeDashlet:)]) {
            [self.delegate externalWindowDashboardControlsVC:self didAskMinimizeDashlet:selectedDashlet];
        }
    } else {
        // maximize if there aren't any other maximized
        NSString *maximizedComponentID;
        for (NSString *componentID in self.maximizedComponents.allKeys) {
            BOOL isMaximized = self.maximizedComponents[componentID].boolValue;
            if (isMaximized) {
                maximizedComponentID = componentID;
                break;
            }
        }

        if (!maximizedComponentID) {
            // maximize
            self.maximizedComponents[selectedComponentID] = @(YES);
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsVC:didAskMaximizeDashlet:)]) {
                [self.delegate externalWindowDashboardControlsVC:self didAskMaximizeDashlet:selectedDashlet];
            }
        }
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
