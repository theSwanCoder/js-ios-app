//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMNewJobVC.h"
@interface JMNewJobVC() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *jobNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;

@end

@implementation JMNewJobVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Job";
    self.view.backgroundColor = [[JMThemesManager sharedManager] resourceViewBackgroundColor];

//    self.jobNameTextField.text = self.resourceLookup.label;
//    self.fileNameTextField.text = self.resourceLookup.label;
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
    if (self.exitBlock) {
        self.exitBlock([self createJob]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private API
- (NSDictionary *)createJob
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
            @"reportUnitURI" : @"/public/Samples/Reports/AllAccounts",
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