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
#import "JMSchedulingManager.h"
#import "JMScheduleCell.h"
#import "JSScheduleJobResource.h"
#import "JSScheduleJobState.h"
#import "JMNewScheduleVC.h"

@interface JMSchedulingListVC () <UITableViewDelegate, UITableViewDataSource, JMJobCellDelegate>
@property (nonatomic, copy) NSArray <JSScheduleJobResource *> *jobs;
@property (nonatomic) JMSchedulingManager *jobsManager;
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

    self.jobsManager = [JMSchedulingManager new];

    [self updateNoJobsLabelAppearence];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;

    self.noJobsLabel.text = JMCustomLocalizedString(@"schedules.no.jobs.message", nil);
    [self showNoJobsLabel:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    __weak __typeof(self) weakSelf = self;
    [self.jobsManager loadJobsWithCompletion:^(NSArray <JSScheduleJobResource *>*jobs, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        strongSelf.jobs = jobs;
        [strongSelf updateNoJobsLabelAppearence];

        [strongSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMScheduleCell *jobCell = [tableView dequeueReusableCellWithIdentifier:@"JMScheduleCell" forIndexPath:indexPath];
    jobCell.delegate = self;

    JSScheduleJobResource *job = self.jobs[indexPath.row];
    jobCell.titleLabel.text = [NSString stringWithFormat:@"%@ (state: %@)", job.label, job.state.value];
    jobCell.detailLabel.text = [NSString stringWithFormat:@"%@ (next run: %@)", job.jobDescription ?: @"", [self dateStringFromDate:job.state.nextFireTime]];

    jobCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return jobCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (IBAction)refresh:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    [self.jobsManager loadJobsWithCompletion:^(NSArray <JSScheduleJobResource *>*jobs, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];

        strongSelf.jobs = jobs;
        [strongSelf updateNoJobsLabelAppearence];

        [strongSelf.tableView reloadData];
    }];
}

- (IBAction)addNewSchedule:(id)sender
{
//    JMNewScheduleVC *newJobVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JMNewScheduleVC"];
//    [self.navigationController pushViewController:newJobVC animated:YES];
}

#pragma mark - JMJobCellDelegate
- (void)jobCellDidReceiveDeleteJobAction:(JMScheduleCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JSScheduleJobResource *job = self.jobs[indexPath.row];

    __weak __typeof(self) weakSelf = self;
    [self.jobsManager deleteJobWithJobIdentifier:job.jobIdentifier
                                      completion:^(NSError *error) {
                                          __typeof(self) strongSelf = weakSelf;

                                          NSMutableArray *jobs = [strongSelf.jobs mutableCopy];
                                          [jobs removeObject:job];
                                          strongSelf.jobs = [jobs copy];
                                          [strongSelf updateNoJobsLabelAppearence];

                                          [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                                                withRowAnimation:UITableViewRowAnimationLeft];

                                      }];
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
    [self showNoJobsLabel:(self.jobs.count == 0)];
}

@end