/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportChartTypesVC.h"
#import "JMLocalization.h"
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
    cell.textLabel.text = chartType.name;
    // TODO: enable showing icons after getting API or other way
//    cell.imageView.image = [UIImage imageNamed:chartType.imageName];
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
