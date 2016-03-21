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
#import "JMNewScheduleBoolenCell.h"
#import "JMNewScheduleVCSection.h"


NSString *const kJMJobLabel = @"kJMJobLabel";
NSString *const kJMJobDescription = @"kJMJobDescription";
NSString *const kJMJobOutputFileURI = @"kJMJobOutputFileURI";
NSString *const kJMJobOutputFolderURI = @"kJMJobOutputFolderURI";
NSString *const kJMJobFormat = @"kJMJobFormat";
NSString *const kJMJobStartDate = @"kJMJobStartDate";
NSString *const kJMJobStartImmediately = @"kJMJobStartImmediately";

@interface JMNewScheduleVC () <UITableViewDataSource, UITableViewDelegate, JMNewJobCellDelegate, JMNewScheduleBoolenCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createJobButton;
@property (weak, nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) JSScheduleMetadata *scheduleResponse;
//@property (nonatomic, strong) NSDictionary *sections;
@property (nonatomic, strong) NSArray <JMNewScheduleVCSection *> *sections;
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

    [self createScheduleRepresentationProperties];

    [self createScheduleRepresentation];
}

#pragma mark - Actions
- (void)updateDate:(UIDatePicker *)sender
{
    self.scheduleResponse.trigger.startDate = sender.date;

    // find text field for date
    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeSchedule];
    NSArray *rows = section.rows;
    NSInteger rowDateCell = [rows indexOfObject:kJMJobStartDate];
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:rowDateCell
                                                        inSection:JMNewScheduleVCSectionTypeSchedule];
    JMNewScheduleCell *dateCell = [self.tableView cellForRowAtIndexPath:dateCellIndexPath];

    // set new value
    dateCell.valueTextField.text = [self dateStringFromDate:self.scheduleResponse.trigger.startDate];
}

- (void)setDate:(UIButton *)sender
{
    self.scheduleResponse.trigger.startDate = self.datePicker.date;

    // find text field for date
    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeSchedule];
    NSArray *rows = section.rows;
    NSInteger rowDateCell = [rows indexOfObject:kJMJobStartDate];
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:rowDateCell
                                                        inSection:JMNewScheduleVCSectionTypeSchedule];
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

    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeOutputOptions];
    NSArray *rows = section.rows;
    NSInteger rowFormatCell = [rows indexOfObject:kJMJobFormat];
    NSIndexPath *formatCellIndexPath = [NSIndexPath indexPathForRow:rowFormatCell
                                                          inSection:JMNewScheduleVCSectionTypeOutputOptions];
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

    JMNewScheduleVCSection *section = self.sections[indexPath.section];
    NSString *jobProperty = section.rows[indexPath.row];
    if ([jobProperty isEqualToString:kJMJobFormat]) {
        [self selectFormat:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[JMThemesManager sharedManager] tableViewCellTitleFont].lineHeight + 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    titleLabel.textColor = [[JMThemesManager sharedManager] reportOptionsTitleLabelTextColor];
    titleLabel.backgroundColor = [UIColor clearColor];

    JMNewScheduleVCSection *scheduleVCSection = self.sections[section];
    NSString *sectionTitle = scheduleVCSection.title;

    titleLabel.text = [sectionTitle uppercaseString];
    [titleLabel sizeToFit];

    UIView *headerView = [UIView new];
    [headerView addSubview:titleLabel];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant: -8.0]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    JMNewScheduleVCSection *scheduleVCSection = self.sections[section];
    NSArray *rows = scheduleVCSection.rows;

    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    JMNewScheduleVCSection *section = self.sections[indexPath.section];
    NSString *jobProperty = section.rows[indexPath.row];

    if ([jobProperty isEqualToString:kJMJobLabel]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.label", nil);
        scheduleCell.valueTextField.text = self.scheduleResponse.label;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobDescription]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.description", nil);
        scheduleCell.valueTextField.text = self.scheduleResponse.scheduleDescription;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.output.file.name", nil);
        scheduleCell.valueTextField.text = self.scheduleResponse.baseOutputFilename;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    }  else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.output.file.path", nil);
        scheduleCell.valueTextField.text = self.scheduleResponse.folderURI;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobFormat]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.format", nil);
        scheduleCell.valueTextField.text = self.scheduleResponse.outputFormats.firstObject;
        scheduleCell.valueTextField.userInteractionEnabled = NO;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobStartDate]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.start.date", nil);
        scheduleCell.valueTextField.text = [self dateStringFromDate:self.scheduleResponse.trigger.startDate];
        [self setupToolbarForTextField:scheduleCell.valueTextField];
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobStartImmediately]) {
        JMNewScheduleBoolenCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleBoolenCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.start.immediately", nil);
        scheduleCell.uiSwitch.on = self.scheduleResponse.trigger.startType == JSScheduleTriggerStartTypeImmediately;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    }

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
    JMNewScheduleVCSection *section = self.sections[indexPath.section];
    NSString *jobProperty = section.rows[indexPath.row];

    if ([jobProperty isEqualToString:kJMJobLabel]) {
        self.scheduleResponse.label = newValue;
    } else if ([jobProperty isEqualToString:kJMJobDescription]) {
        self.scheduleResponse.scheduleDescription = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        self.scheduleResponse.baseOutputFilename = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        self.scheduleResponse.folderURI = newValue;
    }
}

