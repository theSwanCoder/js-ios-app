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
#import "UIAlertView+LocalizedAlert.h"

static NSString * const kJMShowSavedReportSegue = @"ShowSavedReport";

@interface JMReportTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *reportName;
@property (nonatomic, weak) IBOutlet UILabel *creationDate;
@property (nonatomic, weak) IBOutlet UILabel *size;
@end

@implementation JMReportTableViewCell
@end

@interface JMSavedReportsTableViewController()
@property (nonatomic, strong) NSString *reportsDirectory;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation JMSavedReportsTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.reportsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:kJMReportsDirectory];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.fileManager = [NSFileManager defaultManager];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // TODO: make notification instead of each time reports fetching
    self.reports = [[self.fileManager contentsOfDirectoryAtPath:self.reportsDirectory error:nil] mutableCopy];
    [self.reports removeObject:@".DS_Store"];

    [self checkAvailabilityOfEditButton];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setReportPath:sender];
}

#pragma mark - UIViewControllerEditing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self checkAvailabilityOfEditButton];
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
    NSString *reportDirectory = [self.reportsDirectory stringByAppendingPathComponent:report];
    NSDictionary *directoryAttributes = [self.fileManager attributesOfItemAtPath:reportDirectory error:nil];
    NSArray *files = [self.fileManager subpathsOfDirectoryAtPath:reportDirectory error:nil];
    NSDate *creationDate = [directoryAttributes objectForKey:NSFileCreationDate];
    double size = 0;
    
    for (NSString *file in files) {
        NSString *filePath = [reportDirectory stringByAppendingPathComponent:file];
        NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:filePath error:nil];
        size += fileAttributes.fileSize;
    }

    // Table view cell has the same identifier as a file extension
    JMReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:report.pathExtension];
    cell.reportName.text = [report stringByDeletingPathExtension];
    cell.creationDate.text = [self.dateFormatter stringFromDate:creationDate];
    cell.size.text = [self formattedSize:size];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *report = [self.reports objectAtIndex:indexPath.row];
        NSString *reportDirectory = [self.reportsDirectory stringByAppendingPathComponent:report];
        [self.fileManager removeItemAtPath:reportDirectory error:nil];
        [self.reports removeObject:report];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMReportTableViewCell *cell = (JMReportTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    NSString *reportPath = [self.reportsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@/report.%@", cell.reportName.text, cell.reuseIdentifier, cell.reuseIdentifier]];
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

#pragma mark - Private

- (void)checkAvailabilityOfEditButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.reports.count > 0;
}

- (NSString *)formattedSize:(double)size
{
    if (size == 0) {
        return NSLocalizedString(@"savedreports.folder.empty", nil);
    }

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
