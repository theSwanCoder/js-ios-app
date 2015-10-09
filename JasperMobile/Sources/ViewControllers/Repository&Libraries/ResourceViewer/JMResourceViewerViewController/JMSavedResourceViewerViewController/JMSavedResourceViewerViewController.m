/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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

@interface JMSavedResourceViewerViewController () <UITextFieldDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@property (nonatomic, strong) NSString *changedReportName;
@property (nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation JMSavedResourceViewerViewController
@synthesize changedReportName;

#pragma mark - Handle Memory Warnings
- (void)didReceiveMemoryWarning
{
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
#warning WHY ONLY FOR SAVED REPORT VIEWER WE HANDLE MEMORY WARNINGS???
    NSString *errorTitle = JMCustomLocalizedString(@"dialod.title.error", nil);
    NSString *errorMessage = JMCustomLocalizedString(@"savedreport.viewer.show.resource.error.message", nil);
    NSError *error = [NSError errorWithDomain:errorTitle code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
    __weak typeof(self) weakSelf = self;
    [JMUtils presentAlertControllerWithError:error completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf cancelResourceViewingAndExit:YES];
        }
    }];
    
    [super didReceiveMemoryWarning];
}

- (void)cancelResourceViewingAndExit:(BOOL)exit
{
    [self.documentController dismissMenuAnimated:YES];
    [super cancelResourceViewingAndExit:exit];
}

- (JMSavedResources *)savedReports
{
    if (!_savedReports) {
        _savedReports = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
    }
    
    return _savedReports;
}

- (void)startResourceViewing
{
    NSString *fullReportPath = [JMSavedResources absolutePathToSavedReport:self.savedReports];

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    self.isResourceLoaded = NO;

    NSURL *url = [NSURL fileURLWithPath:fullReportPath];
    self.resourceRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:self.resourceRequest];

    // Crashlytics
    NSString *resourcesType;
    if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_HTML]) {
        resourcesType = @"Saved Item (HTML)";
    } else if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_PDF]) {
        resourcesType = @"Saved Item (PDF)";
    } else if ([self.savedReports.format isEqualToString:[JSConstants sharedInstance].CONTENT_TYPE_XLS]) {
        resourcesType = @"Saved Item (XLS)";
    }

    [Answers logCustomEventWithName:@"User opened resource"
                   customAttributes:@{
                           @"Resource's Type" : resourcesType
                   }];
}

- (JMMenuActionsViewAction)availableActionForResource:(JSResourceLookup *)resource
{
    return ([super availableActionForResource:[self resourceLookup]] | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete | JMMenuActionsViewAction_OpenIn);
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
        UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod.title.confirmation"
                                                                                          message:@"savedreport.viewer.delete.confirmation.message"
                                                                                cancelButtonTitle:@"dialog.button.cancel"
                                                                          cancelCompletionHandler:nil];
        __weak typeof(self) weakSelf = self;
        [alertController addActionWithLocalizedTitle:@"dialog.button.ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                BOOL shouldCloseViewer = YES;
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(resourceViewer:shouldCloseViewerAfterDeletingResource:)]) {
                    shouldCloseViewer = [strongSelf.delegate resourceViewer:strongSelf shouldCloseViewerAfterDeletingResource:strongSelf.resourceLookup];
                }
                [strongSelf cancelResourceViewingAndExit:shouldCloseViewer];
                [strongSelf.savedReports removeReport];
                
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(resourceViewer:didDeleteResource:)]) {
                    [strongSelf.delegate resourceViewer:strongSelf didDeleteResource:strongSelf.resourceLookup];
                }
            }
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (action == JMMenuActionsViewAction_OpenIn) {
        self.documentController = [self setupDocumentControllerWithURL:self.resourceRequest.URL
                                                                             usingDelegate:self];

        BOOL canOpen = [self.documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        if (!canOpen) {
            NSString *errorTitle = JMCustomLocalizedString(@"dialod.title.error", nil);
            NSString *errorMessage = JMCustomLocalizedString(@"error.openIn.message", nil);
            NSError *error = [NSError errorWithDomain:errorTitle code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            [JMUtils presentAlertControllerWithError:error completion:nil];
        }
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
    BOOL validData = [JMUtils validateReportName:textField.text errorMessage:&errorMessage];
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
        }
    }
}


#pragma mark - Helpers
- (UIDocumentInteractionController *) setupDocumentControllerWithURL: (NSURL *) fileURL
                                                       usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

@end
