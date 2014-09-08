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
//  JMSavedReportModifyPopup.m
//  Jaspersoft Corporation
//

#import "JMSavedReportModifyPopup.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import "UIViewController+MJPopupViewController.h"

@interface JMUILineView : UIView
@end
@implementation JMUILineView

// Mimics UITableView iOS7 default line separator
// Thanks to danypata for the solution ( http://stackoverflow.com/a/20091771 )
- (void)layoutSubviews {
    [super layoutSubviews];

    if (![self respondsToSelector:@selector(constraints)]) return;

    CGFloat scale = [UIScreen mainScreen].scale;
    if (!self.constraints.count) {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;

        if (width == 1) {
            width /= scale;
        }
        if (height == 0) {
            height = 1 / scale;
        }
        if (height == 1) {
            height /= scale;
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    } else {
        for (NSLayoutConstraint *constraint in self.constraints) {
            if ((constraint.firstAttribute == NSLayoutAttributeWidth ||
                    constraint.firstAttribute == NSLayoutAttributeHeight) && constraint.constant == 1) {
                constraint.constant /= scale;
            }
        }
    }
}

@end

@interface JMSavedReportModifyPopup ()
@property (nonatomic, weak) IBOutlet UIView *topButtonsSeparator;
@property (nonatomic, weak) IBOutlet UIView *middleButtonsSeparator;
@property (nonatomic, weak) IBOutlet UITextField *reportNameTextField;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UILabel *reportNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@property (nonatomic, weak) UIViewController <JMSavedReportModifyPopupDelegate> *delegate;
@property (nonatomic, strong) NSString *reportName;
@property (nonatomic, assign) CGFloat baseHeight;
@property (nonatomic, assign) CGRect errorLabelBaseFrame;
@end

@implementation JMSavedReportModifyPopup

+ (void)presentInViewController:(UIViewController <JMSavedReportModifyPopupDelegate> *)viewController fullReportName:(NSString *)fullReportName
{
    JMSavedReportModifyPopup *instance = [[JMSavedReportModifyPopup alloc] initWithNibName:@"JMSavedReportModifyPopup" bundle:nil];
    instance.delegate = viewController;
    instance.reportName = fullReportName;
    [viewController presentPopupViewController:instance animationType:MJPopupViewAnimationFade];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.cornerRadius = 10.0f;
    self.baseHeight = self.view.frame.size.height;

    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0f, 0)];
    self.reportNameTextField.leftView = leftView;
    self.reportNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.reportNameTextField.background = [self.reportNameTextField.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10.0f, 0, 10.0f)];
    self.reportNameTextField.text = [self.reportName stringByDeletingPathExtension];
    self.reportNameTextField.placeholder = JMCustomLocalizedString(@"modifysavedreport.reportname", nil);
    self.reportNameTextField.delegate = self;
    self.saveButton.titleLabel.text = JMCustomLocalizedString(@"dialog.button.ok", nil);
    self.reportNameLabel.text = JMCustomLocalizedString(@"modifysavedreport.title", nil);
    self.errorLabelBaseFrame = self.errorLabel.frame;
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
            
            self.errorLabel.numberOfLines = 0;
            self.errorLabel.text = errorMessage;
            self.errorLabel.hidden = NO;
            // Restore base frame. Without this sizeToFit method doesn't work properly
            self.errorLabel.frame = self.errorLabelBaseFrame;
            [self.errorLabel sizeToFit];
            
            
            CGRect frame = self.view.frame;
            frame.size.height = self.baseHeight + self.errorLabel.frame.size.height;
            self.view.frame = frame;
            
            return;
        }
    
    [self.delegate updateReportName:reportName];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMClearSavedReportsListNotification object:nil];
    [self.delegate dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

#pragma mark - NSObject

- (void)dealloc
{
    self.view = nil;
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

    if (error) {
        *errorMessage = error.localizedDescription;
    }

    return [*errorMessage length] == 0;
}

@end
