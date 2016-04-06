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


//
//  JMSavedItemsInfoViewController.m
//  TIBCO JasperMobile
//

#import "JMSavedItemsInfoViewController.h"
#import "JMSavedResources+Helpers.h"
#import "JMSavedResourceViewerViewController.h"
#import "JMFavorites.h"
#import "JMFavorites+Helpers.h"
#import "JMResource.h"

@interface JMSavedItemsInfoViewController () <UITextFieldDelegate>
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
        _savedReports = [JMSavedResources savedReportsFromResource:self.resource];
    }
    return _savedReports;
}

#pragma mark - Accessibility
- (NSString *)accessibilityIdentifier
{
    return @"JMRSavedItemInfoViewAccessibilityId";
}

#pragma mark - Overloaded methods
- (void)resetResourceProperties
{
    self.resource = [self.savedReports wrapperFromSavedReports];
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
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertTextDialogueControllerWithLocalizedTitle:@"savedreport_viewer_modify_title"
                                                                                                      message:nil
                                                                                textFieldConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                                                    __strong typeof (self) strongSelf = weakSelf;
                                                                                    textField.placeholder = JMCustomLocalizedString(@"savedreport_viewer_modify_reportname", nil);
                                                                                    textField.text = [strongSelf.resourceLookup.label copy];
                                                                                } textValidationHandler:^NSString * _Nonnull(NSString * _Nullable text) {
                                                                                    NSString *errorMessage = nil;
                                                                                    __strong typeof (self) strongSelf = weakSelf;
                                                                                    if (strongSelf) {
                                                                                        [JMUtils validateReportName:text errorMessage:&errorMessage];
                                                                                        if (!errorMessage && ![JMSavedResources isAvailableReportName:text format:strongSelf.savedReports.format]) {
                                                                                            errorMessage = JMCustomLocalizedString(@"report_viewer_save_name_errmsg_notunique", nil);
                                                                                        }
                                                                                    }
                                                                                    return errorMessage;
                                                                                } textEditCompletionHandler:^(NSString * _Nullable text) {
                                                                                    __strong typeof(self) strongSelf = weakSelf;
                                                                                    if ([strongSelf.savedReports renameReportTo:text]) {
                                                                                        [strongSelf resetResourceProperties];
                                                                                    }
                                                                                }];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if(action == JMMenuActionsViewAction_Delete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:@"dialod_title_confirmation"
                                                                                          message:@"savedreport_viewer_delete_confirmation_message"
                                                                                cancelButtonTitle:@"dialog_button_cancel"
                                                                          cancelCompletionHandler:nil];
        
        __weak typeof(self) weakSelf = self;
        [alertController addActionWithLocalizedTitle:@"dialog_button_ok" style:UIAlertActionStyleDefault handler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.savedReports removeReport];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)runReport
{
    JMSavedResourceViewerViewController *nextVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:[self.resource resourceViewerVCIdentifier]];
    [nextVC setResource:self.resource];
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

#pragma mark - JMBaseResourceViewerVCDelegate
- (void)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer didDeleteResource:(JMResource *)resourceLookup
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *previousViewController = viewControllers[[viewControllers indexOfObject:self] - 1];
    [self.navigationController popToViewController:previousViewController animated:YES];
}

- (BOOL)resourceViewer:(JMBaseResourceViewerVC *)resourceViewer shouldCloseViewerAfterDeletingResource:(JMResource *)resourceLookup
{
    return NO;
}

@end
