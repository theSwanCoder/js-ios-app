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
//  JMNewScheduleVC.m
//  TIBCO JasperMobile
//

#import "JMNewScheduleVC.h"
#import "JMScheduleManager.h"
#import "JMNewScheduleCell.h"

NSString *const kJMJobLabel = @"kJMJobLabel";
NSString *const kJMJobOutputFileURI = @"kJMJobOutputFileURI";
NSString *const kJMJobOutputFolderURI = @"kJMJobOutputFolderURI";
NSString *const kJMJobFormat = @"kJMJobFormat";
NSString *const kJMJobStartDate = @"kJMJobStartDate";

@interface JMNewScheduleVC () <UITableViewDataSource, UITableViewDelegate, JMNewJobCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JSScheduleMetadata *scheduleResponse;
@property (nonatomic, strong) NSArray *jobRepresentationProperties;
@property (weak, nonatomic) IBOutlet UIButton *createJobButton;
@property (strong, nonatomic) JMScheduleManager *scheduleManager;
@end

@implementation JMNewScheduleVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.mode == JMScheduleModeNew) {
        self.title = @"New Schedule";
        [self.createJobButton setTitle:JMCustomLocalizedString(@"schedules.new.job.button.create", nil)
                              forState:UIControlStateNormal];
    } else if (self.mode == JMScheduleModeEdit) {
        self.title = @"Edit Schedule";
        [self.createJobButton setTitle:@"Update"
                              forState:UIControlStateNormal];
    }

    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];

    self.scheduleManager = [JMScheduleManager new];

    // date text field
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self
                   action:@selector(updateDate:)
         forControlEvents:UIControlEventValueChanged];

    [self createScheduleRepresentationProperties];

    [self createScheduleRepresentation];
}

#pragma mark - Actions
- (void)updateDate:(UIDatePicker *)sender
{
    self.scheduleResponse.trigger.startDate = sender.date;

    // find text field for date
    NSInteger rowDateCell = [self.jobRepresentationProperties indexOfObject:kJMJobStartDate];
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:rowDateCell inSection:0];
    JMNewScheduleCell *dateCell = [self.tableView cellForRowAtIndexPath:dateCellIndexPath];

    // set new value
    dateCell.valueTextField.text = [self dateStringFromDate:self.scheduleResponse.trigger.startDate];
}

- (void)setDate:(UIButton *)sender
{
    // find text field for date
    NSInteger rowDateCell = [self.jobRepresentationProperties indexOfObject:kJMJobStartDate];
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:rowDateCell inSection:0];
    JMNewScheduleCell *dateCell = [self.tableView cellForRowAtIndexPath:dateCellIndexPath];

    // set new value
    dateCell.valueTextField.text = [self dateStringFromDate:self.scheduleResponse.trigger.startDate];
    [dateCell.valueTextField resignFirstResponder];
}

- (IBAction)selectFormat:(id)sender
{
    NSArray *availableFormats = @[
            kJS_CONTENT_TYPE_HTML,
            kJS_CONTENT_TYPE_PDF,
            kJS_CONTENT_TYPE_XLS
    ];

    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:JMCustomLocalizedString(@"schedules.new.job.output.format", nil)
                                                                                      message:nil
                                                                            cancelButtonTitle:@"dialog.button.cancel"
                                                                      cancelCompletionHandler:nil];

    NSInteger rowFormatCell = [self.jobRepresentationProperties indexOfObject:kJMJobFormat];
    NSIndexPath *formatCellIndexPath = [NSIndexPath indexPathForRow:rowFormatCell inSection:0];
    JMNewScheduleCell *formatCell = [self.tableView cellForRowAtIndexPath:formatCellIndexPath];

    for (NSString *format in availableFormats) {
        [alertController addActionWithLocalizedTitle:format style:UIAlertActionStyleDefault
                                             handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
                                                 self.scheduleResponse.outputFormats = @[format.uppercaseString];
                                                 formatCell.valueTextField.text = self.scheduleResponse.outputFormats.firstObject;
                                             }];
    }

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *jobProperty = self.jobRepresentationProperties[indexPath.row];
    if ([jobProperty isEqualToString:kJMJobFormat]) {
        [self selectFormat:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobRepresentationProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMNewScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];

    NSString *jobProperty = self.jobRepresentationProperties[indexPath.row];

    NSString *propertyTitle;
    NSString *propertyValue;
    if ([jobProperty isEqualToString:kJMJobLabel]) {
        propertyTitle = JMCustomLocalizedString(@"schedules.new.job.label", nil);
        propertyValue = self.scheduleResponse.label;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        propertyTitle = JMCustomLocalizedString(@"schedules.new.job.output.file.name", nil);
        propertyValue = self.scheduleResponse.baseOutputFilename;
    }  else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        propertyTitle = JMCustomLocalizedString(@"schedules.new.job.output.file.path", nil);
        propertyValue = self.scheduleResponse.folderURI;
    } else if ([jobProperty isEqualToString:kJMJobFormat]) {
        propertyTitle = JMCustomLocalizedString(@"schedules.new.job.format", nil);
        propertyValue = self.scheduleResponse.outputFormats.firstObject;
        cell.valueTextField.userInteractionEnabled = NO;
    } else if ([jobProperty isEqualToString:kJMJobStartDate]) {
        propertyTitle = JMCustomLocalizedString(@"schedules.new.job.start.date", nil);
        propertyValue = [self dateStringFromDate:self.scheduleResponse.trigger.startDate];
        [self setupToolbarForTextField:cell.valueTextField];
    }

    cell.titleLabel.text = propertyTitle;
    cell.valueTextField.text = propertyValue;

    cell.delegate = self;

    return cell;
}

