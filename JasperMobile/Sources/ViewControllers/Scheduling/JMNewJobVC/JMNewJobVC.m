//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMNewJobVC.h"
#import "JMSchedulingManager.h"

@interface JMNewJobVC() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *jobNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation JMNewJobVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Job";
    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

    self.jobNameTextField.text = self.resourceLookup.label;
    self.errorLabel.text = @"";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Save
- (IBAction)saveJob:(id)sender
{
    JMLog(@"save job");
    [self createJobWithCompletion:^(NSError *error) {
        if (error) {
            self.errorLabel.text = error.localizedDescription;
        } else {
            if (self.exitBlock) {
                self.exitBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Private API
- (void)createJobWithCompletion:(void(^)(NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSDictionary *jobData = [self createJobData];
    JMSchedulingManager *jobsManager = [JMSchedulingManager new];
    [jobsManager createJobWithData:jobData completion:^(NSDictionary *job, NSError *error) {
        JMLog(@"error of creating new job: %@", error);
        JMLog(@"job: %@", job);
        completion(error);
    }];
}

- (NSDictionary *)createJobData
{
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
    newJob[@"label"] = self.jobNameTextField.text;
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
            @"reportUnitURI" : self.resourceLookup.uri,
    };

    // output file name
    newJob[@"baseOutputFilename"] = self.fileNameTextField.text;

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
    return newJob;
}

@end