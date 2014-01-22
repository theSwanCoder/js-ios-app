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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *reports = [[self.fileManager contentsOfDirectoryAtPath:self.reportsDirectory error:nil] mutableCopy];
    [reports removeObject:@".DS_Store"];
    self.reports = reports;
    [self checkAvailabilityOfEditButton];
    [self.tableView reloadData];
}

#pragma mark - UIViewControllerEditing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self checkAvailabilityOfEditButton];
}

- (void)didReceiveMemoryWarning
{
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString * const cellIdentifier = @"ReportCell";
    JMReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *report = [self.reports objectAtIndex:indexPath.row];
    NSString *reportDirectory = [self.reportsDirectory stringByAppendingPathComponent:report];
    NSDictionary *directoryAttributes = [self.fileManager attributesOfItemAtPath:reportDirectory error:nil];
    NSArray *files = [self.fileManager subpathsOfDirectoryAtPath:reportDirectory error:nil];
    NSDate *creationDate = [directoryAttributes objectForKey:NSFileCreationDate];

    unsigned long long size = 0;
    NSString *extension;

    for (NSString *file in files) {
        if (!extension) {
            NSRange dotRange = [file rangeOfString:@"."];
            if (dotRange.location != NSNotFound) {
                extension = [file substringWithRange:NSMakeRange(dotRange.location, file.length)];
            }
        }

        NSString *filePath = [reportDirectory stringByAppendingPathComponent:file];
        NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:filePath error:nil];
        size += fileAttributes.fileSize;
    }
    
    size /= 1024.0f;
    NSString *sizeUnit;
    
    if (size > 1000) {
        size /= 1024.0f;
        sizeUnit = @" mb";
    } else {
        sizeUnit = @" kb";
    }
    
//    cell.textLabel.text = report;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@; size: %.1f %@", creationDate, size, sizeUnit];
    
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

#pragma mark - Private

- (void)checkAvailabilityOfEditButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.reports.count > 0;
}

@end
