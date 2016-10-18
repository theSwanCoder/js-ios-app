/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMReportChartTypesVC.m
//  TIBCO JasperMobile
//

#import "JMReportChartTypesVC.h"
#import "JMReportChartType.h"

@interface JMReportChartTypesVC() <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation JMReportChartTypesVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMLocalizedString(@"report_chart_type_view_title");
    [self.view setAccessibility:NO withTextKey:@"report_chart_type_view_title" identifier:JMReportViewerChartTypePageTitleAccessibilityId];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chartTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportChartTypeCell" forIndexPath:indexPath];
    JMReportChartType *chartType = self.chartTypes[indexPath.row];
    cell.isAccessibilityElement = YES;
    cell.accessibilityIdentifier = JMReportViewerChartTypePageCellAccessibilityId;

    cell.textLabel.text = chartType.name;
    cell.imageView.image = [UIImage imageNamed:chartType.imageName];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JMReportChartType *chartType = self.chartTypes[indexPath.row];
    if (self.exitBlock) {
        self.exitBlock(chartType);
    } else {
        // TODO: need other way of closing the view.
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMReportChartType *chartType = self.chartTypes[indexPath.row];
    if ([chartType.name isEqualToString:self.selectedChartType.name]) {
        [cell setSelected:YES animated:YES];
    }
}

@end