#pragma mark - Save
- (IBAction)saveJob:(id)sender
{
    [self validateJobWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            switch (self.mode) {
                case JMScheduleModeNew: {

                    [self.scheduleManager createJobWithData:self.scheduleResponse
                                                 completion:^(JSScheduleMetadata *job, NSError *error) {
                                                    if (error) {
                                                         [JMUtils presentAlertControllerWithError:error completion:nil];
                                                     } else {
                                                         if (self.exitBlock) {
                                                             self.exitBlock();
                                                         }
                                                        [self.navigationController popViewControllerAnimated:YES];
                                                     }
                                                 }];

                    break;
                }
                case JMScheduleModeEdit: {

                    [self.scheduleManager updateSchedule:self.scheduleResponse
                                              completion:^(JSScheduleMetadata *job, NSError *error) {
                                                  if (error) {
                                                      [JMUtils presentAlertControllerWithError:error completion:nil];
                                                  } else {
                                                      if (self.exitBlock) {
                                                          self.exitBlock();
                                                      }
                                                      [self.navigationController popViewControllerAnimated:YES];
                                                  }
                                              }];
                    break;
                }
            }
        } else {
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }];
}

#pragma mark - JMNewJobCellDelegate
- (void)jobCell:(JMNewScheduleCell *)cell didChangeValue:(NSString *)newValue
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *jobProperty = self.jobRepresentationProperties[indexPath.row];
    if ([jobProperty isEqualToString:kJMJobLabel]) {
        self.scheduleResponse.label = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        self.scheduleResponse.baseOutputFilename = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        self.scheduleResponse.folderURI = newValue;
    }
}

#pragma mark - Helpers
- (void)createScheduleRepresentationProperties
{
    self.jobRepresentationProperties = @[
            kJMJobLabel,
            kJMJobOutputFileURI,
            kJMJobOutputFolderURI,
            kJMJobFormat,
            kJMJobStartDate
    ];
}

- (void)createScheduleRepresentation
{
    switch (self.mode) {
        case JMScheduleModeNew: {
            NSString *resourceFolder = [self.resourceLookup.uri stringByDeletingLastPathComponent];
            self.scheduleResponse = [JSScheduleMetadata new];
            self.scheduleResponse.reportUnitURI = self.resourceLookup.uri;
            self.scheduleResponse.label = self.resourceLookup.label;
            self.scheduleResponse.baseOutputFilename = [self filenameFromLabel:self.resourceLookup.label];
            self.scheduleResponse.folderURI = resourceFolder;
            self.scheduleResponse.outputFormats = [self defaultFormats];
            self.scheduleResponse.trigger.startDate = [NSDate date];
            break;
        }
        case JMScheduleModeEdit: {
            // TODO: add loading indicator
            [self.scheduleManager loadScheduleInfoWithScheduleId:self.scheduleSummary.jobIdentifier completion:^(JSScheduleMetadata *schedule, NSError *error) {
                if (schedule) {
                    self.scheduleResponse = schedule;
                    [self.tableView reloadData];
                } else {
                    [JMUtils presentAlertControllerWithError:error completion:nil];
                }
            }];
            break;
        }
    }
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc]init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [outputFormatter stringFromDate:date];
    return dateString;
}

- (void)setupToolbarForTextField:(UITextField *)textField
{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self
                   action:@selector(updateDate:)
         forControlEvents:UIControlEventValueChanged];
    textField.inputView = datePicker;


    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(setDate:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    [toolbar setItems:@[flexibleSpace, doneButton] animated:YES];
    textField.inputAccessoryView = toolbar;
}

- (void)validateJobWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    if (!completion) {
        return;
    }

    NSString *message;

    if (!self.scheduleResponse.baseOutputFilename) {
        message = JMCustomLocalizedString(@"schedules.error.empty.filename", nil);
    } else if (!self.scheduleResponse.outputFormats.count) {
        message = JMCustomLocalizedString(@"schedules.error.empty.format", nil);
    }

    if (message) {
        NSError *error = [[NSError alloc] initWithDomain:JMCustomLocalizedString(@"schedules.error.domain", nil)
                                                    code:0
                                                userInfo:@{ NSLocalizedDescriptionKey : message }];
        completion(NO, error);
    } else {
        completion(YES, nil);
    }
}

- (NSArray *)defaultFormats
{
    return @[kJS_CONTENT_TYPE_PDF.uppercaseString];
}

- (NSString *)filenameFromLabel:(NSString *)label
{
    NSString *filename = [label stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return filename;
}

@end