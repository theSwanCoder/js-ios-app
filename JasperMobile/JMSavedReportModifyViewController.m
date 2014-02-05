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
//  JMSavedReportModifyViewController.m
//  Jaspersoft Corporation
//

#import "JMSavedReportModifyViewController.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@interface JMSavedReportModifyViewController()
@property (nonatomic, weak) IBOutlet UILabel *reportNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@property (nonatomic, weak) IBOutlet UITextField *reportNameTextField;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@end

@implementation JMSavedReportModifyViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = JMCustomLocalizedString(@"savedreportmodify.title", nil);
    self.reportNameLabel.text = JMCustomLocalizedString(@"savedreportmodify.reportname", nil);
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0f, 0)];
    self.reportNameTextField.leftView = leftView;
    self.reportNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.reportNameTextField.background = [self.reportNameTextField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
    self.reportNameTextField.text = [self.reportName stringByDeletingPathExtension];
    self.reportNameTextField.delegate = self;
    self.saveButton.titleLabel.text = JMCustomLocalizedString(@"dialog.button.save", nil);
    [JMUtils setBackgroundImagesForButton:self.saveButton
                                imageName:@"blue_button.png"
                     highlightedImageName:@"blue_button_highlighted.png"
                               edgesInset:18.0f];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        NSArray *viewsToUpdate = @[self.reportNameLabel, self.reportNameTextField, self.errorLabel, self.saveButton];
        for (UIView *view in viewsToUpdate) {
            CGRect frame = view.frame;
            frame.origin.y -= 70;
            view.frame = frame;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Actions

- (IBAction)modify:(id)sender
{
    NSString *reportName = self.reportNameTextField.text;
    NSString *reportExtension = [self.reportName pathExtension];
    NSString *errorMessage;
    
    if (![reportName isEqualToString:[self.reportName stringByDeletingPathExtension]] &&
        !([JMUtils validateReportName:reportName extension:reportExtension errorMessage:&errorMessage] &&
          [self renameReportDirectoryTo:reportName extension:reportExtension errorMessage:&errorMessage])) {
        self.errorLabel.text = errorMessage;
        self.errorLabel.hidden = NO;
        CGSize size = CGSizeMake(self.errorLabel.frame.size.width, CGFLOAT_MAX);
        CGSize errorMessageSize = [errorMessage sizeWithFont:self.errorLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        self.errorLabel.frame = CGRectMake(self.errorLabel.frame.origin.x, self.errorLabel.frame.origin.y, self.errorLabel.frame.size.width, errorMessageSize.height);

        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kJMClearSavedReportsListNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (BOOL)renameReportDirectoryTo:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage
{
    if (extension) {
        reportName = [reportName stringByAppendingPathExtension:extension];
    }

    NSString *oldPath = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:self.reportName];
    NSString *newPath = [[JMUtils documentsReportDirectoryPath] stringByAppendingPathComponent:reportName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    [fileManager moveItemAtPath:oldPath toPath:newPath error:&error];
    *errorMessage = error.localizedDescription;

    NSDictionary *attributesToUpdate = @{
        NSFileModificationDate : [NSDate date]
    };
    [fileManager setAttributes:attributesToUpdate ofItemAtPath:newPath error:&error];
    *errorMessage = [*errorMessage stringByAppendingFormat:@".%@", error.localizedDescription];

    if (error) {
        *errorMessage = error.localizedDescription;
    }

    return [*errorMessage length] == 0;
}

@end