#pragma mark - JMNewScheduleBoolenCellDelegate
- (void)scheduleCell:(JMNewScheduleBoolenCell *)cell didChangeValue:(BOOL)newValue
{
    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeSchedule];
    NSArray *scheduleRows;
    if (newValue) {
        self.scheduleResponse.trigger.startType = JSScheduleTriggerStartTypeImmediately;
        scheduleRows = @[
                kJMJobStartImmediately,
        ];
    } else {
        self.scheduleResponse.trigger.startType = JSScheduleTriggerStartTypeAtDate;
        scheduleRows = @[
                kJMJobStartImmediately,
                kJMJobStartDate,
        ];
    }
    section.rows = scheduleRows;

    NSIndexSet *sectionIndecies = [NSIndexSet indexSetWithIndex:JMNewScheduleVCSectionTypeSchedule];
    [self.tableView reloadSections:sectionIndecies withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Helpers
- (void)createScheduleRepresentationProperties
{
    JMNewScheduleVCSection *mainSection = [JMNewScheduleVCSection sectionWithTitle:@"Main"
                                                                              type:JMNewScheduleVCSectionTypeMain
                                                                              rows:@[
                                                                                      kJMJobLabel,
                                                                                      kJMJobDescription,
                                                                              ]];

    JMNewScheduleVCSection *outputOptionsSection = [JMNewScheduleVCSection sectionWithTitle:@"Output Options"
                                                                              type:JMNewScheduleVCSectionTypeOutputOptions
                                                                              rows:@[
                                                                                      kJMJobOutputFileURI,
                                                                                      kJMJobOutputFolderURI,
                                                                                      kJMJobFormat,
                                                                              ]];

    NSArray *scheduleRows;
    if (self.scheduleResponse.trigger.startType == JSScheduleTriggerStartTypeImmediately) {
        scheduleRows = @[
                kJMJobStartImmediately,
        ];
    } else {
        scheduleRows = @[
                kJMJobStartImmediately,
                kJMJobStartDate,
        ];
    }
    JMNewScheduleVCSection *scheduleSection = [JMNewScheduleVCSection sectionWithTitle:@"Schedule Start"
                                                                              type:JMNewScheduleVCSectionTypeSchedule
                                                                              rows:scheduleRows];
    self.sections = @[
            mainSection,
            outputOptionsSection,
            scheduleSection
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
    if (!self.datePicker) {
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        [datePicker setDate:[NSDate date]];
        [datePicker addTarget:self
                       action:@selector(updateDate:)
             forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        self.datePicker = datePicker;
    }

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
    } else if (!self.scheduleResponse.label.length) {
        message = JMCustomLocalizedString(@"schedules.error.empty.label", nil);
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