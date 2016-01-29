//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMSchedulingVC.h"
#import "JMSchedulingManager.h"
#import "JMJobCell.h"
#import "JSScheduleJobResource.h"
#import "JSScheduleJobState.h"

@interface JMSchedulingVC() <UITableViewDelegate, UITableViewDataSource, JMJobCellDelegate>
@property (nonatomic, copy) NSArray <JSScheduleJobResource *> *jobs;
@property (nonatomic) JMSchedulingManager *jobsManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *noJobsLabel;
@end

@implementation JMSchedulingVC

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
        [strongSelf.tableView reloadData];

        [strongSelf updateNoJobsLabelAppearence];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMJobCell *jobCell = [tableView dequeueReusableCellWithIdentifier:@"JMJobCell" forIndexPath:indexPath];
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
        [strongSelf.tableView reloadData];
    }];
}

#pragma mark - JMJobCellDelegate
- (void)jobCellDidReceiveDeleteJobAction:(JMJobCell *)cell
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
                                          [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                                                withRowAnimation:UITableViewRowAnimationLeft];

                                          [strongSelf updateNoJobsLabelAppearence];
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