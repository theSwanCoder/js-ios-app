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
//  JMScheduleVC.m
//  TIBCO JasperMobile
//

#import "JMScheduleVC.h"
#import "JMScheduleManager.h"
#import "JMNewScheduleCell.h"
#import "JMNewScheduleBoolenCell.h"
#import "JMNewScheduleVCSection.h"


NSString *const kJMJobLabel            = @"kJMJobLabel";
NSString *const kJMJobDescription      = @"kJMJobDescription";
NSString *const kJMJobOutputFileURI    = @"kJMJobOutputFileURI";
NSString *const kJMJobOutputFolderURI  = @"kJMJobOutputFolderURI";
NSString *const kJMJobFormat           = @"kJMJobFormat";
NSString *const kJMJobStartDate        = @"kJMJobStartDate";
NSString *const kJMJobStartImmediately = @"kJMJobStartImmediately";

@interface JMScheduleVC () <UITableViewDataSource, UITableViewDelegate, JMNewScheduleCellDelegate, JMNewScheduleBoolenCellDelegate>
@property (weak, nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray <JMNewScheduleVCSection *> *sections;
//@property (nonatomic, strong) JSResourceLookup *resourceLookup;
//@property (nonatomic, strong) JSScheduleLookup *scheduleLookup;
//@property (strong, nonatomic) JMScheduleManager *scheduleManager;
@property (weak, nonatomic) IBOutlet UIButton *createJobButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation JMScheduleVC

#pragma mark - UIViewController LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Schedule";
    self.view.backgroundColor = [[JMThemesManager sharedManager] viewBackgroundColor];

    [self createScheduleRepresentationProperties];

    [self.createJobButton setTitle:@"Apply"
                          forState:UIControlStateNormal];
}

#pragma mark - Actions
- (void)updateDate:(UIDatePicker *)sender
{
    NSDate *newDate = sender.date;
    NSDate *currentDate = [NSDate date];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
        return;
    } else {
        // TODO: at the moment we support only simple trigger
        JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
        simpleTrigger.startDate = newDate;

        [self updateDateCellWithDate:newDate];
    }
}

- (void)setDate:(UIButton *)sender
{
    NSDate *newDate = self.datePicker.date;
    NSDate *currentDate = [NSDate date];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
        UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.error"
                                                                                          message:JMCustomLocalizedString(@"schedules.error.date.past", nil)
                                                                                cancelButtonTitle:@"dialog.button.ok"
                                                                          cancelCompletionHandler:nil];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    // TODO: at the moment we support only simple trigger
    JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
    simpleTrigger.startDate = newDate;

    [self updateDateCellWithDate:newDate];

    [[self dateCell].valueTextField resignFirstResponder];
}

- (void)updateDateCellWithDate:(NSDate *)date
{
    [self dateCell].valueTextField.text = [self dateStringFromDate:date];
}

- (JMNewScheduleCell *)dateCell
{
    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeSchedule];
    NSArray *rows = section.rows;
    NSInteger rowDateCell = [rows indexOfObject:kJMJobStartDate];
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:rowDateCell
                                                        inSection:JMNewScheduleVCSectionTypeSchedule];
    JMNewScheduleCell *dateCell = [self.tableView cellForRowAtIndexPath:dateCellIndexPath];
    return dateCell;
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
                                                 self.scheduleMetadata.outputFormats = @[format.uppercaseString];
                                                 formatCell.valueTextField.text = self.scheduleMetadata.outputFormats.firstObject;
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
        scheduleCell.valueTextField.text = self.scheduleMetadata.label;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobDescription]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.description", nil);
        scheduleCell.valueTextField.text = self.scheduleMetadata.scheduleDescription;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.output.file.name", nil);
        scheduleCell.valueTextField.text = self.scheduleMetadata.baseOutputFilename;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    }  else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.output.file.path", nil);
        scheduleCell.valueTextField.text = self.scheduleMetadata.folderURI;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobFormat]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.format", nil);
        scheduleCell.valueTextField.text = self.scheduleMetadata.outputFormats.firstObject;
        scheduleCell.valueTextField.userInteractionEnabled = NO;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobStartDate]) {
        JMNewScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.start.date", nil);

        // TODO: at the moment we support only simple trigger
        JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
        scheduleCell.valueTextField.text = [self dateStringFromDate:simpleTrigger.startDate];
        [self setupToolbarForTextField:scheduleCell.valueTextField];
        scheduleCell.delegate = self;
        cell = scheduleCell;
    } else if ([jobProperty isEqualToString:kJMJobStartImmediately]) {
        JMNewScheduleBoolenCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"JMNewScheduleBoolenCell" forIndexPath:indexPath];
        scheduleCell.titleLabel.text = JMCustomLocalizedString(@"schedules.new.job.start.immediately", nil);

        // TODO: at the moment we support only simple trigger
        JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
        scheduleCell.uiSwitch.on = simpleTrigger.startType == JSScheduleTriggerStartTypeImmediately;
        scheduleCell.delegate = self;
        cell = scheduleCell;
    }

    return cell;
}

