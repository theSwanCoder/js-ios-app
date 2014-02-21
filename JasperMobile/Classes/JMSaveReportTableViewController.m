/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMSaveReportTableViewController.m
//  Jaspersoft Corporation
//

#import "JMSaveReportTableViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMRequestDelegate.h"
#import "JMRotationBase.h"
#import "JMUtils.h"
#import "UITableViewCell+SetSeparators.h"
#import "UITableViewController+CellRelativeHeight.h"
#import "ALToastView.h"
#import <Objection-iOS/Objection.h>

#define kJMReportNameSection 0
#define kJMReportFormatSection 1
#define kJMSaveReportSection 2

__weak static UIColor *separatorColor;
static CGFloat const separatorHeight = 1.0f;

static NSString * const kJMAttachmentPrefix = @"_";

@interface JMSaveReportTableViewController ()
@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSArray *reportFormats;
@property (nonatomic, strong) NSDictionary *cellsIdentifiers;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, weak) JSConstants *constants;
@property (nonatomic, assign) CGRect baseErrorLabelFrame;
@end

@implementation JMSaveReportTableViewController
objection_requires(@"reportClient", @"constants")
inject_default_rotation()

@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;

#pragma mark - Accessors

- (NSDictionary *)cellsIdentifiers
{
    if (!_cellsIdentifiers) {
        _cellsIdentifiers = @{
            @kJMReportNameSection : @"ReportNameCell",
            @kJMReportFormatSection : @"ReportFormatCell",
            @kJMSaveReportSection : @"SaveReportCell"
        };
    }

    return _cellsIdentifiers;
}

