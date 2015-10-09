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


//
//  JMSavedItemsInfoViewController.m
//  TIBCO JasperMobile
//

#import "JMSavedItemsInfoViewController.h"
#import "JSResourceLookup+Helpers.h"
#import "JMSavedResources+Helpers.h"
#import "JMSavedResourceViewerViewController.h"
#import "JMFavorites.h"
#import "JMFavorites+Helpers.h"

@interface JMSavedItemsInfoViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) JMSavedResources *savedReports;
@end

@implementation JMSavedItemsInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetResourceProperties) name:kJMSavedResourcesDidChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (JMSavedResources *)savedReports
{
    if (!_savedReports) {
        _savedReports = [JMSavedResources savedReportsFromResourceLookup:self.resourceLookup];
    }
    return _savedReports;
}

#pragma mark - Overloaded methods
- (void)resetResourceProperties
{
    self.resourceLookup = [self.savedReports wrapperFromSavedReports];
    [super resetResourceProperties];
}

- (NSArray *)resourceProperties
{
    NSMutableArray *properties = [[super resourceProperties] mutableCopy];
    [properties addObject:@{
                            kJMTitleKey : @"format",
                            kJMValueKey : self.savedReports.format ?: @""
                            }];
    return properties;
}

- (JMMenuActionsViewAction)availableAction
{
    return ([super availableAction] | JMMenuActionsViewAction_Run | JMMenuActionsViewAction_Rename | JMMenuActionsViewAction_Delete);
}

- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    [super actionsView:view didSelectAction:action];
    if (action == JMMenuActionsViewAction_Run) {
        [self runReport];
    }else if (action == JMMenuActionsViewAction_Rename) {
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:JMCustomLocalizedString(@"savedreport.viewer.modify.title", nil)
                                                             message:nil
                                                            delegate:self
                                                   cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil)
                                                   otherButtonTitles:JMCustomLocalizedString(@"dialog.button.ok", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = JMCustomLocalizedString(@"savedreport.viewer.modify.reportname", nil);
        textField.delegate = self;
        textField.text = [self.resourceLookup.label copy];
        
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

- (void)runReport
{
    JMSavedResourceViewerViewController *nextVC = (JMSavedResourceViewerViewController *) [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[self.resourceLookup resourceViewerVCIdentifier]];
    nextVC.resourceLookup = self.resourceLookup;
    nextVC.delegate = self;
    
    if (nextVC) {
        [self.navigationController pushViewController:nextVC animated:YES];
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

                BOOL isResourceFavorite = [JMFavorites isResourceInFavorites:self.resourceLookup];
                JSResourceLookup *newSavedReport = [self.savedReports wrapperFromSavedReports];
                if (isResourceFavorite) {
                    [JMFavorites removeFromFavorites:self.resourceLookup];
                    [JMFavorites addToFavorites:newSavedReport];
                }
                self.resourceLookup = newSavedReport;
            }
        } else if (alertView.tag == JMMenuActionsViewAction_Delete) {
            [self.savedReports removeReport];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - JMBaseResourceViewerVCDelegate
- (void)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer didDeleteResource:(JSResourceLookup *)resourceLookup
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *previousViewController = viewControllers[[viewControllers indexOfObject:self] - 1];
    [self.navigationController popToViewController:previousViewController animated:YES];
}

- (BOOL)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer shouldCloseViewerAfterDeletingResource:(JSResourceLookup *)resourceLookup
{
    return NO;
}

@end