#pragma mark - Save
- (IBAction)makeAction:(UIButton *)sender
{
    [self validateJobWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            self.exitBlock(self.scheduleMetadata);
        } else {
            [self updateView];
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
    }];
}

- (void)updateView
{
    [self.tableView reloadData];
}

#pragma mark - JMNewScheduleCellDelegate
- (void)scheduleCell:(JMNewScheduleCell *)cell didChangeValue:(NSString *)newValue
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JMNewScheduleVCSection *section = self.sections[indexPath.section];
    NSString *jobProperty = section.rows[indexPath.row];

    if ([jobProperty isEqualToString:kJMJobLabel]) {
        self.scheduleMetadata.label = [newValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else if ([jobProperty isEqualToString:kJMJobDescription]) {
        self.scheduleMetadata.scheduleDescription = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFileURI]) {
        self.scheduleMetadata.baseOutputFilename = newValue;
    } else if ([jobProperty isEqualToString:kJMJobOutputFolderURI]) {
        self.scheduleMetadata.folderURI = newValue;
    }
}

#pragma mark - JMNewScheduleBoolenCellDelegate
- (void)scheduleBoolenCell:(JMNewScheduleBoolenCell *)cell didChangeValue:(BOOL)newValue
{
    JMNewScheduleVCSection *section = self.sections[JMNewScheduleVCSectionTypeSchedule];
    // TODO: at the moment we support only simple trigger
    JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
    NSArray *scheduleRows;
    if (newValue) {
        simpleTrigger.startType = JSScheduleTriggerStartTypeImmediately;
        simpleTrigger.startDate = nil;
        scheduleRows = @[
                kJMJobStartImmediately,
        ];
    } else {
        simpleTrigger.startType = JSScheduleTriggerStartTypeAtDate;
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

    // TODO: at the moment we support only simple trigger
    JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
    NSArray *scheduleRows;
    if (simpleTrigger.startType == JSScheduleTriggerStartTypeImmediately) {
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

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[JSDateFormatterFactory sharedFactory] formatterWithPattern:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (void)setupToolbarForTextField:(UITextField *)textField
{
    if (!self.datePicker) {
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        // need set timezone to 0 because of received value
        datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        // TODO: at the moment we support only simple trigger
        JSScheduleSimpleTrigger *simpleTrigger = self.scheduleMetadata.trigger[@(JSScheduleTriggerTypeSimple)];
        datePicker.date = simpleTrigger.startDate;
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

    if (!self.scheduleMetadata.baseOutputFilename.length) {
        message = JMCustomLocalizedString(@"schedules.error.empty.filename", nil);
    } else if (!self.scheduleMetadata.folderURI.length) {
        message = JMCustomLocalizedString(@"schedules.error.empty.output.folder", nil);
    } else if (!self.scheduleMetadata.label.length) {
        message = JMCustomLocalizedString(@"schedules.error.empty.label", nil);
    } else if (!self.scheduleMetadata.outputFormats.count) {
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

@end