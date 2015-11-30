//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMNewJobVC.h"
#import "JMSchedulingManager.h"

@interface JMNewJobVC() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *jobNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
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

    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self
                   action:@selector(updateDate:)
         forControlEvents:UIControlEventValueChanged];
    self.dateTextField.inputView = datePicker;

    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, -40, 320, 40)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(setDate:)];
    [toolbar setItems:@[doneButton] animated:YES];
    self.dateTextField.inputAccessoryView = toolbar;

    self.dateTextField.text = [self dateStringFromDate:[NSDate date]];
}

#pragma mark - Actions
- (void)updateDate:(UIDatePicker *)sender
{
    JMLog(@"new date: %@", sender.date);
}

- (void)setDate:(UIButton *)sender
{
    JMLog(@"set date");

    NSDate *date = ((UIDatePicker *)self.dateTextField.inputView).date;
    self.dateTextField.text = [self dateStringFromDate:date];

    [self.dateTextField resignFirstResponder];
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
    NSMutableDictionary *newJob = [NSMutableDictionary dictionary];
    newJob[@"label"] = self.jobNameTextField.text;

    // trigger
    NSDictionary *simpleTrigger = @{
            @"simpleTrigger" : @{
                    @"timezone" : @"Europe/Helsinki",
                    @"startType" : @2,
                    @"startDate" : self.dateTextField.text,
                    @"occurrenceCount" : @1,
            }
    };
    newJob[@"trigger"] = simpleTrigger;

    // source
    // TODO: add params
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

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    // Increase to 1 min for test purposes
    // TODO: remove this
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    timeInterval += 60;
    date = [NSDate dateWithTimeIntervalSince1970:timeInterval];

    NSString *dateString = [outputFormatter stringFromDate:date];
    return dateString;
}

@end