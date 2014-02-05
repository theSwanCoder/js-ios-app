/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMSavedReportsTableViewController.m
//  Jaspersoft Corporation
//

#import "JMSavedReportsTableViewController.h"
#import "JMConstants.h"
#import "JMSavedReportViewerViewController.h"
#import "JMSavedReportModifyViewController.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"

static NSString * const kJMShowSavedReportSegue = @"ShowSavedReport";
static NSString * const kJMShowSavedReportModifyControllerSegue = @"ShowSavedReportModifyController";
static NSString * const kJMDSStoreFile = @".DS_Store";

@interface JMReportTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *reportNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel;
@end

@implementation JMReportTableViewCell
@end

@interface JMSavedReportsTableViewController()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray *reports;
@property (nonatomic, assign) NSInteger reportToModify;
@end

@implementation JMSavedReportsTableViewController

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearSavedReports)
                                                 name:kJMClearSavedReportsListNotification
                                               object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.fileManager = [NSFileManager defaultManager];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.reports.count) {
        self.reports = [[self.fileManager contentsOfDirectoryAtPath:[JMUtils documentsReportDirectoryPath] error:nil] mutableCopy];
        [self.reports removeObject:kJMDSStoreFile];

        NSString *reportDirectory = [JMUtils documentsReportDirectoryPath];
        [self.reports sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *obj1Date = [self modificationDateForDirectory:[reportDirectory stringByAppendingPathComponent:obj1]];
            NSDate *obj2Date = [self modificationDateForDirectory:[reportDirectory stringByAppendingPathComponent:obj2]];
            return [obj2Date compare:obj1Date];
        }];
    }

    [self checkAvailabilityOfEditButton];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kJMShowSavedReportSegue]) {
        [segue.destinationViewController setReportPath:sender];
    } else {
        self.reportToModify = [sender row];
        [segue.destinationViewController setReportName:[self.reports objectAtIndex:self.reportToModify]];
    }
}

#pragma mark - UIViewControllerEditing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self checkAvailabilityOfEditButton];
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.reports = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *report = [self.reports objectAtIndex:indexPath.row];
    NSString *reportDirectory = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:report];
    NSMutableArray *files = [[self.fileManager subpathsOfDirectoryAtPath:reportDirectory error:nil] mutableCopy];
    [files removeObject:kJMDSStoreFile];
    double size = 0;

    for (NSString *file in files) {
        NSString *filePath = [reportDirectory stringByAppendingPathComponent:file];
        NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:filePath error:nil];
        size += fileAttributes.fileSize;
    }

    // Table view cell has the same identifier as a file extension
    JMReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:report.pathExtension];
    cell.reportNameLabel.text = [report stringByDeletingPathExtension];
    cell.creationDateLabel.text = [self.dateFormatter stringFromDate:[self modificationDateForDirectory:reportDirectory]];
    cell.sizeLabel.text = [self formattedSize:size];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *report = [self.reports objectAtIndex:indexPath.row];
        NSString *reportDirectory = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:report];
        [self.fileManager removeItemAtPath:reportDirectory error:nil];
        [self.reports removeObject:report];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMReportTableViewCell *cell = (JMReportTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    NSString *reportPath = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@/report.%@",
                    cell.reportNameLabel.text, cell.reuseIdentifier, cell.reuseIdentifier]];
    if (![self.fileManager fileExistsAtPath:reportPath]) {
        [[UIAlertView localizedAlertWithTitle:@"savedreports.error.reportnotfound.title"
                                      message:@"savedreports.error.reportnotfound.msg"
                                     delegate:nil
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles:nil] show];
    } else {
        [self performSegueWithIdentifier:kJMShowSavedReportSegue sender:reportPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kJMShowSavedReportModifyControllerSegue sender:indexPath];
}

#pragma mark - Private

- (void)clearSavedReports
{
    self.reports = nil;
}

- (void)checkAvailabilityOfEditButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.reports.count > 0;
}

- (NSDate *)modificationDateForDirectory:(NSString *)directory
{
    NSDictionary *directoryAttributes = [self.fileManager attributesOfItemAtPath:directory error:nil];
    return [directoryAttributes objectForKey:NSFileModificationDate];
}

- (NSString *)formattedSize:(double)size
{
    size = size / 1024.0f;
    NSString *sizeUnit;

    if (size > 1000) {
        size = size / 1024.0f;
        sizeUnit = @" mb";
    } else {
        sizeUnit = @" kb";
    }

    return [NSString stringWithFormat:@"%.1f %@", size, sizeUnit];
}

@end
