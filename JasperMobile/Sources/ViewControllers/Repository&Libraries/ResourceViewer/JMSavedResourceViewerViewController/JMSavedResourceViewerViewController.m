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


#import "JMSavedResourceViewerViewController.h"
#import "JMSavedResources+Helpers.h"

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

- (void)startResourceViewing
{
    NSString *fullReportPath = [JMSavedResources pathToReportWithName:self.savedReports.label format:self.savedReports.format];

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    self.isResourceLoaded = NO;

    if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
        NSString* content = [NSString stringWithContentsOfFile:fullReportPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        NSURL *url = [NSURL fileURLWithPath:fullReportPath];
        [self.webView loadHTMLString:content baseURL:url];
    } else {
        NSURL *url = [NSURL fileURLWithPath:fullReportPath];
        self.resourceRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:self.resourceRequest];
    }
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return ([super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete);
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Rename) {
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(@"savedreport.viewer.modify.title", nil)
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)
                                           otherButtonTitles:JMCustomLocalizedString(@"dialog.button.ok", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = JMCustomLocalizedString(@"savedreport.viewer.modify.reportname", nil);
        textField.delegate = self;
        textField.text = [self.savedReports.label copy];
        
        alertView.tag = action;
        [alertView show];
    } else if(action == JMMenuActionsViewAction_Delete) {
        UIAlertView *alertView  = [UIAlertView localizedAlertWithTitle:@"dialod.title.confirmation"
                                                               message:@"savedreport.viewer.delete.confirmation.message"
                                                              delegate:self
                                                     cancelButtonTitle:@"dialog.button.cancel"
                                                     otherButtonTitles:@"dialog.button.ok", nil];
        alertView.tag = action;
        [alertView show];
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
    BOOL validData = [JMUtils validateReportName:textField.text extension:self.savedReports.format errorMessage:&errorMessage];
    if (validData && ![JMSavedResources isAvailableReportName:textField.text format:self.savedReports.format]) {
        validData = NO;
        errorMessage = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.notunique", nil);
    }
    alertView.message = errorMessage;
    
    return validData;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        if (alertView.tag == JMMenuActionsViewAction_Rename) {
            NSString *newName = [alertView textFieldAtIndex:0].text;
            if ([self.savedReports renameReportTo:newName]) {
                self.title = newName;
                self.resourceLookup = [self.savedReports wrapperFromSavedReports];
            }
        } else if (alertView.tag == JMMenuActionsViewAction_Delete) {
            BOOL shouldCloseViewer = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(resourceViewer:shouldCloseViewerAfterDeletingResource:)]) {
                shouldCloseViewer = [self.delegate resourceViewer:self shouldCloseViewerAfterDeletingResource:self.resourceLookup];
            }
            [self cancelResourceViewingAndExit:shouldCloseViewer];
            [self.savedReports removeReport];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(resourceViewer:didDeleteResource:)]) {
                [self.delegate resourceViewer:self didDeleteResource:self.resourceLookup];
            }
        }
    }
}

@end
