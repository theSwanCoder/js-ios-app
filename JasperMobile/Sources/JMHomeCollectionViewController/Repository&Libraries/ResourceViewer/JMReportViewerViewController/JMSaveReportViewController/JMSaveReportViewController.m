//
//  JMSaveReportViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSaveReportViewController.h"
#import <Objection-iOS/Objection.h>
#import "JMSavedResources+Helpers.h"
#import "JMCancelRequestPopup.h"
#import "JMRequestDelegate.h"
#import "ALToastView.h"


NSString * const kJMSaveReportViewControllerSegue = @"SaveReportViewControllerSegue";
NSString * const kJMAttachmentPrefix = @"_";


@interface JMSaveReportViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *selectedReportFormat;
@property (nonatomic, strong) NSArray *reportFormats;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, strong) NSString *errorString;
@property (nonatomic, weak) JSConstants *constants;

@end


@implementation JMSaveReportViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")

@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize reportClient = _reportClient;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [JMCustomLocalizedString(@"savereport.title", nil) capitalizedString];
    self.reportName = self.resourceLookup.label;
    self.selectedReportFormat = [self.reportFormats firstObject];

    self.view.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.backgroundColor = kJMDetailViewLightBackgroundColor;
    self.tableView.layer.cornerRadius = 4;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"apply_item.png"] style:UIBarButtonItemStyleBordered  target:self action:@selector(saveButtonTapped:)];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? self.reportFormats.count : 1;
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
        return self.tableView.rowHeight + ceil(textRect.size.height);
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = indexPath.section ? @"FormatSelectionCell" : @"ReportNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (indexPath.section) {
        NSString *currentFormat = [self.reportFormats objectAtIndex:indexPath.row];
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
    if (indexPath.section) {
        self.selectedReportFormat = [self.reportFormats objectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
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
    NSString *fullReportDirectory = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:[self.reportName stringByAppendingPathExtension:self.selectedReportFormat]];
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
        
        __weak typeof(self) weakSelf = self;
        [JMCancelRequestPopup presentInViewController:self message:@"savereport.saving.status.title" restClient:self.reportClient cancelBlock:^{
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        }];
        
        JSRequestFinishedBlock checkErrorBlock = ^(JSOperationResult *result) {
            if (result.isSuccessful) return;
            [weakSelf.reportClient cancelAllRequests];
            [[NSFileManager defaultManager] removeItemAtPath:fullReportDirectory error:nil];
        };
        
        JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
            JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
            JSExportExecution *export = [response.exports objectAtIndex:0];
            NSString *requestId = response.requestId;
            
            NSString *fullReportPath = [NSString stringWithFormat:@"%@/%@.%@", fullReportDirectory, kJMReportFilename, self.selectedReportFormat];
            [weakSelf.reportClient saveReportOutput:requestId exportOutput:export.uuid path:fullReportPath delegate:[JMRequestDelegate requestDelegateForFinishBlock:nil]];
            
            for (JSReportOutputResource *attachment in export.attachments) {
                NSString *attachmentPath = [NSString stringWithFormat:@"%@/%@%@", fullReportDirectory, kJMAttachmentPrefix, attachment.fileName];
                [weakSelf.reportClient saveReportAttachment:requestId exportOutput:export.uuid attachmentName:attachment.fileName path:attachmentPath usingBlock:^(JSRequest *request) {
                    request.delegate = [JMRequestDelegate requestDelegateForFinishBlock:nil];
                    request.finishedBlock = checkErrorBlock;
                }];
            }
        }];

        [JMRequestDelegate setFinalBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
            [JMSavedResources addReport:weakSelf.resourceLookup withName:weakSelf.reportName formar:self.selectedReportFormat];
            [ALToastView toastInView:weakSelf.delegate.view withText:JMCustomLocalizedString(@"savereport.saved", nil)];
            [[NSNotificationCenter defaultCenter] postNotificationName:kJMClearSavedReportsListNotification object:nil];
        }];

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
