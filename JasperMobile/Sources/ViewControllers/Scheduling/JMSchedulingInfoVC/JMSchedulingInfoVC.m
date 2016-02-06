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
//  JMSchedulingInfoVC.h
//  TIBCO JasperMobile
//

#import "JMSchedulingInfoVC.h"
#import "JMScheduleCell.h"
#import "JMSchedulingManager.h"
#import "JMNewScheduleVC.h"

@interface JMSchedulingInfoVC() <UITableViewDelegate, UITableViewDataSource, JMScheduleCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray <JSScheduleJobResource *> *schedules;
@property (nonatomic) JMSchedulingManager *schedulesManager;
@end

@implementation JMSchedulingInfoVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.resourceLookup.label;
    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

    self.schedulesManager = [JMSchedulingManager new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refresh];
}

#pragma mark - Actions
- (IBAction)newSchedule:(UIButton *)sender
{
    JMNewScheduleVC *newScheduleVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMNewScheduleVC"];
    newScheduleVC.resourceLookup = self.resourceLookup;
    newScheduleVC.exitBlock = ^() {
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:newScheduleVC animated:YES];
}

- (void)editSchedule:(JSScheduleJobResource *)schedule
{

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.schedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMScheduleCell *jobCell = [tableView dequeueReusableCellWithIdentifier:@"JMScheduleCell" forIndexPath:indexPath];
    jobCell.delegate = self;

    JSScheduleJobResource *schedue = self.schedules[indexPath.row];
    jobCell.titleLabel.text = [NSString stringWithFormat:@"%@ (state: %@)", schedue.label, schedue.state.value];
    jobCell.detailLabel.text = [NSString stringWithFormat:@"%@ (next run: %@)", schedue.jobDescription ?: @"", [self dateStringFromDate:schedue.state.nextFireTime]];

    jobCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return jobCell;
}

#pragma mark - JMScheduleCellDelegate
- (void)scheduleCellDidReceiveEditScheduleAction:(JMScheduleCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    JSScheduleJobResource *schedue = self.schedules[indexPath.row];
    [self editSchedule:schedue];
}

#pragma mark - Helpers
- (void)refresh
{
    __weak __typeof(self) weakSelf = self;
    [self.schedulesManager loadSchedulesForResourceLookup:self.resourceLookup completion:^(NSArray <JSScheduleJobResource *> *schedules, NSError *error) {
        __typeof(self) strongSelf = weakSelf;

        if (schedules) {
            strongSelf.schedules = schedules;
            [strongSelf.tableView reloadData];
        } else {
//            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }];
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    date = [NSDate dateWithTimeIntervalSince1970:timeInterval];

    NSString *dateString = [outputFormatter stringFromDate:date];
    return dateString;
}

@end