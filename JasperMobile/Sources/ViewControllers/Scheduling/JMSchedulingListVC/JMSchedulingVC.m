//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMSchedulingVC.h"
#import "JMSchedulingManager.h"
#import "JMJobCell.h"

@interface JMSchedulingVC() <UITableViewDelegate, UITableViewDataSource, JMJobCellDelegate>
@property (nonatomic, copy) NSArray *jobs;
@property (nonatomic) JMSchedulingManager *jobsManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation JMSchedulingVC

#pragma mark -LifeCycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Scheduling";

    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

    self.jobsManager = [JMSchedulingManager new];
    [self.jobsManager loadJobsWithCompletion:^(NSArray *jobs, NSError *error) {
        JMLog(@"jobs: %@", jobs);
        self.jobs = jobs;
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.jobs = self.jobsManager.jobs;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return self.jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMJobCell *jobCell = (JMJobCell *) [tableView dequeueReusableCellWithIdentifier:@"JMJobCell" forIndexPath:indexPath];
    jobCell.delegate = self;
    NSDictionary *job = self.jobs[indexPath.row];
    jobCell.titleLabel.text = job[@"label"];
    jobCell.dateLabel.text = job[@"state"][@"nextFireTime"];
    return jobCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *job = self.jobs[indexPath.row];
    NSInteger jobIdendifier = ((NSNumber *)job[@"id"]).integerValue;
    [self.jobsManager jobInfoWithJobIdentifier:jobIdendifier
                                    completion:^(NSDictionary *jobInfo, NSError *error) {

                                    }];
}

#pragma mark - Actions
- (IBAction)addJob:(id)sender
{
    JMLog(@"add job");
//    {
//        "label": "Sample Job Name",
//        "description": "Sample desctiption",
//        "trigger": {
//            "simpleTrigger": {
//                "timezone": "America/Los_Angeles",
//                "startType": 2,
//                "startDate": "2013-10-26 10:00",
//                "occurrenceCount": 1
//            }
//        },
//        "source": {
//            "reportUnitURI": "/adhoc/topics/Cascading_multi_select_topic",
//            "parameters": {
//                "parameterValues": {
//                    "Country_multi_select": ["Mexico"],
//                            "Cascading_name_single_select": ["Chin-Lovell Engineering Associates"],
//                            "Cascading_state_multi_select": ["DF",
//                            "Jalisco",
//                            "Mexico"]
//                }
//            }
//        },
//        "baseOutputFilename": "Cascading_multi_select_report",
//        "outputTimeZone": "America/Los_Angeles",
//        "repositoryDestination": {
//            "folderURI": "/temp"
//        },
//        "outputFormats": {
//            "outputFormat": ["PDF", "XLS"]
//        }
//    }

    NSMutableDictionary *newJob = [NSMutableDictionary dictionary];
    newJob[@"label"] = @"Test Job Name (05. All Account) 3";
    // trigger

    NSDictionary *simpleTrigger = @{
        @"simpleTrigger" : @{
                    @"timezone" : @"Europe/Helsinki",
                    @"startType" : @2,
                    @"startDate" : @"2015-11-30 22:00",
                    @"occurrenceCount" : @1,
            }
    };
    newJob[@"trigger"] = simpleTrigger;

    // source
    newJob[@"source"] = @{
//            @"parameters" : @"<null>",
            @"reportUnitURI" : @"/public/Samples/Reports/AllAccounts",
    };

    // output file name
    newJob[@"baseOutputFilename"] = @"AllAccounts_Test3";

    // destination
    newJob[@"repositoryDestination"] =  @{
            @"folderURI" : @"/public/Samples/Reports"
    };

    // time zone
    newJob[@"outputTimeZone"] = @"Europe/Helsinki";

    // outputFormats
    newJob[@"outputFormats"] = @{
            @"outputFormat" : @[@"PDF"]
    };

    [self.jobsManager createJobWithData:newJob completion:^(NSDictionary *job, NSError *error) {
        [self.jobsManager loadJobsWithCompletion:^(NSArray *jobs, NSError *error) {
            self.jobs = jobs;
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark - JMJobCellDelegate
- (void)jobCellDidReceiveDeleteJobAction:(JMJobCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *job = self.jobs[indexPath.row];
    NSInteger jobIdendifier = ((NSNumber *)job[@"id"]).integerValue;
    [self.jobsManager deleteJobWithJobIdentifier:jobIdendifier
                                      completion:^(NSError *error) {
                                          [self.jobsManager loadJobsWithCompletion:^(NSArray *jobs, NSError *error) {
                                              self.jobs = jobs;
                                              [self.tableView reloadData];
                                          }];
                                      }];
}

@end