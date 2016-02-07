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
//  JMSchedulingListVC.h
//  TIBCO JasperMobile
//

#import "JMSchedulingListVC.h"
#import "JMScheduleManager.h"
#import "JMScheduleCell.h"
#import "JMNewScheduleVC.h"

@interface JMSchedulingListVC () <UITableViewDelegate, UITableViewDataSource, JMScheduleCellDelegate>
@property (nonatomic, copy) NSArray <JSScheduleLookup *> *scheduleSummaries;
@property (nonatomic) JMScheduleManager *schedulesManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *noJobsLabel;
@end

@implementation JMSchedulingListVC

#pragma mark - LifeCycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"schedules.title", nil);

    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

    self.schedulesManager = [JMScheduleManager new];

    [self updateNoJobsLabelAppearence];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;

    self.noJobsLabel.text = JMCustomLocalizedString(@"schedules.no.jobs.message", nil);
    [self showNoJobsLabel:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scheduleSummaries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMScheduleCell *jobCell = [tableView dequeueReusableCellWithIdentifier:@"JMScheduleCell" forIndexPath:indexPath];
    jobCell.delegate = self;

    JSScheduleLookup *job = self.scheduleSummaries[indexPath.row];
    jobCell.titleLabel.text = [NSString stringWithFormat:@"%@ (state: %@)", job.label, job.state.value];
    jobCell.detailLabel.text = [NSString stringWithFormat:@"%@ (next run: %@)", job.scheduleDescription ?: @"", [self dateStringFromDate:job.state.nextFireTime]];

    jobCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return jobCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    JSScheduleLookup *scheduleSummary = self.scheduleSummaries[indexPath.row];
    [self editSchedule:scheduleSummary];
}

#pragma mark - Actions
- (void)refresh
{
    __weak __typeof(self) weakSelf = self;
    [self.schedulesManager loadSchedulesForResourceLookup:nil completion:^(NSArray <JSScheduleLookup *> *jobs, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];

        strongSelf.scheduleSummaries = jobs;
        [strongSelf updateNoJobsLabelAppearence];

        [strongSelf.tableView reloadData];
    }];
}

- (void)editSchedule:(JSScheduleLookup *)schedule
{
    JMNewScheduleVC *newScheduleVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"JMNewScheduleVC"];
    newScheduleVC.scheduleSummary = schedule;
    newScheduleVC.mode = JMScheduleModeEdit;
    [self.navigationController pushViewController:newScheduleVC animated:YES];
}

- (void)deleteSchedule:(JSScheduleLookup *)scheduleSummary
{
    __weak __typeof(self) weakSelf = self;
    [self.schedulesManager deleteJobWithJobIdentifier:scheduleSummary.jobIdentifier
                                           completion:^(NSError *error) {
                                               __typeof(self) strongSelf = weakSelf;

                                               NSInteger scheduleSummaryIndex = [strongSelf.scheduleSummaries indexOfObjectIdenticalTo:scheduleSummary];

                                               NSMutableArray *jobs = [strongSelf.scheduleSummaries mutableCopy];
                                               [jobs removeObject:scheduleSummary];
                                               strongSelf.scheduleSummaries = [jobs copy];

                                               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:scheduleSummaryIndex inSection:0];
                                               [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                                                           withRowAnimation:UITableViewRowAnimationLeft];

                                           }];
}

#pragma mark - JMJobCellDelegate
- (void)scheduleCellDidReceiveDeleteScheduleAction:(JMScheduleCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JSScheduleLookup *scheduleSummary = self.scheduleSummaries[indexPath.row];

    [self deleteSchedule:scheduleSummary];
}

#pragma mark - Helpers
-(void)showNoJobsLabel:(BOOL)shouldShow
{
    self.noJobsLabel.hidden = !shouldShow;
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

- (void)updateNoJobsLabelAppearence
{
    [self showNoJobsLabel:(self.scheduleSummaries.count == 0)];
}

@end