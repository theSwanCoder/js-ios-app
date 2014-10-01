//
//  JMSavedResourceViewerViewController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSavedResourceViewerViewController.h"
#import "JMSavedResources+Helpers.h"
#import "UIAlertView+LocalizedAlert.h"

@interface JMSavedResourceViewerViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@property (nonatomic, strong) NSString *changedReportName;

@end

@implementation JMSavedResourceViewerViewController
@synthesize changedReportName;

- (JMSavedResources *)savedReports
{
    if (!_savedReports) {
        _savedReports = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
    }
    return _savedReports;
}

- (void)runReportExecution
{
    NSString *fullReportPath = [JMUtils documentsReportDirectoryPath];
    for (NSMutableString *name in @[self.savedReports.label, kJMReportFilename]) {
        fullReportPath = [fullReportPath stringByAppendingPathComponent: [name stringByAppendingPathExtension:self.savedReports.format]];
    }
    
    NSURL *url = [NSURL fileURLWithPath:fullReportPath];
    self.request = [NSURLRequest requestWithURL:url];
}

- (JMResourceViewerAction)availableAction
{
    return [super availableAction] | JMResourceViewerAction_Rename | JMResourceViewerAction_Delete;
}

#pragma mark - JMResourceViewerActionsViewDelegate
- (void)actionsView:(JMResourceViewerActionsView *)view didSelectAction:(JMResourceViewerAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMResourceViewerAction_Rename) {
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(@"modifysavedreport.title", nil)
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)
                                           otherButtonTitles:JMCustomLocalizedString(@"dialog.button.ok", nil), nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = JMCustomLocalizedString(@"modifysavedreport.reportname", nil);
        textField.delegate = self;
        textField.text = [self.savedReports.label copy];
        
        [alertView show];
    } else if(action == JMResourceViewerAction_Delete) {
        [JMSavedResources removeReport:self.resourceLookup];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *errorMessage = @"";
    UITextField *textField = [alertView textFieldAtIndex:0];
    BOOL validData = [JMUtils validateReportName:textField.text extension:nil errorMessage:&errorMessage];
    alertView.message = errorMessage;
    
    return validData;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSString *newName = [alertView textFieldAtIndex:0].text;
        [self.savedReports renameReportTo:newName];
        self.title = newName;
    }
}

@end