- (NSArray *)reportFormats
{
    if (!_reportFormats) {
        _reportFormats = @[
            self.constants.CONTENT_TYPE_HTML,
            self.constants.CONTENT_TYPE_PDF
        ];
    }

    return _reportFormats;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.reportName = self.resourceLookup.label;
    self.selectedReportFormat = [self.reportFormats firstObject];
    separatorColor = self.tableView.separatorColor;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kJMReportFormatSection) {
        return self.reportFormats.count;
    }

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kJMReportNameSection) {
        return JMCustomLocalizedString(@"savereport.name", nil);
    } else if (section == kJMReportFormatSection) {
        return JMCustomLocalizedString(@"savereport.format", nil);
    }

    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kJMReportNameSection) {
        CGFloat height = 72.0f;

        if (self.errorMessage.length) {
            UIFont *font = [UIFont systemFontOfSize:14.0f];
            CGSize errorMessageSize = [self.errorMessage sizeWithFont:font constrainedToSize:CGSizeMake(self.baseErrorLabelFrame.size.width, CGFLOAT_MAX)
                                                        lineBreakMode:NSLineBreakByWordWrapping];
            height += errorMessageSize.height;
        }

        return height;

    }
    return self.defaultHeightForTableViewCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self.cellsIdentifiers objectForKey:[NSNumber numberWithInt:indexPath.section]];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (indexPath.section == kJMReportNameSection) {
        UITextField *textField = (UITextField *) [cell viewWithTag:1];
        UILabel *errorLabel = (UILabel *) [cell viewWithTag:2];

        textField.text = self.reportName;
        textField.delegate = self;
        textField.placeholder = JMCustomLocalizedString(@"savereport.name", nil);

        if (!textField.leftView) {
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0f, 0)];
            textField.leftView = leftView;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.background = [textField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
        }

        if (CGRectIsEmpty(self.baseErrorLabelFrame)) {
            self.baseErrorLabelFrame = errorLabel.frame;
        }

        if (self.errorMessage.length) {
            errorLabel.hidden = NO;
            errorLabel.numberOfLines = 0;
            errorLabel.text = self.errorMessage;
            errorLabel.frame = self.baseErrorLabelFrame;
            [errorLabel sizeToFit];
        } else {
            errorLabel.hidden = YES;
        }
    } else if (indexPath.section == kJMReportFormatSection) {
        NSString *reportFormat = [self.reportFormats objectAtIndex:indexPath.row];
        cell.textLabel.text = [reportFormat uppercaseString];
        if ([self.selectedReportFormat isEqualToString:reportFormat]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundColor = [UIColor clearColor];

        UIButton *run = (UIButton *) [cell viewWithTag:1];
        run.titleLabel.text = JMCustomLocalizedString(@"dialog.button.save", nil);
        [JMUtils setBackgroundImagesForButton:run
                                    imageName:@"blue_button.png"
                         highlightedImageName:@"blue_button_highlighted.png"
                                   edgesInset:18.0f];
    }

    if (indexPath.section != kJMSaveReportSection) {
        [cell setTopSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
        // Check if this is the last cell in the section
        if ([self.tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row) {
            [cell setBottomSeparatorWithHeight:separatorHeight color:separatorColor tableViewStyle:self.tableView.style];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != kJMReportFormatSection) return;
    self.selectedReportFormat = [self.reportFormats objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)saveReport:(id)sender
{
    self.errorMessage = nil;

    NSString *reportDirectory = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:[self.reportName stringByAppendingPathExtension:self.selectedReportFormat]];
    NSString *errorMessage;

    if (![JMUtils validateReportName:self.reportName extension:self.selectedReportFormat errorMessage:&errorMessage] ||
        ![self createReportDirectory:reportDirectory errorMessage:&errorMessage]) {
        self.errorMessage = errorMessage;
        [self.tableView reloadData];
        return;
    }

    // Clear any errors
    [self.tableView reloadData];

    __weak JMSaveReportTableViewController *reportSaver = self;

    [JMCancelRequestPopup presentInViewController:self message:@"status.saving" restClient:self.reportClient cancelBlock:^{
        [[NSFileManager defaultManager] removeItemAtPath:reportDirectory error:nil];
    }];
    
    JSRequestFinishedBlock checkErrorBlock = ^(JSOperationResult *result) {
        if (result.isSuccessful) return;
        [reportSaver.reportClient cancelAllRequests];
        [[NSFileManager defaultManager] removeItemAtPath:reportDirectory error:nil];
    };

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];
        NSString *requestId = response.requestId;

        NSString *fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", reportDirectory, kJMReportFilename, self.selectedReportFormat];
        [reportSaver.reportClient saveReportOutput:requestId exportOutput:export.uuid path:fullReportPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:nil]];

        for (JSReportOutputResource *attachment in export.attachments) {
            NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", reportDirectory, kJMAttachmentPrefix, attachment.fileName];
            [reportSaver.reportClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath usingBlock:^(JSRequest *request) {
                request.delegate = [JMRequestDelegate requestDelegateForFinishBlock:nil];
                request.finishedBlock = checkErrorBlock;
            }];
        }
    }];

    [JMRequestDelegate setFinalBlock:^{
        [reportSaver.navigationController popViewControllerAnimated:YES];
        [ALToastView toastInView:reportSaver.delegate.view withText:JMCustomLocalizedString(@"savereport.saved", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMClearSavedReportsListNotification object:nil];
    }];

    [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.selectedReportFormat interactive:NO freshData:YES saveDataSnapshot:NO
                         ignorePagination:NO transformerKey:nil pages:nil attachmentsPrefix:kJMAttachmentPrefix parameters:self.parameters usingBlock:^(JSRequest *request) {
        request.delegate = delegate;
        request.finishedBlock = checkErrorBlock;
    }];
}

- (IBAction)reportNameChanged:(id)sender
{
    self.reportName = [sender text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Private

- (BOOL)createReportDirectory:(NSString *)reportDirectory errorMessage:(NSString **)errorMessage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    [fileManager createDirectoryAtPath:reportDirectory
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];

    if (error) *errorMessage = error.localizedDescription;
    return [*errorMessage length] == 0;
}

@end
