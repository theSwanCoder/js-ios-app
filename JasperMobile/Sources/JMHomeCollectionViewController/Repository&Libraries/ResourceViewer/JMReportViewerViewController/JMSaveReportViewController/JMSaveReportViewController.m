/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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


#import "JMSaveReportViewController.h"
#import "JMSavedResources+Helpers.h"
#import "UITableViewCell+Additions.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "ALToastView.h"


NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMAttachmentPrefix = @"_";


@interface JMSaveReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;

@end


@implementation JMSaveReportViewController
objection_requires(@"resourceClient", @"reportClient")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize reportClient = _reportClient;

#pragma mark - Initialization
- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [JMCustomLocalizedString(@"savereport.title", nil) capitalizedString];
    self.reportName = self.resourceLookup.label;
    self.selectedReportFormat = [[JMUtils supportedFormatsForReportSaving] firstObject];

    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item"] style:UIBarButtonItemStyleBordered  target:self action:@selector(saveButtonTapped:)];
    [self.tableView setRowHeight:[JMUtils isIphone] ? 44.f : 50.f];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? [JMUtils supportedFormatsForReportSaving].count : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section ? JMCustomLocalizedString(@"savereport.format", nil) : JMCustomLocalizedString(@"savereport.name", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.errorString) {
        CGFloat maxWidth = self.tableView.frame.size.width - 40;
        CGSize maximumLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
        CGRect textRect = [self.errorString boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:[JMFont tableViewCellDetailErrorFont]}
                                                         context:nil];
        return tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = indexPath.section ? @"FormatSelectionCell" : @"ReportNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (indexPath.section) {
        if (indexPath.row) {
            [cell setTopSeparatorWithHeight:1.f color:tableView.separatorColor tableViewStyle:UITableViewStylePlain];
        }

        NSString *currentFormat = [[JMUtils supportedFormatsForReportSaving] objectAtIndex:indexPath.row];
        cell.textLabel.text = currentFormat;
        cell.accessoryType = [self.selectedReportFormat isEqualToString:currentFormat] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        UITextField *textField = (UITextField *) [cell.contentView viewWithTag:1];
        textField.text = self.reportName;
        textField.placeholder = JMCustomLocalizedString(@"savereport.name", nil);
        
        UILabel *errorLabel = (UILabel *) [cell.contentView viewWithTag:2];
        errorLabel.text = self.errorString;
        errorLabel.font = [JMFont tableViewCellDetailErrorFont];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedReportFormat = [[JMUtils supportedFormatsForReportSaving] objectAtIndex:indexPath.row];
    self.errorString = nil;
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.reportName = textField.text;
}

#pragma mark - Actions
- (void)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    NSString *fullReportDirectory = [JMSavedResources pathToReportDirectoryWithName:self.reportName format:self.selectedReportFormat];
    NSString *errorMessage = nil;
    BOOL isValidReportName = ([JMUtils validateReportName:self.reportName extension:self.selectedReportFormat errorMessage:&errorMessage] &&
                              [self createReportDirectory:fullReportDirectory errorMessage:&errorMessage]);
    
    self.errorString = errorMessage;
    [self.tableView reloadData];
    
    if (!self.errorString && isValidReportName) {
        // Clear any errors
        [self.tableView reloadData];
        
        NSMutableArray *parameters = [NSMutableArray array];
        for (JSInputControlDescriptor *inputControlDescriptor in self.inputControls) {
            JSReportParameter *reportParameter = [[JSReportParameter alloc] initWithName:inputControlDescriptor.uuid
                                                                                   value:inputControlDescriptor.selectedValues];
            [parameters addObject:reportParameter];
        }
        
        [JMCancelRequestPopup presentWithMessage:@"savereport.saving.status.title" restClient:self.reportClient cancelBlock:^{
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        }];
        
        JSRequestFinishedBlock checkErrorBlock = @weakself(^(JSOperationResult *result)) {
            if (result.isSuccessful) return;
            [self.reportClient cancelAllRequests];
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        }@weakselfend;
        
        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:@weakself(^(JSOperationResult *result)) {
            JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
            JSExportExecutionResponse *export = [response.exports objectAtIndex:0];
            NSString *requestId = response.requestId;
            
            NSString *fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", fullReportDirectory, kJMReportFilename, self.selectedReportFormat];
            [self.reportClient loadReportOutput:requestId exportOutput:export.uuid loadForSaving:YES path:fullReportPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:nil]];
            
            for (JSReportOutputResource *attachment in export.attachments) {
                NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", fullReportDirectory, kJMAttachmentPrefix, attachment.fileName];
                [self.reportClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath usingBlock:^(JSRequest *request) {
                    request.delegate = [JMRequestDelegate requestDelegateForFinishBlock:nil];
                    request.finishedBlock = checkErrorBlock;
                }];
            }
        } @weakselfend];

        [JMRequestDelegate setFinalBlock:@weakself(^(void)) {
            [self.navigationController popViewControllerAnimated:YES];
            [JMSavedResources addReport:self.resourceLookup withName:self.reportName format:self.selectedReportFormat];
            [ALToastView toastInView:self.delegate.view withText:JMCustomLocalizedString(@"savereport.saved", nil)];
        } @weakselfend];

        [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.selectedReportFormat interactive:NO freshData:YES saveDataSnapshot:NO
                             ignorePagination:NO transformerKey:nil pages:nil attachmentsPrefix:kJMAttachmentPrefix parameters:parameters usingBlock:^(JSRequest *request) {
                                 request.delegate = delegate;
                                 request.finishedBlock = checkErrorBlock;
                             }];
    }
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
